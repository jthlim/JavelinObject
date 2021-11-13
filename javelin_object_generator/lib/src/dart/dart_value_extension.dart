import 'package:javelin_object/jo_internal.dart';

import '../annotation/annotation_module_extension.dart';
import '../data_type.dart';
import '../module.dart';
import '../value.jo.dart';

extension DartValueExtension on Value {
  String get constValueString {
    final buffer = StringBuffer();
    switch (type) {
      case ValueType.nullValue:
      case ValueType.boolValue:
      case ValueType.intValue:
      case ValueType.doubleValue:
      case ValueType.stringValue:
      case ValueType.enumValue:
      case ValueType.newValue:
        break;
      case ValueType.listValue:
      case ValueType.setValue:
      case ValueType.mapValue:
        buffer.write('const ');
        break;
      case ValueType.classValue:
        final resolvedObject = classValue.objectType.resolvedObject;
        if (!resolvedObject.isImmutable) {
          throw FormatException(
            '${resolvedObject.name} cannot be const constructed as it is '
            'not immutable.',
          );
        }
        buffer.write('const ');
        break;
      case ValueType.unionValue:
        final resolvedObject = unionValue.objectType.resolvedObject;
        if (!resolvedObject.isImmutable) {
          throw FormatException(
            '${resolvedObject.name} cannot be const constructed as it is '
            'not immutable.',
          );
        }
        buffer.write('const ');
        break;
    }
    _addValueString(buffer);
    return buffer.toString();
  }

  String get valueString {
    final buffer = StringBuffer();
    switch (type) {
      case ValueType.nullValue:
      case ValueType.boolValue:
      case ValueType.intValue:
      case ValueType.doubleValue:
      case ValueType.stringValue:
      case ValueType.enumValue:
      case ValueType.newValue:
        break;
      case ValueType.listValue:
      case ValueType.setValue:
      case ValueType.mapValue:
        buffer.write('const ');
        break;
      case ValueType.classValue:
        final resolvedObject = classValue.objectType.resolvedObject;
        if (resolvedObject.isImmutable) {
          buffer.write('const ');
        }
        break;
      case ValueType.unionValue:
        final resolvedObject = unionValue.objectType.resolvedObject;
        if (resolvedObject.isImmutable) {
          buffer.write('const ');
        }
        break;
    }
    _addValueString(buffer);
    return buffer.toString();
  }

  void _addValueString(StringBuffer buffer) {
    when(
      newValue: (newValue) => newValue._addValueString(buffer),
      nullValue: () => buffer.write('null'),
      boolValue: (value) => buffer.write('$value'),
      intValue: (value) => buffer.write('$value'),
      doubleValue: (value) => buffer.write('$value'),
      stringValue: (value) => buffer.write(value.dartEscapedString),
      listValue: (list) {
        buffer.write('[');
        for (final e in list) {
          e._addValueString(buffer);
          buffer.write(',');
        }
        buffer.write(']');
      },
      setValue: (set) {
        buffer.write('{');
        for (final e in set) {
          e._addValueString(buffer);
          buffer.write(',');
        }
        buffer.write('}');
      },
      mapValue: (map) {
        buffer.write('{');
        map.forEach((k, v) {
          k._addValueString(buffer);
          buffer.write(': ');
          v._addValueString(buffer);
          buffer.write(',');
        });
        buffer.write('}');
      },
      classValue: (classValue) {
        final type = classValue.objectType.resolvedObject;
        if (type is! Class) {
          if (type is Enum) {
            throw FormatException(
              '${type.name} is not a class. Use Enum.value syntax',
            );
          } else if (type is Union) {
            throw FormatException(
              '${type.name} is not a class. Use Union.activeElement(param)',
            );
          }
          throw StateError('Internal error');
        }

        final fieldNames = <String, String>{};
        for (final field in type.fields) {
          fieldNames[field.name] = field.name;
          for (final alias in field.aliases) {
            fieldNames[alias] = field.name;
          }
        }
        for (final key in classValue.parameters.keys) {
          if (!fieldNames.containsKey(key)) {
            throw FormatException('${type.name} has no parameter named $key');
          }
        }

        buffer.write('${type.name}(');
        var isFirstTime = true;
        for (final field in type.fields) {
          final value = classValue.parameters[field.name];
          if (value == null) {
            if (field.type.isOptional) continue;
            if (field.defaultValue != null) continue;
            throw FormatException(
              '${type.name} requires field \'${field.name}\'',
            );
          }
          if (isFirstTime) {
            isFirstTime = false;
          } else {
            buffer.write(', ');
          }
          buffer.write('${field.name}: ');
          value._addValueString(buffer);
        }

        buffer.write(')');
      },
      enumValue: (enumValue) {
        final objectType = enumValue.objectType;
        final objectName = objectType.objectName;
        buffer.write('$objectName.${enumValue.valueName}');
      },
      unionValue: (unionValue) {
        final type = unionValue.objectType.resolvedObject;
        if (type is! Union) {
          if (type is Enum) {
            throw FormatException(
              '${type.name} is not a union. Use Enum.value syntax',
            );
          } else if (type is Class) {
            throw FormatException(
              '${type.name} is not a union. Use Class(param: value) syntax',
            );
          }
          throw StateError('Internal error');
        }
        final fieldName = unionValue.activeElementName;

        final field = type.fields.firstWhere(
          (f) => f.name == fieldName,
          orElse: () {
            throw FormatException('$fieldName not found in union ${type.name}');
          },
        );
        buffer.write('${type.name}.$fieldName(');
        final value = unionValue.value;
        if (value != null) {
          buffer.write(value.valueString);
        } else if (!field.type.isOptional && field.defaultValue == null) {
          throw FormatException('${type.name}.$fieldName requires a parameter');
        }
        buffer.write(')');
      },
    );
  }

  Object? toDartObject() {
    return when(
      newValue: (newValue) => newValue.toDartObject(),
      nullValue: () => null,
      boolValue: (value) => value,
      intValue: (value) => value,
      doubleValue: (value) => value,
      stringValue: (value) => value,
      listValue: (list) => list.map((e) => e.toDartObject()).toList(),
      setValue: (set) => set.map((e) => e.toDartObject()).toList(),
      mapValue: (map) =>
          map.map((k, v) => MapEntry(k.toDartObject(), v.toDartObject())),
      classValue: (classValue) =>
          classValue.parameters.map((k, v) => MapEntry(k, v.toDartObject())),
      enumValue: (enumValue) => enumValue.valueName,
      unionValue: (unionValue) {
        if ((unionValue.objectType.resolvedObject as Union).isInline) {
          return unionValue.value?.toDartObject();
        }

        return <String, Object?>{
          unionValue.activeElementName: unionValue.value?.toDartObject()
        };
      },
    );
  }
}
