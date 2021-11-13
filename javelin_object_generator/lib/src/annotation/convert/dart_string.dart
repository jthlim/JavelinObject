import '../../compiler_context.dart';
import '../../dart/dart_module_extension.dart';
import '../../data_type.dart';
import '../../generator.dart';
import '../../generator_priority/object_generator_priority.dart';
import '../../module.dart';

import '../annotation_module_extension.dart';

/// Creates dart code to instantiate a class.
class ToDartStringClassGenerator implements ClassGenerator {
  const ToDartStringClassGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    buffer.write(
      '\n'
      '  String toDartString() {\n'
      '    final buffer = StringBuffer();\n'
      '    buildDartString(buffer);\n'
      '    return buffer.toString();\n'
      '  }\n'
      '\n',
    );

    if (c.isExtendable || c.hasSuperclass) {
      buffer.write(
        '  void buildDartString(StringBuffer buffer, [bool \$forSubclass=false]) {\n',
      );
    } else {
      buffer.write(
        '  void buildDartString(StringBuffer buffer) {\n',
      );
    }

    if (c.isVirtual) {
      buffer.write(
        '    if (!\$forSubclass) {\n'
        '      buffer.write(\'${c.name}(\');\n'
        '    }\n',
      );
    } else {
      buffer.write(
        '    buffer.write(\'${c.name}(\');\n',
      );
    }

    if (c.hasSuperclassMembers) {
      buffer.write('    super.buildDartString(buffer, true);\n');
    }

    for (final field in c.fields) {
      if (field.type.isOptional) {
        final tempVariableName = '\$${field.name}';
        buffer.write(
          '    final $tempVariableName = ${field.storageName};\n'
          '    if ($tempVariableName != null) {\n'
          '      buffer.write(\'${field.name}: ${toDartString(field.type, tempVariableName)},\');\n'
          '    }\n',
        );
      } else {
        buffer.write(
            '      buffer.write(\'${field.name}: ${toDartString(field.type, field.storageName)},\');\n');
      }
    }

    if (c.isVirtual) {
      buffer.write(
        '    if (!\$forSubclass) {\n'
        '      buffer.write(\')\');\n'
        '    }\n'
        '  }\n',
      );
    } else {
      buffer.write(
        '    buffer.write(\')\');\n'
        '  }\n',
      );
    }
  }

  @override
  int get priority => ObjectGeneratorPriority.stringify.index;
}

class ToDartStringEnumGenerator implements EnumGenerator {
  const ToDartStringEnumGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Enum e) {
    buffer.write(
      '\n'
      '  String toDartString() => \'${e.name}\.\${\$name}\';\n'
      '\n'
      '  void buildDartString(StringBuffer buffer) => \n'
      '    buffer.write(\'${e.name}\.\${\$name}\');\n',
    );
  }

  @override
  int get priority => ObjectGeneratorPriority.stringify.index;
}

class ToDartStringUnionGenerator implements UnionGenerator {
  const ToDartStringUnionGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    buffer.write(
      '\n'
      '  String toDartString() {\n'
      '    final buffer = StringBuffer();\n'
      '    buildDartString(buffer);\n'
      '    return buffer.toString();\n'
      '  }\n'
      '\n'
      '  void buildDartString(StringBuffer buffer) {\n'
      '    buffer.write(\'${u.name}.\');\n'
      '    switch (${u.activeElementFieldName}) {\n',
    );

    for (final field in u.fields) {
      if (field.canUseParameterlessConstructor) {
        buffer.write(
          '      case ${u.activeElementClassName}.${field.name}:\n'
          '        buffer.write(\'${field.name}(${toDartString(field.type, field.name)})\');\n'
          '        break;\n',
        );
      } else {
        buffer.write(
          '      case ${u.activeElementClassName}.${field.name}:\n'
          '        buffer.write(\'${field.name}(${toDartString(field.type, field.name)})\');\n'
          '        break;\n',
        );
      }
    }

    buffer.write(
      '    }\n'
      '  }\n',
    );
  }

  @override
  int get priority => ObjectGeneratorPriority.stringify.index;
}

String toDartString(DataType type, String variableName) {
  switch (type.kind) {
    case DataTypeKind.optionalType:
      return toDartString(type.optionalType, variableName);
    case DataTypeKind.boolType:
    case DataTypeKind.int8Type:
    case DataTypeKind.int32Type:
    case DataTypeKind.int64Type:
    case DataTypeKind.uint8Type:
    case DataTypeKind.uint32Type:
    case DataTypeKind.uint64Type:
    case DataTypeKind.floatType:
    case DataTypeKind.doubleType:
      if (variableName.startsWith('\$')) {
        return '\${$variableName}';
      } else {
        return '\$$variableName';
      }
    case DataTypeKind.stringType:
      return '\${$variableName.dartEscapedString}';
    case DataTypeKind.bytesType:
      throw UnimplementedError('Not yet implemented for $type');
    case DataTypeKind.listType:
      final converter = toDartString(type.listType, 'e');
      return '[\${$variableName.map((e) => \'$converter\').join(\',\')}]';
    case DataTypeKind.setType:
      final converter = toDartString(type.setType, 'e');
      return '{\${$variableName.map((e) => \'$converter\').join(\',\')}}';
    case DataTypeKind.mapType:
      final keyConverter = toDartString(type.mapType.keyType, 'k');
      final valueConverter = toDartString(type.mapType.valueType, 'v');
      return '\${$variableName.map((k, v) => MapEntry(\'$keyConverter\', \'$valueConverter\'))}';
    case DataTypeKind.objectType:
      return '\${$variableName.toDartString()}';
  }
}
