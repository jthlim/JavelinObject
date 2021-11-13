import '../../compiler_context.dart';
import '../../dart/data_type_format_extension.dart';
import '../../data_type.dart';
import '../../generator.dart';
import '../../generator_priority/object_generator_priority.dart';
import '../../module.dart';
import '../annotation_module_extension.dart';

class FromObjectUnionGenerator implements UnionGenerator {
  const FromObjectUnionGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    final dartTypeGroups = <_DartTypeGroup, Field>{};

    buffer.write(
      '  factory ${u.name}.fromObject(Object object) => fromObjectOrNull(object)!;\n'
      '\n'
      '  static ${u.name}? fromObjectOrNull(Object? object) {\n',
    );

    for (final field in u.fields) {
      final dartTypeGroup = field.type.dartTypeGroup;
      if (dartTypeGroups.containsKey(dartTypeGroup)) {
        throw FormatException(
          'Inline union has fields ${field.name}, '
          '${dartTypeGroups[dartTypeGroup]!.name} with the same jsonType: $dartTypeGroup',
        );
      }
      dartTypeGroups[dartTypeGroup] = field;
    }

    final dartTypeGroupKeys = dartTypeGroups.keys.toList()
      ..sort((a, b) => a.index - b.index);

    for (final dartTypeGroupKey in dartTypeGroupKeys) {
      final field = dartTypeGroups[dartTypeGroupKey]!;
      buffer.write(
        '    if (object is ${field.type.testDartType}) {\n'
        '      return ${u.name}.${field.name}'
        /*    */ '(${field.type.nonOptional.mapToObjectConverter(variableName: 'object', checkTypes: false)});\n'
        '    }\n',
      );
    }

    buffer.write(
      '    return null;\n'
      '  }\n',
    );
  }

  @override
  int get priority => ObjectGeneratorPriority.convertFactory.index;
}

class ToObjectUnionGenerator implements UnionGenerator {
  const ToObjectUnionGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    if (!u.isInline) {
      throw FormatException(
        'toObject cannot be generated for non-inline union ${u.name}',
      );
    }

    buffer.write(
      '\n'
      '  Object toObject() {\n'
      '    switch (${u.activeElementFieldName}) {\n',
    );
    var hasPlainObjects = false;
    for (final field in u.fields) {
      final variableName = '\$${field.name}';

      final nonOptionalType = field.type.nonOptional;
      final objectConverter =
          nonOptionalType.objectToMapConverter(variableName);

      if (objectConverter != variableName) continue;

      buffer.write('      case ${u.activeElementClassName}.${field.name}:\n');
      hasPlainObjects = true;
    }
    if (hasPlainObjects) {
      buffer.write('        return _value;\n');
    }

    for (final field in u.fields) {
      final variableName = '\$${field.name}';

      final nonOptionalType = field.type.nonOptional;
      final objectConverter =
          nonOptionalType.objectToMapConverter(variableName);

      if (objectConverter == variableName) continue;

      buffer.write(
        '      case ${u.activeElementClassName}.${field.name}:\n'
        '        final $variableName = _value as ${nonOptionalType.dartType};\n'
        '        return $objectConverter;\n',
      );
    }
    buffer.write(
      '    }\n'
      '  }',
    );
  }

  @override
  int get priority => ObjectGeneratorPriority.converter.index;
}

enum _DartTypeGroup {
  boolean,
  integer,
  bytes,
  string,
  real,
  list,
  set,
  map,
}

extension _DataTypeExtension on DataType {
  _DartTypeGroup get dartTypeGroup {
    final type = nonOptional;
    switch (type.kind) {
      case DataTypeKind.optionalType:
        throw StateError('Internal error');
      case DataTypeKind.boolType:
        return _DartTypeGroup.boolean;
      case DataTypeKind.int8Type:
      case DataTypeKind.int32Type:
      case DataTypeKind.int64Type:
      case DataTypeKind.uint8Type:
      case DataTypeKind.uint32Type:
      case DataTypeKind.uint64Type:
        return _DartTypeGroup.integer;
      case DataTypeKind.floatType:
      case DataTypeKind.doubleType:
        return _DartTypeGroup.real;
      case DataTypeKind.stringType:
        return _DartTypeGroup.string;
      case DataTypeKind.bytesType:
        return _DartTypeGroup.bytes;
      case DataTypeKind.listType:
        return _DartTypeGroup.list;
      case DataTypeKind.setType:
        return _DartTypeGroup.set;
      case DataTypeKind.mapType:
        return _DartTypeGroup.map;
      case DataTypeKind.objectType:
        final object = type.objectType.resolvedObject;
        if (object is Class) return _DartTypeGroup.map;
        if (object is Enum) return _DartTypeGroup.string;
        if (object is Union) {
          if (object.isInline) {
            throw FormatException(
              'Cannot use inline union ${object.name} inside another '
              'inline union',
            );
          }
          return _DartTypeGroup.map;
        }
        throw UnimplementedError('Type ${object.runtimeType} not handled');
    }
  }

  String get testDartType {
    final type = nonOptional;
    switch (type.kind) {
      case DataTypeKind.optionalType:
        throw StateError('Internal error');
      case DataTypeKind.boolType:
        return 'bool';
      case DataTypeKind.int8Type:
      case DataTypeKind.int32Type:
      case DataTypeKind.int64Type:
      case DataTypeKind.uint8Type:
      case DataTypeKind.uint32Type:
      case DataTypeKind.uint64Type:
        return 'int';
      case DataTypeKind.floatType:
      case DataTypeKind.doubleType:
        return 'double';
      case DataTypeKind.stringType:
        return 'String';
      case DataTypeKind.bytesType:
        return 'Uint8List';
      case DataTypeKind.listType:
        return 'List';
      case DataTypeKind.setType:
        return 'Set';
      case DataTypeKind.mapType:
        return 'Map';
      case DataTypeKind.objectType:
        final object = type.objectType.resolvedObject;
        if (object is Class) return 'Map';
        if (object is Enum) return 'String';
        if (object is Union) {
          if (object.isInline) {
            throw FormatException(
              'Cannot use inline union ${object.name} inside another '
              'inline union',
            );
          }
          return 'Map';
        }
        throw UnimplementedError('Type ${object.runtimeType} not handled');
    }
  }
}
