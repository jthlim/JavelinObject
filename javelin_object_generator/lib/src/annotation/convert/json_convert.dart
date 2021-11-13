// JSON maps are different from the general toMap/fromMap for the following
// reasons:
//
// * JSON maps do not support non-string keys.
// * JSON maps cannot serialize or deserialize sets.
//
// For these reasons, JSON maps have their own fromMap() implementation.
// Sets are converted to arrays, and maps that have non-string keys use
// arrays of 2N objects instead.

import 'package:javelin_object/jo_internal.dart';

import '../../compiler_context.dart';
import '../../dart/dart_module_extension.dart';
import '../../dart/dart_value_extension.dart';
import '../../dart/data_type_format_extension.dart';
import '../../data_type.dart';
import '../../generator.dart';
import '../../generator_priority/object_generator_priority.dart';
import '../../module.dart';
import '../annotation_module_extension.dart';
import '../annotations.jo.dart';

class FromJsonFactoryClassGenerator implements ClassGenerator {
  FromJsonFactoryClassGenerator({
    required this.module,
    required this.validateFields,
  });

  final Module module;
  final bool validateFields;

  static void processFromJsonConvertAnnotation(
    CompilerContext context,
    Module module,
    Class c,
    ConvertClass annotation,
  ) {
    context.addClassGenerator(
      FromJsonFactoryClassGenerator(
        module: module,
        validateFields: annotation.validateFromJson,
      ),
      c: c,
    );
    context.addClassGenerator(
      const FromJsonFactoryHelperClassGenerator(),
      c: c,
    );
  }

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    if (c.isVirtual && !c.isAbstract) {
      final typeName = c.jsonTypeName;
      final registration = module.dartRegistration;

      for (final cls in c.classAndSuperclasses) {
        if (cls.isVirtual) {
          registration.add(
            '  of.registerJsonFactory<${cls.name}>(\n'
            '    ${typeName.dartEscapedString},\n'
            '    (map) => ${c.name}.fromJsonMap(map),\n'
            '  );\n',
          );
        }
      }
    }

    if (c.isVirtual) {
      if (c.isAbstract) {
        buffer.write(
          '\n'
          '  factory ${c.name}.fromJson(String json) {\n'
          '    final jsonMap = jsonDecode(json);\n'
          '    return JoObjectFactory().createFromJsonMap(jsonMap)!;\n'
          '  }\n'
          '\n'
          '  ${c.name}.fromJsonMap(Map<String, Object?> map)',
        );
      } else {
        buffer.write(
          '\n'
          '  factory ${c.name}.fromJson(String json) {\n'
          '    final jsonMap = jsonDecode(json);\n'
          '    return JoObjectFactory().createFromJsonMap(jsonMap) ??\n'
          '        ${c.name}.fromJsonMap(jsonMap);\n'
          '  }\n'
          '\n'
          '  ${c.name}.fromJsonMap(Map<String, Object?> map)',
        );
      }
    } else if (c.isAbstract) {
      buffer.write(
        '\n'
        '  @abstract\n'
        '  ${c.name}.fromJsonMap(Map<String, Object?> map)',
      );
    } else {
      buffer.write(
        '\n'
        '  factory ${c.name}.fromJson(String json) => ${c.name}.fromJsonMap(jsonDecode(json));\n'
        '\n'
        '  ${c.name}.fromJsonMap(Map<String, Object?> map)',
      );
    }

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
          '${field.storageName} = _${field.name}FromJsonMap(map)',
        );
      }
    }

    if (c.hasSuperclassMembers) {
      if (isFirstTime) {
        isFirstTime = false;
        buffer.write('\n    : super.fromJsonMap(map)');
      } else {
        buffer.write(',\n      super.fromJsonMap(map)');
      }
    }

    if (!validateFields) {
      buffer.write(';\n');
    } else {
      buffer.write(
        '  {\n'
        '    map.validateKeys(validKeys: const {\n',
      );

      final allFieldNames = <String>{};
      for (final field in c.fields) {
        allFieldNames.addAll(field.jsonAliases);
      }
      for (final fieldName in allFieldNames) {
        buffer.write('      \'$fieldName\',\n');
      }
      buffer.write(
        '    });\n'
        '  }\n',
      );
    }
  }

  @override
  int get priority => ObjectGeneratorPriority.convertFactory.index;
}

class FromJsonFactoryHelperClassGenerator implements ClassGenerator {
  const FromJsonFactoryHelperClassGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    buffer.write('\n');
    for (final field in c.fields) {
      final aliases = field.jsonAliases;
      final aliasesParameter = aliases.length == 1
          ? ''
          : ', aliases: const [${aliases.take(1).map((e) => e.dartEscapedString).join(', ')}]';
      final converter = field.type.nonOptional
          .jsonMapToObjectConverter(variableName: 'lookup', checkTypes: false);

      if (field.type.isOptional) {
        if (converter == 'lookup') {
          buffer.write(
            '  static ${field.type.dartType} _${field.name}FromJsonMap(Map<Object?, Object?> map) =>\n'
            '    map.joLookupValue<${field.type.jsonMapType}>'
            /*   */ '(fieldName: ${aliases.first.dartEscapedString}$aliasesParameter);\n',
          );
        } else {
          buffer.write(
            '  static ${field.type.dartType} _${field.name}FromJsonMap(Map<Object?, Object?> map) {\n'
            '    final lookup = map.joLookupValue<${field.type.jsonMapType}>'
            /*   */ '(fieldName: ${aliases.first.dartEscapedString}$aliasesParameter);\n'
            '    if (lookup == null) return null;\n'
            '    return $converter;\n'
            '  }\n',
          );
        }
      } else if (field.defaultValue != null) {
        final defaultValueString = field.defaultValue!.valueString;
        if (converter == 'lookup') {
          buffer.write(
            '  static ${field.type.dartType} _${field.name}FromJsonMap(Map<Object?, Object?> map) =>\n'
            '    map.joLookupValue<${field.type.jsonMapType}?>'
            /*   */ '(fieldName: ${aliases.first.dartEscapedString}$aliasesParameter) '
            /*   */ '?? $defaultValueString;\n',
          );
        } else {
          final converterSuffix = field.type.canReturnNull ? '!' : '';
          buffer.write(
            '  static ${field.type.dartType} _${field.name}FromJsonMap(Map<Object?, Object?> map) {\n'
            '    final lookup = map.joLookupValue<${field.type.jsonMapType}?>'
            /*   */ '(fieldName: ${aliases.first.dartEscapedString}$aliasesParameter);\n'
            '    if (lookup == null) return $defaultValueString;\n'
            '    return $converter$converterSuffix;\n'
            '  }\n',
          );
        }
      } else {
        final converterSuffix = field.type.canReturnNull ? '!' : '';
        if (converter == 'lookup') {
          buffer.write(
            '  static ${field.type.dartType} _${field.name}FromJsonMap(Map<Object?, Object?> map) =>\n'
            '    map.joLookupValue<${field.type.dartMapType}>'
            /*   */ '(fieldName: ${aliases.first.dartEscapedString}$aliasesParameter)$converterSuffix;\n',
          );
        } else {
          buffer.write(
            '  static ${field.type.dartType} _${field.name}FromJsonMap(Map<Object?, Object?> map) {\n'
            '    final lookup = map.joLookupValue<${field.type.jsonMapType}>'
            /*   */ '(fieldName: ${aliases.first.dartEscapedString}$aliasesParameter);\n'
            '    return $converter$converterSuffix;\n'
            '  }\n',
          );
        }
      }
    }
  }

  @override
  int get priority => ObjectGeneratorPriority.convertFactoryHelper.index;
}

class JsonTypeClassGenerator implements ClassGenerator {
  const JsonTypeClassGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    if (!c.hasVirtualFactory) return;

    if (c.isAbstract) {
      buffer.write(
        '\n'
        '  String get \$jsonType;\n',
      );
    } else {
      buffer.write(
        '\n'
        '  String get \$jsonType => ${c.jsonTypeName.dartEscapedString};\n',
      );
    }
  }

  @override
  int get priority => ObjectGeneratorPriority.accessors.index;
}

class ToJsonClassGenerator implements ClassGenerator {
  const ToJsonClassGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    buffer.write(
      '\n'
      '  String toJson({bool pretty = false}) {\n'
      '    final encoder = pretty\n'
      '      ? const JsonEncoder.withIndent(\'  \')\n'
      '      : const JsonEncoder();\n'
      '    return encoder.convert(toJsonMap());\n'
      '  }\n'
      '\n',
    );

    if (c.isExtendable || c.hasSuperclass) {
      buffer.write(
        '  Map<String, Object?> toJsonMap([bool \$includeType=${c.isVirtual}]) {\n',
      );
    } else {
      buffer.write(
        '  Map<String, Object?> toJsonMap() {\n',
      );
    }

    for (final field in c.fields) {
      buffer.write('    final \$${field.name} = ${field.storageName};\n');
    }

    if (c.hasSuperclassMembers) {
      if (c.isExtendable) {
        buffer.write(
          '\n'
          '    final \$\$result = super.toJsonMap(\$includeType);\n',
        );
      } else {
        buffer.write(
          '\n'
          '    final \$\$result = super.toJsonMap();\n',
        );
      }

      for (final field in c.fields) {
        buffer.write('    ');
        if (field.type.isOptional) {
          buffer.write('if (\$${field.name} != null) ');
        }
        buffer.write(
            '\$\$result[${field.jsonAliases.first.dartEscapedString}] = ');

        final nonOptionalType = field.type.nonOptional;
        final objectConverter =
            nonOptionalType.objectToJsonMapConverter('\$${field.name}');
        buffer.write('$objectConverter;\n');
      }

      buffer.write(
        '    return \$\$result;\n'
        '  }\n',
      );
    } else {
      buffer.write(
        '\n'
        '    return {\n',
      );

      if (c.isVirtual &&
          (c.baseClass == null ||
              !c.baseClass!.resolvedClass.hasVirtualFactory)) {
        buffer.write(
          '      if (\$includeType) \'\\\$t\': \$jsonType,\n',
        );
      }

      for (final field in c.fields) {
        if (field.type.isOptional) {
          buffer.write(
            '      if (\$${field.name} != null)\n'
            '  ',
          );
        }
        buffer.write('      ${field.jsonAliases.first.dartEscapedString}: ');

        final nonOptionalType = field.type.nonOptional;
        final objectConverter =
            nonOptionalType.objectToJsonMapConverter('\$${field.name}');
        buffer.write('$objectConverter,\n');
      }
      buffer.write(
        '    };\n'
        '  }\n',
      );
    }
  }

  @override
  int get priority => ObjectGeneratorPriority.converter.index;
}

class FromJsonEnumGenerator implements EnumGenerator {
  const FromJsonEnumGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Enum e) {
    buffer.write(
      '\n'
      '  factory ${e.name}.fromJsonString(String s) =>\n'
      '    fromJsonStringOrNull(s)!;\n'
      '\n'
      '  static ${e.name}? fromJsonStringOrNull(String s) {\n'
      '    switch(s) {\n',
    );

    for (final value in e.values) {
      for (final alias in value.jsonAliases) {
        buffer.write('    case ${alias.dartEscapedString}:\n');
      }
      buffer.write('      return ${value.name};\n');
    }

    buffer.write(
      '    }\n'
      '    return null;\n'
      '  }\n',
    );
  }

  @override
  int get priority => ObjectGeneratorPriority.convertFactory.index;
}

class ToJsonEnumGenerator implements EnumGenerator {
  const ToJsonEnumGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Enum e) {
    buffer.write(
      '\n'
      '  String toJsonString() {\n'
      '    switch(this) {\n',
    );

    for (final value in e.values) {
      buffer.write('    case ${value.name}:\n');
      buffer.write(
        '      return${value.jsonAliases.first.dartEscapedString};\n',
      );
    }

    buffer.write(
      '    }\n'
      '    throw StateError(\'Unexpected enum value \$this\');\n'
      '  }\n',
    );
  }

  @override
  int get priority => ObjectGeneratorPriority.converter.index;
}

class FromJsonFactoryUnionGenerator implements UnionGenerator {
  const FromJsonFactoryUnionGenerator({this.validateFields = false});

  final bool validateFields;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    if (u.isInline) {
      _generateInline(context, buffer, u);
    } else {
      _generateNonInline(context, buffer, u);
    }
  }

  void _generateNonInline(
    CompilerContext context,
    StringBuffer buffer,
    Union u,
  ) {
    buffer.write(
      '\n'
      '  factory ${u.name}.fromJson(String json) => ${u.name}.fromJsonMapOrNull(jsonDecode(json))!;\n'
      '\n'
      '  static ${u.name}? fromJsonMapOrNull(Map<String, Object?> map) {\n',
    );

    if (validateFields) {
      buffer.write('    map.validateKeys(validKeys: const {\n');

      final allFieldNames = <String>{};
      for (final field in u.fields) {
        allFieldNames.addAll(field.jsonAliases);
      }
      for (final fieldName in allFieldNames) {
        buffer.write('      \'$fieldName\',\n');
      }
      buffer.write('    });\n');
    }

    buffer.write(
      '    final entries = map.entries;\n'
      '    if (entries.length != 1) return null;\n'
      '    final entry = entries.first;\n'
      '    switch (entry.key) {\n',
    );
    for (final field in u.fields) {
      for (final fieldName in field.jsonAliases) {
        buffer.write('      case ${fieldName.dartEscapedString}:\n');
      }
      buffer.write(
        '        return _${field.name}FromJsonValue(entry.value);\n',
      );
    }

    buffer.write(
      '      default:\n'
      '        return null;\n'
      '    }\n'
      '  }\n',
    );
  }

  void _generateInline(CompilerContext context, StringBuffer buffer, Union u) {
    final jsonTypes = <_JsonType, Field>{};

    buffer.write(
      '  factory ${u.name}.fromJsonObject(Object object) => fromJsonObjectOrNull(object)!;\n'
      '\n'
      '  static ${u.name}? fromJsonObjectOrNull(Object? object) {\n',
    );

    for (final field in u.fields) {
      final jsonType = field.type.jsonType;
      if (jsonTypes.containsKey(jsonType)) {
        throw FormatException(
          'Inline union has fields ${field.name}, '
          '${jsonTypes[jsonType]!.name} with the same jsonType: $jsonType',
        );
      }
      jsonTypes[jsonType] = field;

      buffer.write(
        '    if (object is ${field.type.jsonMapType}) {'
        '      return ${u.name}.${field.name}'
        /*    */ '(${field.type.nonOptional.jsonMapToObjectConverter(variableName: 'object', checkTypes: false)});\n'
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

class FromJsonFactoryHelperUnionGenerator implements UnionGenerator {
  const FromJsonFactoryHelperUnionGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    // Not required for inline unions.
    if (u.isInline) return;

    buffer.write('\n');
    for (final field in u.fields) {
      final nonOptionalFieldType = field.type;
      final object = nonOptionalFieldType.objectTypeOrNull?.resolvedObject;
      final isOptionalReturnType = object is Enum || object is Union;

      if (isOptionalReturnType) {
        if (object is Enum) {
          final enumFactory =
              object.hasJsonAlias ? 'fromJsonStringOrNull' : 'fromStringOrNull';
          buffer.write(
            '  static ${u.name}? _${field.name}FromJsonValue(Object? value) {\n'
            '    if (value is! String) return null;\n'
            '    final enumValue = ${object.name}.$enumFactory(value);\n'
            '    if (enumValue == null) return null;\n'
            '    return ${u.name}.${field.name}(enumValue);\n'
            '   }\n',
          );
        } else if (object is Union) {
          buffer.write(
            '  static ${u.name}? _${field.name}FromJsonValue(Object? value) {\n'
            '    if (value is! Map<String, Object?>) return null;\n'
            '    final unionValue = ${object.name}.fromJsonMapOrNull(value);\n'
            '    if (unionValue == null) return null;\n'
            '    return ${u.name}.${field.name}(unionValue);\n'
            '   }\n',
          );
        }
      } else {
        final converter = field.type.jsonMapToObjectConverter(
          variableName: 'value',
          checkTypes: true,
        );

        buffer.write(
          '  static ${u.name} _${field.name}FromJsonValue(Object? value) =>\n'
          '    ${u.name}.${field.name}($converter);\n',
        );
      }
    }
  }

  @override
  int get priority => ObjectGeneratorPriority.convertFactoryHelper.index;
}

class ToJsonUnionGenerator implements UnionGenerator {
  const ToJsonUnionGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    if (u.isInline) {
      _generateInline(context, buffer, u);
    } else {
      _generateNonInline(context, buffer, u);
    }
  }

  void _generateNonInline(
    CompilerContext context,
    StringBuffer buffer,
    Union u,
  ) {
    buffer.write(
      '\n'
      '  String toJson({bool pretty = false}) {\n'
      '    final encoder = pretty\n'
      '      ? const JsonEncoder.withIndent(\'  \')\n'
      '      : const JsonEncoder();\n'
      '    return encoder.convert(toJsonMap());\n'
      '  }\n'
      '\n'
      '  Map<String, Object?> toJsonMap() {\n'
      '    switch (${u.activeElementFieldName}) {\n',
    );
    for (final field in u.fields) {
      final variableName = '\$${field.name}';
      final objectConverter = field.type.objectToJsonMapConverter(variableName);
      buffer.write(
        '      case ${u.activeElementClassName}.${field.name}:\n'
        '        final $variableName = _value as ${field.type.dartType};\n'
        '        return { ${field.jsonAliases.first.dartEscapedString}: $objectConverter };\n',
      );
    }
    buffer.write(
      '    }\n'
      '  }',
    );
  }

  void _generateInline(CompilerContext context, StringBuffer buffer, Union u) {
    buffer.write(
      '\n'
      '  String toJson({bool pretty = false}) {\n'
      '    final encoder = pretty\n'
      '      ? const JsonEncoder.withIndent(\'  \')\n'
      '      : const JsonEncoder();\n'
      '    return encoder.convert(toJsonObject());\n'
      '  }\n'
      '\n'
      '  Object toJsonObject() {\n'
      '    switch (${u.activeElementFieldName}) {\n',
    );
    var hasPlainObjects = false;
    for (final field in u.fields) {
      final variableName = '\$${field.name}';

      final nonOptionalType = field.type.nonOptional;
      final objectConverter =
          nonOptionalType.objectToJsonMapConverter(variableName);

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
          nonOptionalType.objectToJsonMapConverter(variableName);

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

extension JsonDataTypeFormatExtension on DataType {
  String get jsonMapType {
    switch (kind) {
      case DataTypeKind.optionalType:
        return '${optionalType.jsonMapType}?';
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
      case DataTypeKind.setType:
        return 'List';
      case DataTypeKind.mapType:
        // JSON only supports String key types. If the map has non-string keys,
        // it needs to be transformed from a map to a list of key/value pairs.
        if (mapType.keyType.kind != DataTypeKind.stringType) {
          return 'List';
        }
        return 'Map';

      case DataTypeKind.objectType:
        final resolvedObject = objectType.resolvedObject;
        if (resolvedObject is Class) {
          return 'Map';
        } else if (resolvedObject is Enum) {
          return 'String';
        } else if (resolvedObject is Union) {
          if (resolvedObject.isInline) {
            throw FormatException(
              'Inline union ${resolvedObject.name} cannot be used inside '
              'another inline union.',
            );
          }
          return 'Map';
        }
        throw UnimplementedError(
          'Unhandled object: ${resolvedObject.runtimeType}',
        );
    }
  }

  String objectToJsonMapConverter(String variableName) {
    switch (kind) {
      case DataTypeKind.optionalType:
        final converter = optionalType.objectToJsonMapConverter(variableName);
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
        final elementConverter = listType.objectToJsonMapConverter('e');
        if (elementConverter == 'e') return variableName;
        return '$variableName.map((e) => $elementConverter).toList()';
      case DataTypeKind.setType:
        final elementConverter = setType.objectToJsonMapConverter('e');
        if (elementConverter == 'e') return variableName;
        return '$variableName.map((e) => $elementConverter).toList()';
      case DataTypeKind.mapType:
        final map = mapType;
        final keyConverter = map.keyType.objectToJsonMapConverter('k');
        final valueConverter = map.valueType.objectToJsonMapConverter('v');

        // JSON only supports String key types. If the map has non-string keys,
        // it needs to be transformed from a map to a list of key/value pairs.

        if (map.keyType.kind != DataTypeKind.stringType) {
          if (keyConverter == 'k' && valueConverter == 'v') {
            return '$variableName.joMapForJson';
          }
          return '$variableName.map'
              '((k, v) => MapEntry($keyConverter, $valueConverter))'
              '.joMapForJson';
        }

        if (keyConverter == 'k' && valueConverter == 'v') return variableName;
        return '$variableName.map'
            '((k, v) => MapEntry($keyConverter, $valueConverter))';

      case DataTypeKind.objectType:
        final resolvedObject = objectType.resolvedObject;
        if (resolvedObject is Enum) {
          if (resolvedObject.hasJsonAlias) {
            return '$variableName.toJsonString()';
          } else {
            return '$variableName.\$name';
          }
        } else if (resolvedObject is Class) {
          if (resolvedObject.isExtendable) {
            return '$variableName.toJsonMap(${resolvedObject.isVirtual})';
          } else {
            return '$variableName.toJsonMap()';
          }
        } else if (resolvedObject is Union) {
          if (resolvedObject.isInline) {
            return '$variableName.toJsonObject()';
          } else {
            return '$variableName.toJsonMap()';
          }
        }
        throw UnimplementedError(
          'Internal error: ${resolvedObject.runtimeType} cannot be converted '
          'to a map',
        );
    }
  }

  String jsonMapToObjectConverter({
    required String variableName,
    required bool checkTypes,
  }) {
    switch (kind) {
      case DataTypeKind.optionalType:
        final converter = optionalType.jsonMapToObjectConverter(
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
        final elementConverter = listType.jsonMapToObjectConverter(
          variableName: 'e',
          checkTypes: true,
        );
        if (checkTypes) {
          return '($variableName as Iterable).joMapNotNull((e) => $elementConverter).toList()';
        } else {
          return '$variableName.joMapNotNull((e) => $elementConverter).toList()';
        }
      case DataTypeKind.setType:
        final elementConverter = setType.jsonMapToObjectConverter(
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
        final keyConverter = map.keyType.jsonMapToObjectConverter(
          variableName: 'k',
          checkTypes: true,
        );
        final valueConverter = map.valueType.jsonMapToObjectConverter(
          variableName: 'v',
          checkTypes: true,
        );

        // JSON only supports String key types. If the map has non-string keys,
        // it needs to be transformed from a map to a list of key/value pairs.

        if (map.keyType.kind != DataTypeKind.stringType) {
          return '$variableName.joMapFromJson.joMapNotNull((k) => $keyConverter, (v) => $valueConverter)';
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
          final enumFactory = resolvedObject.hasJsonAlias
              ? 'fromJsonStringOrNull'
              : 'fromStringOrNull';
          if (checkTypes) {
            return '${resolvedObject.name}.$enumFactory($variableName as String)';
          } else {
            return '${resolvedObject.name}.$enumFactory($variableName)';
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

        throw StateError('Unable to deserialize ${resolvedObject.runtimeType}');
    }
  }
}

enum _JsonType {
  boolean,
  string,
  number,
  object,
  array,
}

extension _DataTypeExtension on DataType {
  _JsonType get jsonType {
    final type = nonOptional;
    switch (type.kind) {
      case DataTypeKind.optionalType:
        throw StateError('Internal error');
      case DataTypeKind.boolType:
        return _JsonType.boolean;
      case DataTypeKind.int8Type:
      case DataTypeKind.int32Type:
      case DataTypeKind.int64Type:
      case DataTypeKind.uint8Type:
      case DataTypeKind.uint32Type:
      case DataTypeKind.uint64Type:
      case DataTypeKind.floatType:
      case DataTypeKind.doubleType:
        return _JsonType.number;
      case DataTypeKind.stringType:
      case DataTypeKind.bytesType:
        return _JsonType.string;
      case DataTypeKind.listType:
      case DataTypeKind.setType:
        return _JsonType.array;
      case DataTypeKind.mapType:
        return _JsonType.object;
      case DataTypeKind.objectType:
        final resolvedObject = objectType.resolvedObject;
        if (resolvedObject is Class) {
          return _JsonType.object;
        } else if (resolvedObject is Enum) {
          return _JsonType.string;
        } else if (resolvedObject is Union) {
          if (resolvedObject.isInline) {
            throw FormatException(
              'Inline union ${resolvedObject.name} cannot be used inside '
              'another inline union.',
            );
          }
          return _JsonType.object;
        }
        throw UnimplementedError('Unhandled datatype: ${type.runtimeType}');
    }
  }
}
