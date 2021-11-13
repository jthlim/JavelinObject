import 'package:collection/collection.dart';

import '../../compiler_context.dart';
import '../../dart/dart_module_extension.dart';
import '../../dart/dart_value_extension.dart';
import '../../dart/data_type_format_extension.dart';
import '../../data_type.dart';
import '../../generator.dart';
import '../../generator_priority/object_generator_priority.dart';
import '../../module.dart';
import '../../value.jo.dart';

import '../annotation_module_extension.dart';
import '../annotations.jo.dart';

class FromBinaryFactoryClassGenerator implements ClassGenerator {
  FromBinaryFactoryClassGenerator(this.module);

  final Module module;

  static void processFromBinaryConvertAnnotation(
    CompilerContext context,
    Module module,
    Class c,
    ConvertClass annotation,
  ) {
    context.addClassGenerator(FromBinaryFactoryClassGenerator(module), c: c);
    context.addClassGenerator(
      const FromBinaryFactoryHelperClassGenerator(),
      c: c,
    );
  }

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    if (c.isVirtual && !c.isAbstract) {
      final typeId = c.typeId;
      final registration = module.dartRegistration;

      for (final cls in c.classAndSuperclasses) {
        if (cls.isVirtual) {
          registration.add(
            '  of.registerBinaryFactory<${cls.name}>(\n'
            '    $typeId,\n'
            '    (map) => ${c.name}.fromJoFieldMap0(map),\n'
            '  );\n',
          );
        }
      }
    }

    if (c.isVirtual) {
      final derivedFieldId = c.derivedFieldId;

      final derivedField =
          c.fields.firstWhereOrNull((f) => f.fieldId == derivedFieldId);

      if (derivedField != null) {
        throw FormatException(
          '${c.name}.${derivedField.name} uses fieldId $derivedFieldId, '
          'but this id is used to serialize the derived class. Either change '
          'it to another fieldId, or use derivedFieldId: parameter to the '
          'Convert annotation.',
        );
      }

      if (!c.hasSuperclass && c.isVirtual) {
        final typeIdFieldId = c.typeIdFieldId;
        final typeIdField =
            c.fields.firstWhereOrNull((f) => f.fieldId == typeIdFieldId);

        if (typeIdField != null) {
          throw FormatException(
            '${c.name}.${typeIdField.name} uses fieldId $typeIdFieldId, '
            'but this id is used to serialize the type id of the class. Either '
            'change to to another fieldId, or use typeIdFieldId: parameter to '
            'the Convert annotation.',
          );
        }

        if (typeIdFieldId == derivedFieldId) {
          throw FormatException(
            '${c.name} has derivedFieldId and typeIdFieldId both set to '
            '$typeIdFieldId.',
          );
        }
      }
    }

    buffer.write('\n');
    if (c.isVirtual) {
      if (c.isAbstract) {
        buffer.write(
          '  factory ${c.name}.fromBytes(Uint8List bytes) {\n'
          '    final joFieldMap = parseJoBinary(bytes);\n'
          '    return JoObjectFactory().createFromBinary(joFieldMap, ${c.typeIdFieldId})!;\n'
          '  }\n',
        );
      } else {
        buffer.write(
          '  factory ${c.name}.fromBytes(Uint8List bytes) {\n'
          '    final joFieldMap = parseJoBinary(bytes);\n'
          '    return JoObjectFactory().createFromBinary(joFieldMap, ${c.typeIdFieldId}) ??\n'
          '        ${c.name}.fromJoFieldMap0(joFieldMap);\n'
          '  }\n',
        );
      }
    } else if (!c.isAbstract) {
      buffer.write(
        '  factory ${c.name}.fromBytes(Uint8List bytes) => '
        '${c.name}.fromJoFieldMap0(parseJoBinary(bytes));\n'
        '\n',
      );
    }

    final derivedFieldIds = c.derivedFieldIds;
    final classDepth = c.depth;
    for (var i = 0; i < classDepth; ++i) {
      if (c.isAbstract) {
        buffer.write('  @protected\n');
      }
      buffer.write('  ${c.name}.fromJoFieldMap$i(');
      for (var j = 0; j <= i; ++j) {
        if (j != 0) buffer.write(', ');
        buffer.write('Map<int, JoFieldData> map$j');
      }
      buffer.write(') : this.fromJoFieldMap${i + 1}(');
      for (var j = 0; j <= i; ++j) {
        if (j != 0) buffer.write(', ');
        buffer.write('map$j');
      }
      buffer.write(
        ', map$i.embeddedObject(${derivedFieldIds[i]}) ?? const {});\n',
      );
    }

    if (c.isAbstract) {
      buffer.write('  @protected\n');
    }
    buffer.write('  ${c.name}.fromJoFieldMap$classDepth(');
    for (var i = 0; i < classDepth; ++i) {
      if (i != 0) buffer.write(', ');
      buffer.write('Map<int, JoFieldData> map$i');
    }
    if (classDepth != 0) buffer.write(', ');
    buffer.write('Map<int, JoFieldData> map)');

    var isFirstTime = true;
    if (c.fields.isNotEmpty) {
      for (final field in c.fields) {
        if (isFirstTime) {
          isFirstTime = false;
          buffer.write('\n    : ');
        } else {
          buffer.write(',\n      ');
        }
        buffer.write(
          '${field.storageName} = _${field.name}FromJoFieldMap(map)',
        );
      }
    }

    if (c.hasSuperclassMembers) {
      if (isFirstTime) {
        isFirstTime = false;
        buffer.write('\n    : ');
      } else {
        buffer.write(',\n      ');
      }
      buffer.write('super.fromJoFieldMap${classDepth - 1}(');
      for (var i = 0; i < classDepth; ++i) {
        if (i != 0) buffer.write(', ');
        buffer.write('map$i');
      }
      buffer.write(')');
    }

    buffer.write(';\n');
  }

  @override
  int get priority => ObjectGeneratorPriority.convertFactory.index;
}

class FromBinaryFactoryHelperClassGenerator implements ClassGenerator {
  const FromBinaryFactoryHelperClassGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    c.fields.validateAllFieldsHaveIds('class ${c.name}');

    buffer.write('\n');
    for (final field in c.fields) {
      buffer.write(
        '  static ${field.type.dartType} _${field.name}FromJoFieldMap(Map<int, JoFieldData> map) ',
      );

      final nonOptionalFieldType = field.type.nonOptional;

      // Big switch statement to handle all types.
      // break; will tidy up default values and suffix nullability.
      switch (nonOptionalFieldType.kind) {
        case DataTypeKind.optionalType:
          throw StateError('Internal error');
        case DataTypeKind.boolType:
          buffer.write('=>\n    map.boolValue(${field.fieldId}');
          break;
        case DataTypeKind.int8Type:
        case DataTypeKind.int32Type:
        case DataTypeKind.int64Type:
          buffer.write('=>\n    map.intValue(${field.fieldId}');
          break;
        case DataTypeKind.uint8Type:
        case DataTypeKind.uint32Type:
        case DataTypeKind.uint64Type:
          buffer.write('=>\n    map.uintValue(${field.fieldId}');
          break;
        case DataTypeKind.floatType:
        case DataTypeKind.doubleType:
          buffer.write('=>\n    map.doubleValue(${field.fieldId}');
          break;
        case DataTypeKind.stringType:
          buffer.write('=>\n    map.stringValue(${field.fieldId}');
          break;
        case DataTypeKind.bytesType:
          buffer.write('=>\n    map.bytesValue(${field.fieldId}');
          break;
        case DataTypeKind.listType:
          final isImmutable = c.isImmutable || field.isImmutable;
          final elementFactory =
              _createFactory(nonOptionalFieldType.listType, isImmutable);
          final opt = field.type.isOptional ? '' : '!';
          buffer.write(
            '=>\n    map.listValue(${field.fieldId}, $elementFactory, $isImmutable)$opt;\n',
          );
          continue;
        case DataTypeKind.setType:
          final isImmutable = c.isImmutable || field.isImmutable;
          final elementFactory =
              _createFactory(nonOptionalFieldType.setType, isImmutable);
          final opt = field.type.isOptional ? '' : '!';
          buffer.write(
            '=>\n    map.setValue(${field.fieldId}, $elementFactory, $isImmutable)$opt;\n',
          );
          continue;
        case DataTypeKind.mapType:
          final isImmutable = c.isImmutable || field.isImmutable;
          final mapDataType = nonOptionalFieldType.mapType;
          final keyFactory = _createFactory(mapDataType.keyType, isImmutable);
          final valueFactory =
              _createFactory(mapDataType.valueType, isImmutable);
          final opt = field.type.isOptional ? '' : '!';
          buffer.write(
            '=>\n    map.mapValue(${field.fieldId}, $keyFactory, $valueFactory, $isImmutable)$opt;\n',
          );
          continue;
        case DataTypeKind.objectType:
          final object = nonOptionalFieldType.objectType.resolvedObject;
          if (object is Class || object is Union) {
            final tempFieldName = '\$${field.name}';
            buffer.write(
              '{\n'
              '    final $tempFieldName = map.bytesValue(${field.fieldId});\n',
            );
            var needsForceUnwrap = true;
            if (field.type.isOptional) {
              buffer.write('    if (\$${field.name} == null) return null;\n');
              needsForceUnwrap = false;
            } else {
              final defaultValue = field.defaultValue;
              if (defaultValue != null) {
                buffer.write(
                  '    if ($tempFieldName == null) '
                  'return ${defaultValue.valueString};\n',
                );
                needsForceUnwrap = false;
              }
            }
            buffer.write(
              '    return ${object.name}.fromBytes($tempFieldName',
            );
            if (needsForceUnwrap) buffer.write('!');
            buffer.write(
              ');\n'
              '  }\n',
            );
            continue;
          } else if (object is Enum) {
            final convertAnnotations =
                object.annotations.annotationsOfType<ConvertEnum>();
            if (!convertAnnotations.any((e) => e.includeFromId)) {
              throw FormatException(
                'Cannot serialize ${c.name} to binary as field ${field.name} is '
                'an enum ${object.name} that does not specify '
                '@Convert(fromId: true)',
              );
            }
            buffer.write(
              '=>\n    map.enumValue(${field.fieldId}, ${object.name}.fromIdOrNull',
            );
          } else {
            throw UnimplementedError(
              'Binary serialization not yet implemented for '
              '${object.runtimeType}',
            );
          }
      }
      final defaultValue = field.defaultValue;
      if (defaultValue != null) {
        if (defaultValue.type == ValueType.newValue) {
          buffer.write(') ?? ${defaultValue.valueString};\n');
          continue;
        } else {
          buffer.write(', defaultValue: ${defaultValue.constValueString}');
        }
      }

      if (field.type.isOptional) {
        buffer.write(');\n');
      } else {
        buffer.write(')!;\n');
      }
    }
  }

  @override
  int get priority => ObjectGeneratorPriority.convertFactoryHelper.index;
}

class BinaryTypeIdClassGenerator implements ClassGenerator {
  const BinaryTypeIdClassGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    if (!c.hasVirtualFactory) return;

    if (c.isAbstract) {
      buffer.write(
        '\n'
        '  int get \$joTypeId;\n',
      );
    } else {
      buffer.write(
        '\n'
        '  int get \$joTypeId => ${c.typeId};\n',
      );
    }
  }

  @override
  int get priority => ObjectGeneratorPriority.accessors.index;
}

class ToBinaryClassGenerator implements ClassGenerator {
  const ToBinaryClassGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    c.fields.validateAllFieldsHaveIds('class ${c.name}');

    if (c.isExtendable || c.hasSuperclass) {
      buffer.write(
        '\n'
        '  Uint8List toBytes([bool \$includeType=${c.isVirtual}]) =>\n'
        '    encodeBytes(null, \$includeType).toBytes();\n'
        '\n'
        '  JoBinaryEncoder encodeBytes([\n'
        '    JoBinaryEncoder? \$derivedEncoder,\n'
        '    bool \$includeType=${c.isVirtual},\n'
        '  ]) {\n',
      );
    } else {
      buffer.write(
        '\n'
        '  Uint8List toBytes() => encodeBytes().toBytes();\n'
        '\n'
        '  JoBinaryEncoder encodeBytes([JoBinaryEncoder? \$derivedEncoder]) {\n',
      );
    }

    buffer.write('    final encoder = JoBinaryEncoder();\n');
    if (c.isExtendable) {
      buffer.write(
        '    if (\$derivedEncoder != null) {\n'
        '      encoder.writeObject(${c.derivedFieldId}, \$derivedEncoder);\n'
        '    }\n',
      );
    }

    if (c.isVirtual &&
        (c.baseClass == null ||
            !c.baseClass!.resolvedClass.hasVirtualFactory)) {
      buffer.write(
        '    if (\$includeType) {\n'
        '      encoder.writeUint(${c.typeIdFieldId}, \$joTypeId);\n'
        '    }\n',
      );
    }

    for (final field in c.fields) {
      final fieldType = field.type;
      if (fieldType.isOptional) {
        final nonOptionalType = fieldType.nonOptional;
        buffer.write(
          '    final \$${field.name} = ${field.storageName};\n',
        );
        buffer.write('    if (\$${field.name} != null) {\n');
        _generateFieldWrite(
            buffer, '      ', nonOptionalType, field, '\$${field.name}');
        buffer.write('    }\n');
      } else {
        _generateFieldWrite(buffer, '    ', fieldType, field, field.name);
      }
    }

    if (c.hasSuperclass) {
      buffer.write('    return super.encodeBytes(encoder, \$includeType);\n');
    } else {
      buffer.write('    return encoder;\n');
    }

    buffer.write('  }\n');
  }

  @override
  int get priority => ObjectGeneratorPriority.converter.index;
}

class FromBinaryFactoryUnionGenerator implements UnionGenerator {
  const FromBinaryFactoryUnionGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    u.fields.validateAllFieldsHaveIds('union ${u.name}');

    buffer.write(
      '\n'
      '  factory ${u.name}.fromBytes(Uint8List bytes) =>\n'
      '    ${u.name}.fromJoFieldMapOrNull(parseJoBinary(bytes))!;\n'
      '\n'
      '  static ${u.name}? fromJoFieldMapOrNull(Map<int, JoFieldData> map) {\n'
      '    final entries = map.entries;\n'
      '    if (entries.length != 1) return null;\n'
      '    final entry = entries.first;\n'
      '    switch (entry.key) {\n',
    );

    for (final field in u.fields) {
      if (field.canUseParameterlessConstructor) {
        buffer.write(
          '      case ${field.fieldId}:\n'
          '        return _${field.name}FromJoField();\n',
        );
      } else {
        buffer.write(
          '      case ${field.fieldId}:\n'
          '        return _${field.name}FromJoField(entry.value);\n',
        );
      }
    }

    buffer.write(
      '      default:\n'
      '        return null;\n'
      '    }\n'
      '  }\n',
    );
  }

  @override
  int get priority => ObjectGeneratorPriority.convertFactory.index;
}

class FromBinaryFactoryHelperUnionGenerator implements UnionGenerator {
  const FromBinaryFactoryHelperUnionGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    buffer.write('\n');
    for (final field in u.fields) {
      if (field.canUseParameterlessConstructor) {
        buffer.write(
          '  static ${u.name} _${field.name}FromJoField() =>\n'
          '    const ${u.name}.${field.name}();\n',
        );
        continue;
      }

      final nonOptionalFieldType = field.type.nonOptional;
      final object = nonOptionalFieldType.objectTypeOrNull?.resolvedObject;
      final isOptionalReturnType = object is Enum || object is Union;

      if (isOptionalReturnType) {
        buffer.write(
          '  static ${u.name}? _${field.name}FromJoField(JoFieldData data) ',
        );
      } else {
        buffer.write(
          '  static ${u.name} _${field.name}FromJoField(JoFieldData data) ',
        );
      }

      switch (field.type.kind) {
        case DataTypeKind.optionalType:
          final isImmutable = u.isImmutable || field.isImmutable;
          final valueFactory =
              _createFactory(field.type.optionalType, isImmutable);
          buffer.write(
            '=>\n    ${u.name}.${field.name}(data.optionalValue($valueFactory));\n',
          );
          break;
        case DataTypeKind.boolType:
          buffer.write('=>\n    ${u.name}.${field.name}(data.boolValue);\n');
          break;
        case DataTypeKind.int8Type:
        case DataTypeKind.int32Type:
        case DataTypeKind.int64Type:
          buffer.write('=>\n    ${u.name}.${field.name}(data.intValue);\n');
          break;
        case DataTypeKind.uint8Type:
        case DataTypeKind.uint32Type:
        case DataTypeKind.uint64Type:
          buffer.write('=>\n    ${u.name}.${field.name}(data.uintValue);\n');
          break;
        case DataTypeKind.floatType:
        case DataTypeKind.doubleType:
          buffer.write('=>\n    ${u.name}.${field.name}(data.doubleValue);\n');
          break;
        case DataTypeKind.stringType:
          buffer.write('=>\n    ${u.name}.${field.name}(data.stringValue);\n');
          break;
        case DataTypeKind.bytesType:
          buffer.write('=>\n    ${u.name}.${field.name}(data.bytesValue);\n');
          break;
        case DataTypeKind.listType:
          final isImmutable = u.isImmutable || field.isImmutable;
          final elementFactory =
              _createFactory(nonOptionalFieldType.listType, isImmutable);
          buffer.write(
            '=>\n    ${u.name}.${field.name}(data.listValue($elementFactory, $isImmutable));\n',
          );
          break;
        case DataTypeKind.setType:
          final isImmutable = u.isImmutable || field.isImmutable;
          final elementFactory =
              _createFactory(nonOptionalFieldType.setType, isImmutable);
          buffer.write(
            '=>\n    ${u.name}.${field.name}(data.setValue($elementFactory, $isImmutable));\n',
          );
          break;
        case DataTypeKind.mapType:
          final map = nonOptionalFieldType.mapType;
          final isImmutable = u.isImmutable || field.isImmutable;
          final keyFactory = _createFactory(map.keyType, isImmutable);
          final valueFactory = _createFactory(map.valueType, isImmutable);
          buffer.write(
            '=>\n    ${u.name}.${field.name}(data.mapValue($keyFactory, $valueFactory, true));\n',
          );
          break;
        case DataTypeKind.objectType:
          if (object is Class) {
            buffer.write(
              '=>\n    ${u.name}.${field.name}(${object.name}.fromJoFieldMap0(data.embeddedObject));\n',
            );
          } else if (object is Union) {
            buffer.write(
              '{\n'
              '    final result = ${object.name}.fromJoFieldMapOrNull(data.embeddedObject);\n'
              '    if (result == null) return null;\n'
              '    return ${u.name}.${field.name}(result);\n'
              '  }\n',
            );
          } else if (object is Enum) {
            final convertAnnotations =
                object.annotations.annotationsOfType<ConvertEnum>();
            if (!convertAnnotations.any((e) => e.includeFromId)) {
              throw FormatException(
                'Cannot serialize ${u.name} to binary as field ${field.name} is '
                'an enum ${object.name} that does not specify '
                '@Convert(fromId: true)',
              );
            }
            buffer.write(
              '{\n'
              '    final result = ${object.name}.fromIdOrNull(data.uintValue);\n'
              '    if (result == null) return null;\n'
              '    return ${u.name}.${field.name}(result);\n'
              '  }\n',
            );
          } else {
            throw UnimplementedError(
              'Binary serialization not yet implemented for '
              '${object.runtimeType}',
            );
          }
          break;
      }
    }
  }

  @override
  int get priority => ObjectGeneratorPriority.convertFactoryHelper.index;
}

class ToBinaryUnionGenerator implements UnionGenerator {
  const ToBinaryUnionGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    u.fields.validateAllFieldsHaveIds('union ${u.name}');

    buffer.write(
      '\n'
      '  Uint8List toBytes() {\n'
      '    final encoder = JoBinaryEncoder();\n'
      '    encodeBytes(encoder);\n'
      '    return encoder.toBytes();\n'
      '  }\n'
      '\n'
      '  void encodeBytes(JoBinaryEncoder encoder) {\n'
      '    switch (${u.activeElementFieldName}) {\n',
    );
    for (final field in u.fields) {
      final fieldType = field.type;
      buffer.write('     case ${u.activeElementClassName}.${field.name}:\n');
      _generateFieldWrite(buffer, '       ', fieldType, field, field.name);
      buffer.write('       break;\n');
    }
    buffer.write(
      '    }\n'
      '  }\n',
    );
  }

  @override
  int get priority => ObjectGeneratorPriority.converter.index;
}

void _generateFieldWrite(
  StringBuffer buffer,
  String prefix,
  DataType fieldType,
  Field field,
  String variableName,
) {
  buffer.write(prefix);
  switch (fieldType.kind) {
    case DataTypeKind.optionalType:
      final valueType = fieldType.optionalType;
      final valueSerializer = _createSerializer(valueType);
      buffer.write(
        'encoder.writeOptional<${valueType.dartType}>'
        '(${field.fieldId}, $variableName, $valueSerializer);\n',
      );
      break;
    case DataTypeKind.boolType:
      buffer.write('encoder.writeBool(${field.fieldId}, $variableName);\n');
      break;
    case DataTypeKind.int8Type:
    case DataTypeKind.int32Type:
    case DataTypeKind.int64Type:
      buffer.write('encoder.writeInt(${field.fieldId}, $variableName);\n');
      break;
    case DataTypeKind.uint8Type:
    case DataTypeKind.uint32Type:
    case DataTypeKind.uint64Type:
      buffer.write('encoder.writeUint(${field.fieldId}, $variableName);\n');
      break;
    case DataTypeKind.floatType:
      buffer.write('encoder.writeFloat(${field.fieldId}, $variableName);\n');
      break;
    case DataTypeKind.doubleType:
      buffer.write('encoder.writeDouble(${field.fieldId}, $variableName);\n');
      break;
    case DataTypeKind.stringType:
      buffer.write('encoder.writeString(${field.fieldId}, $variableName);\n');
      break;
    case DataTypeKind.bytesType:
      buffer.write('encoder.writeBytes(${field.fieldId}, $variableName);\n');
      break;
    case DataTypeKind.listType:
      final elementType = fieldType.listType;
      final elementSerializer = _createSerializer(elementType);
      buffer.write(
        'encoder.writeIterable<${elementType.dartType}>'
        '(${field.fieldId}, $variableName, $elementSerializer);\n',
      );
      break;
    case DataTypeKind.setType:
      final elementType = fieldType.setType;
      final elementSerializer = _createSerializer(elementType);
      buffer.write(
        'encoder.writeIterable<${elementType.dartType}>'
        '(${field.fieldId}, $variableName, $elementSerializer);\n',
      );
      break;
    case DataTypeKind.mapType:
      final map = fieldType.mapType;
      final keySerializer = _createSerializer(map.keyType);
      final valueSerializer = _createSerializer(map.valueType);
      buffer.write(
        'encoder.writeMap'
        '<${map.keyType.dartType}, ${map.valueType.dartType}>'
        '(${field.fieldId}, $variableName, $keySerializer, $valueSerializer);\n',
      );
      break;
    case DataTypeKind.objectType:
      final object = fieldType.objectType.resolvedObject;
      if (object is Class) {
        if (object.isExtendable) {
          buffer.write(
            'encoder.writeObject(${field.fieldId}, $variableName.encodeBytes(null, ${object.isVirtual}));\n',
          );
        } else {
          buffer.write(
            'encoder.writeObject(${field.fieldId}, $variableName.encodeBytes());\n',
          );
        }
      } else if (object is Enum) {
        buffer.write(
          'encoder.writeUint(${field.fieldId}, $variableName.\$id);\n',
        );
      } else if (object is Union) {
        final fieldEncoderName = '\$${field.name}Encoder';
        buffer.write(
          'final $fieldEncoderName = JoBinaryEncoder();\n'
          '$prefix$variableName.encodeBytes($fieldEncoderName);\n'
          '${prefix}encoder.writeObject(${field.fieldId}, $fieldEncoderName);\n',
        );
      } else {
        throw UnimplementedError(
          'Binary serialization not implemented for ${object.runtimeType}',
        );
      }
      break;
  }
}

String _createFactory(DataType type, bool immutable) {
  switch (type.kind) {
    case DataTypeKind.optionalType:
      final valueFactory = _createFactory(type.optionalType, immutable);
      return '(fieldData) => fieldData.optionalValue($valueFactory)';
    case DataTypeKind.boolType:
      return '(fieldData) => fieldData.boolValue';
    case DataTypeKind.int8Type:
    case DataTypeKind.int32Type:
    case DataTypeKind.int64Type:
      return '(fieldData) => fieldData.intValue';
    case DataTypeKind.uint8Type:
    case DataTypeKind.uint32Type:
    case DataTypeKind.uint64Type:
      return '(fieldData) => fieldData.uintValue';
    case DataTypeKind.floatType:
    case DataTypeKind.doubleType:
      return '(fieldData) => fieldData.doubleValue';
    case DataTypeKind.stringType:
      return '(fieldData) => fieldData.stringValue';
    case DataTypeKind.bytesType:
      return '(fieldData) => fieldData.bytesValue';
    case DataTypeKind.listType:
      final elementFactory = _createFactory(type.listType, immutable);
      return '(fieldData) => fieldData.listValue($elementFactory, $immutable)';
    case DataTypeKind.setType:
      final elementFactory = _createFactory(type.setType, immutable);
      return '(fieldData) => fieldData.setValue($elementFactory, $immutable)';
    case DataTypeKind.mapType:
      final map = type.mapType;
      final keyFactory = _createFactory(map.keyType, immutable);
      final valueFactory = _createFactory(map.valueType, immutable);
      return '(fieldData) => fieldData.mapValue($keyFactory, $valueFactory, $immutable)';
    case DataTypeKind.objectType:
      final object = type.objectType.resolvedObject;
      if (object is Class) {
        return '(fieldData) => ${object.name}'
            '.fromJoFieldMap0(fieldData.embeddedObject)';
      } else if (object is Union) {
        return '(fieldData) => ${object.name}.fromJoFieldMapOrNull(fieldData.embeddedObject)';
      } else if (object is Enum) {
        return '(fieldData) => ${object.name}.fromIdOrNull(fieldData.uintValue)';
      } else {
        throw UnimplementedError(
          'Binary serialization not yet implemented for '
          '${object.runtimeType}',
        );
      }
  }
}

String _createSerializer(DataType type) {
  switch (type.kind) {
    case DataTypeKind.optionalType:
      throw StateError('Internal error');
    case DataTypeKind.boolType:
      return '(enc, e) => enc.writeBool(e)';
    case DataTypeKind.int8Type:
    case DataTypeKind.int32Type:
    case DataTypeKind.int64Type:
      return '(enc, e) => enc.writeInt(e)';
    case DataTypeKind.uint8Type:
    case DataTypeKind.uint32Type:
    case DataTypeKind.uint64Type:
      return '(enc, e) => enc.writeUint(e)';
    case DataTypeKind.floatType:
      return '(enc, e) => enc.writeFloat(e)';
    case DataTypeKind.doubleType:
      return '(enc, e) => enc.writeDouble(e)';
    case DataTypeKind.stringType:
      return '(enc, e) => enc.writeString(e)';
    case DataTypeKind.bytesType:
      return '(enc, e) => enc.writeBytes(e)';
    case DataTypeKind.listType:
      final elementType = type.listType;
      final elementSerializer = _createSerializer(elementType);
      return '(enc, e) => enc.writeIterable<${elementType.dartType}>'
          '(e, $elementSerializer)';
    case DataTypeKind.setType:
      final elementType = type.setType;
      final elementSerializer = _createSerializer(elementType);
      return '(enc, e) => enc.writeIterable<${elementType.dartType}>'
          '(e, $elementSerializer)';
    case DataTypeKind.mapType:
      final map = type.mapType;
      final keyFactory = _createSerializer(map.keyType);
      final valueFactory = _createSerializer(map.valueType);
      return '(enc, e) => enc.writeMap'
          '<${map.keyType.dartType}, ${map.valueType.dartType}>'
          '(e, $keyFactory, $valueFactory)';
    case DataTypeKind.objectType:
      final object = type.objectType.resolvedObject;
      if (object is Class) {
        return '(enc, e) => enc.writeObject(e.encodeBytes())';
      } else if (object is Enum) {
        return '(enc, e) => enc.writeUint(e.\$id)';
      } else if (object is Union) {
        return '(enc, e) {\n'
            '        final objectEncoder = JoBinaryEncoder();\n'
            '        e.encodeBytes(objectEncoder);\n'
            '        enc.writeObject(objectEncoder);\n'
            '      }';
      } else {
        throw UnimplementedError(
          'Binary serialization not yet implemented for '
          '${object.runtimeType}',
        );
      }
  }
}
