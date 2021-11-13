import '../data_type.dart';
import '../module.dart';

extension DataTypeFormatExtension on DataType {
  String get dartType {
    final buffer = StringBuffer();
    _toDartType(buffer, this);
    return buffer.toString();
  }

  String get dartMapType {
    switch (kind) {
      case DataTypeKind.optionalType:
        return '${optionalType.dartMapType}?';
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
      case DataTypeKind.bytesType:
        return 'String';
      case DataTypeKind.listType:
        return 'List';
      case DataTypeKind.setType:
        return 'Set';
      case DataTypeKind.mapType:
        return 'Map';
      case DataTypeKind.objectType:
        final resolvedObject = objectType.resolvedObject;
        if (resolvedObject is Class) {
          return 'Map';
        } else if (resolvedObject is Enum) {
          return 'String';
        } else if (resolvedObject is Union) {
          if (resolvedObject.isInline) {
            return 'Object';
          } else {
            return 'Map';
          }
        }
        throw UnimplementedError(
          'Unhandled datatype: ${resolvedObject.runtimeType}',
        );
    }
  }

  void _toDartType(StringBuffer buffer, DataType type) {
    switch (type.kind) {
      case DataTypeKind.optionalType:
        _toDartType(buffer, type.optionalType);
        buffer.write('?');
        break;
      case DataTypeKind.boolType:
        buffer.write('bool');
        break;
      case DataTypeKind.int8Type:
      case DataTypeKind.int32Type:
      case DataTypeKind.int64Type:
      case DataTypeKind.uint8Type:
      case DataTypeKind.uint32Type:
      case DataTypeKind.uint64Type:
        buffer.write('int');
        break;
      case DataTypeKind.floatType:
      case DataTypeKind.doubleType:
        buffer.write('double');
        break;
      case DataTypeKind.stringType:
        buffer.write('String');
        break;
      case DataTypeKind.bytesType:
        buffer.write('Uint8List');
        break;
      case DataTypeKind.listType:
        buffer.write('List<');
        _toDartType(buffer, type.listType);
        buffer.write('>');
        break;
      case DataTypeKind.setType:
        buffer.write('Set<');
        _toDartType(buffer, type.setType);
        buffer.write('>');
        break;
      case DataTypeKind.mapType:
        buffer.write('Map<');
        _toDartType(buffer, type.mapType.keyType);
        buffer.write(', ');
        _toDartType(buffer, type.mapType.valueType);
        buffer.write('>');
        break;
      case DataTypeKind.objectType:
        buffer.write(type.objectType.objectName);
        break;
    }
  }

  String objectToMapConverter(String variableName) {
    switch (kind) {
      case DataTypeKind.optionalType:
        final converter = optionalType.objectToMapConverter(variableName);
        if (converter == variableName) return variableName;
        return '($variableName == null ? null : $converter)';
      case DataTypeKind.boolType:
      case DataTypeKind.int8Type:
      case DataTypeKind.int32Type:
      case DataTypeKind.int64Type:
      case DataTypeKind.uint8Type:
      case DataTypeKind.uint32Type:
      case DataTypeKind.uint64Type:
      case DataTypeKind.floatType:
      case DataTypeKind.doubleType:
      case DataTypeKind.stringType:
        return variableName;
      case DataTypeKind.bytesType:
        return 'base64Encode($variableName)';
      case DataTypeKind.listType:
        final elementConverter = listType.objectToMapConverter('e');
        if (elementConverter == 'e') return variableName;

        return '$variableName.map((e) => $elementConverter).toList()';
      case DataTypeKind.setType:
        final elementConverter = setType.objectToMapConverter('e');
        if (elementConverter == 'e') return variableName;

        return '$variableName.map((e) => $elementConverter).toSet()';
      case DataTypeKind.mapType:
        final map = mapType;
        final keyConverter = map.keyType.objectToMapConverter('k');
        final valueConverter = map.valueType.objectToMapConverter('v');
        if (keyConverter == 'k' && valueConverter == 'v') return variableName;

        return '$variableName.map'
            '((k, v) => MapEntry($keyConverter, $valueConverter))';
      case DataTypeKind.objectType:
        final resolvedObject = objectType.resolvedObject;
        if (resolvedObject is Enum) {
          return '$variableName.\$name';
        } else if (resolvedObject is Class) {
          if (resolvedObject.isExtendable) {
            return '$variableName.toMap(${resolvedObject.isVirtual})';
          } else {
            return '$variableName.toMap()';
          }
        } else if (resolvedObject is Union) {
          if (resolvedObject.isInline) {
            return '$variableName.toObject()';
          } else {
            return '$variableName.toMap()';
          }
        }
        throw StateError(
          'Internal error: ${resolvedObject.runtimeType} cannot be converted '
          'to a map',
        );
    }
  }

  String mapToObjectConverter({
    required String variableName,
    required bool checkTypes,
  }) {
    switch (kind) {
      case DataTypeKind.optionalType:
        final converter = optionalType.mapToObjectConverter(
          variableName: variableName,
          checkTypes: checkTypes,
        );
        return '($variableName == null ? null : $converter)';
      case DataTypeKind.boolType:
      case DataTypeKind.int8Type:
      case DataTypeKind.int32Type:
      case DataTypeKind.int64Type:
      case DataTypeKind.uint8Type:
      case DataTypeKind.uint32Type:
      case DataTypeKind.uint64Type:
      case DataTypeKind.floatType:
      case DataTypeKind.doubleType:
      case DataTypeKind.stringType:
        if (checkTypes) {
          return '$variableName as $dartType';
        }
        return variableName;
      case DataTypeKind.bytesType:
        if (checkTypes) {
          return 'base64Decode($variableName as String)';
        }
        return 'base64Decode($variableName)';
      case DataTypeKind.listType:
        final elementConverter = listType.mapToObjectConverter(
          variableName: 'e',
          checkTypes: true,
        );

        if (checkTypes) {
          return '($variableName as Iterable).joMapNotNull((e) => $elementConverter).toList()';
        } else {
          return '$variableName.joMapNotNull((e) => $elementConverter).toList()';
        }
      case DataTypeKind.setType:
        final elementConverter = setType.mapToObjectConverter(
          variableName: 'e',
          checkTypes: true,
        );
        if (checkTypes) {
          return '($variableName as Iterable).joMapNotNull((e) => $elementConverter).toSet()';
        } else {
          return '$variableName.joMapNotNull((e) => $elementConverter).toSet()';
        }
      case DataTypeKind.mapType:
        final map = mapType;
        final keyConverter = map.keyType.mapToObjectConverter(
          variableName: 'k',
          checkTypes: true,
        );
        final valueConverter = map.valueType.mapToObjectConverter(
          variableName: 'v',
          checkTypes: true,
        );

        if (checkTypes) {
          return '($variableName as Map).joMapNotNull((k) => $keyConverter, (v) => $valueConverter)';
        } else {
          return '$variableName.joMapNotNull((k) => $keyConverter, (v) => $valueConverter)';
        }
      case DataTypeKind.objectType:
        final resolvedObject = objectType.resolvedObject;
        if (resolvedObject is Class) {
          if (checkTypes) {
            return '${resolvedObject.name}.fromMap($variableName as Map)';
          } else {
            return '${resolvedObject.name}.fromMap($variableName)';
          }
        } else if (resolvedObject is Enum) {
          if (checkTypes) {
            return '${resolvedObject.name}.fromStringOrNull($variableName as String)';
          } else {
            return '${resolvedObject.name}.fromStringOrNull($variableName)';
          }
        } else if (resolvedObject is Union) {
          if (resolvedObject.isInline) {
            if (checkTypes) {
              return '${resolvedObject.name}.fromObjectOrNull($variableName as Object)';
            } else {
              return '${resolvedObject.name}.fromObjectOrNull($variableName)';
            }
          } else {
            if (checkTypes) {
              return '${resolvedObject.name}.fromMapOrNull($variableName as Map)';
            } else {
              return '${resolvedObject.name}.fromMapOrNull($variableName)';
            }
          }
        }
        throw UnimplementedError(
          'Unhandled type ${resolvedObject.runtimeType}',
        );
    }
  }
}
