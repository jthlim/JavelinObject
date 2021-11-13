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

class FromMapFactoryClassGenerator implements ClassGenerator {
  const FromMapFactoryClassGenerator({
    required this.module,
    required this.validateFields,
  });

  final Module module;
  final bool validateFields;

  static void processFromMapConvertAnnotation(
    CompilerContext context,
    Module module,
    Class c,
    ConvertClass annotation,
  ) {
    context.addClassGenerator(
      FromMapFactoryClassGenerator(
        module: module,
        validateFields: annotation.validateFromMap,
      ),
      c: c,
    );

    if (c.fields.isNotEmpty) {
      context.addClassGenerator(
        const FromMapFactoryHelperClassGenerator(),
        c: c,
      );
    }
  }

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    if (c.isVirtual && !c.isAbstract) {
      final typeName = c.typeName;
      final registration = module.dartRegistration;

      for (final cls in c.classAndSuperclasses) {
        if (cls.isVirtual) {
          registration.add(
            '  of.registerJoMapFactory<${cls.name}>(\n'
            '    ${typeName.dartEscapedString},\n'
            '    (map) => ${c.name}.fromMap(map),\n'
            '  );\n',
          );
        }
      }
    }

    final protected = c.isAbstract && !c.isVirtual ? '  @protected\n' : '';
    buffer.write(
      '\n'
      '$protected'
      '  ${c.name}.fromMap(Map<Object?, Object?> map)',
    );

    var isFirstTime = true;
    if (c.fields.isNotEmpty) {
      for (final field in c.fields) {
        if (isFirstTime) {
          isFirstTime = false;
          buffer.write('\n    : ');
        } else {
          buffer.write(',\n      ');
        }
        buffer.write('${field.storageName} = _${field.name}FromMap(map)');
      }
    }

    if (c.hasSuperclassMembers) {
      if (isFirstTime) {
        isFirstTime = false;
        buffer.write('\n    : super.fromMap(map)');
      } else {
        buffer.write(',\n      super.fromMap(map)');
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
      for (final currentClass in c.classAndSuperclasses) {
        for (final field in currentClass.fields) {
          allFieldNames.add(field.name);
          allFieldNames.addAll(field.aliases);
        }
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

class FromMapFactoryHelperClassGenerator implements ClassGenerator {
  const FromMapFactoryHelperClassGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    buffer.write('\n');
    for (final field in c.fields) {
      final aliases = field.aliases;
      final aliasesParameter = aliases.isEmpty
          ? ''
          : ', aliases: const [${aliases.map((e) => e.dartEscapedString).join(', ')}]';
      final converter = field.type.nonOptional
          .mapToObjectConverter(variableName: 'lookup', checkTypes: false);

      if (field.type.isOptional) {
        if (converter == 'lookup') {
          buffer.write(
            '  static ${field.type.dartType} _${field.name}FromMap(Map<Object?, Object?> map) =>\n'
            '    map.joLookupValue<${field.type.dartMapType}>'
            /*   */ '(fieldName: ${field.name.dartEscapedString}$aliasesParameter);\n',
          );
        } else {
          buffer.write(
            '  static ${field.type.dartType} _${field.name}FromMap(Map<Object?, Object?> map) {\n'
            '    final lookup = map.joLookupValue<${field.type.dartMapType}>'
            /*   */ '(fieldName: ${field.name.dartEscapedString}$aliasesParameter);\n'
            '    if (lookup == null) return null;\n'
            '    return $converter;\n'
            '  }\n',
          );
        }
      } else if (field.defaultValue != null) {
        final defaultValueString = field.defaultValue!.valueString;
        if (converter == 'lookup') {
          buffer.write(
            '  static ${field.type.dartType} _${field.name}FromMap(Map<Object?, Object?> map) =>\n'
            '    map.joLookupValue<${field.type.dartMapType}?>'
            /*   */ '(fieldName: ${field.name.dartEscapedString}$aliasesParameter) '
            /*   */ '?? $defaultValueString;\n',
          );
        } else {
          final converterSuffix = field.type.canReturnNull ? '!' : '';
          buffer.write(
            '  static ${field.type.dartType} _${field.name}FromMap(Map<Object?, Object?> map) {\n'
            '    final lookup = map.joLookupValue<${field.type.dartMapType}?>'
            /*   */ '(fieldName: ${field.name.dartEscapedString}$aliasesParameter);\n'
            '    if (lookup == null) return $defaultValueString;\n'
            '    return $converter$converterSuffix;\n'
            '  }\n',
          );
        }
      } else {
        final converterSuffix = field.type.canReturnNull ? '!' : '';
        if (converter == 'lookup') {
          buffer.write(
            '  static ${field.type.dartType} _${field.name}FromMap(Map<Object?, Object?> map) =>\n'
            '    map.joLookupValue<${field.type.dartMapType}>'
            /*   */ '(fieldName: ${field.name.dartEscapedString}$aliasesParameter)$converterSuffix;\n',
          );
        } else {
          buffer.write(
            '  static ${field.type.dartType} _${field.name}FromMap(Map<Object?, Object?> map) {\n'
            '    final lookup = map.joLookupValue<${field.type.dartMapType}>'
            /*   */ '(fieldName: ${field.name.dartEscapedString}$aliasesParameter);\n'
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

class JoTypeClassGenerator implements ClassGenerator {
  const JoTypeClassGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    if (!c.hasVirtualFactory) return;

    if (c.isAbstract) {
      buffer.write(
        '\n'
        '  String get \$joType;\n',
      );
    } else {
      buffer.write(
        '\n'
        '  String get \$joType => ${c.typeName.dartEscapedString};\n',
      );
    }
  }

  @override
  int get priority => ObjectGeneratorPriority.accessors.index;
}

class ToMapClassGenerator implements ClassGenerator {
  const ToMapClassGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    buffer.write('\n');
    if (c.fields.isEmpty) {
      if (c.baseClass == null) {
        buffer.write('  Map<String, Object?> toMap() => const {};\n');
      }
      return;
    }

    if (c.isExtendable || c.hasSuperclass) {
      buffer.write(
        '  Map<String, Object?> toMap([bool \$includeType=${c.isVirtual}]) {\n',
      );
    } else {
      buffer.write('  Map<String, Object?> toMap() {\n');
    }

    for (final field in c.fields) {
      buffer.write(
        '    final \$${field.name} = ${field.storageName};\n',
      );
    }

    if (c.hasSuperclassMembers) {
      if (c.isExtendable) {
        buffer.write(
          '\n'
          '    final \$\$result = super.toMap(\$includeType);\n',
        );
      } else {
        buffer.write(
          '\n'
          '    final \$\$result = super.toMap();\n',
        );
      }

      for (final field in c.fields) {
        buffer.write('    ');
        if (field.type.isOptional) {
          buffer.write('if (\$${field.name} != null) ');
        }
        buffer.write('\$\$result[\'${field.name}\'] = ');

        final nonOptionalType = field.type.nonOptional;
        final objectConverter =
            nonOptionalType.objectToMapConverter('\$${field.name}');
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
          '      if (\$includeType) \'\\\$t\': \$joType,\n',
        );
      }

      for (final field in c.fields) {
        if (field.type.isOptional) {
          buffer.write(
            '      if (\$${field.name} != null)\n'
            '  ',
          );
        }
        buffer.write('      \'${field.name}\': ');

        final nonOptionalType = field.type.nonOptional;
        final objectConverter =
            nonOptionalType.objectToMapConverter('\$${field.name}');
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

class FromMapFactoryUnionGenerator implements UnionGenerator {
  const FromMapFactoryUnionGenerator({this.validateFields = false});

  final bool validateFields;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    buffer.write(
      '\n'
      '  static ${u.name}? fromMapOrNull(Map<Object?, Object?> map) {\n',
    );

    if (validateFields) {
      buffer.write('    map.validateKeys(validKeys: const {\n');

      final allFieldNames = <String>{};
      for (final field in u.fields) {
        allFieldNames.add(field.name);
        allFieldNames.addAll(field.aliases);
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
      for (final fieldName in [field.name, ...field.aliases]) {
        buffer.write('      case ${fieldName.dartEscapedString}:\n');
      }
      buffer.write('        return _${field.name}FromValue(entry.value);\n');
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

class FromMapFactoryHelperUnionGenerator implements UnionGenerator {
  const FromMapFactoryHelperUnionGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    buffer.write('\n');
    for (final field in u.fields) {
      final nonOptionalFieldType = field.type;
      final object = nonOptionalFieldType.objectTypeOrNull?.resolvedObject;
      final isOptionalReturnType = object is Enum || object is Union;

      if (isOptionalReturnType) {
        if (object is Enum) {
          buffer.write(
            '  static ${u.name}? _${field.name}FromValue(Object? value) {\n'
            '    if (value is! String) return null;\n'
            '    final enumValue = ${object.name}.fromStringOrNull(value);\n'
            '    if (enumValue == null) return null;\n'
            '    return ${u.name}.${field.name}(enumValue);\n'
            '   }\n',
          );
        } else if (object is Union) {
          if (field.canUseParameterlessConstructor) {
            buffer.write(
              '  static ${u.name}? _${field.name}FromValue(Object? value) => {\n'
              '    if (value == null) return null;\n'
              '    return ${u.name}.${field.name}();\n',
            );
          } else {
            buffer.write(
              '  static ${u.name}? _${field.name}FromValue(Object? value) {\n'
              '    if (value is! Map) return null;\n'
              '    final unionValue = ${object.name}.fromMapOrNull(value);\n'
              '    if (unionValue == null) return null;\n'
              '    return ${u.name}.${field.name}(unionValue);\n'
              '   }\n',
            );
          }
        }
      } else {
        if (field.canUseParameterlessConstructor) {
          if (u.isImmutable) {
            buffer.write(
                '  static ${u.name} _${field.name}FromValue(Object? value) =>\n'
                '    const ${u.name}.${field.name}();\n');
          } else {
            buffer.write(
                '  static ${u.name} _${field.name}FromValue(Object? value) =>\n'
                '    ${u.name}.${field.name}();\n');
          }
        } else {
          final converter = field.type.mapToObjectConverter(
            variableName: 'value',
            checkTypes: true,
          );

          buffer.write(
            '  static ${u.name} _${field.name}FromValue(Object? value) =>\n'
            '    ${u.name}.${field.name}($converter);\n',
          );
        }
      }
    }
  }

  @override
  int get priority => ObjectGeneratorPriority.convertFactoryHelper.index;
}

class ToMapUnionGenerator implements UnionGenerator {
  const ToMapUnionGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    if (u.isInline) {
      throw FormatException(
        'toMap cannot be generated for inline union ${u.name}',
      );
    }

    buffer.write(
      '\n'
      '  Map<String, Object?> toMap() {\n'
      '    switch (${u.activeElementFieldName}) {\n',
    );
    for (final field in u.fields) {
      final variableName = '\$${field.name}';

      final objectConverter = field.type.objectToMapConverter(variableName);

      buffer.write(
        '      case ${u.activeElementClassName}.${field.name}:\n'
        '        final $variableName = _value as ${field.type.dartType};\n'
        '        return { ${field.name.dartEscapedString}: $objectConverter };\n',
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
