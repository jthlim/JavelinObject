import '../annotation/annotation_module_extension.dart';
import '../compiler_context.dart';
import '../dart/data_type_format_extension.dart';
import '../data_type.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';

class UnionAccessorsGenerator implements UnionGenerator {
  const UnionAccessorsGenerator();

  @override
  int get priority => ObjectGeneratorPriority.accessors.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    for (final field in u.fields) {
      if (field.type.isOptional) {
        buffer.write(
          '\n'
          '  ${field.type.dartType} get ${field.name} {\n'
          '    if (${u.activeElementFieldName} != ${u.activeElementClassName}.${field.name}) {\n'
          '      throw StateError(\'${field.name} is not the active element\');\n'
          '    }\n'
          '    return _value as ${field.type.dartType};\n'
          '  }\n'
          '\n'
          '  ${field.type.dartType} get ${field.name}OrNull =>\n'
          '    ${u.activeElementFieldName} == ${u.activeElementClassName}.${field.name}\n'
          '      ? _value as ${field.type.dartType}\n'
          '      : null;\n',
        );
      } else {
        buffer.write(
          '\n'
          '  ${field.type.dartType} get ${field.name} => ${field.name}OrNull!;\n'
          '  ${field.type.dartType}? get ${field.name}OrNull =>\n'
          '    ${u.activeElementFieldName} == ${u.activeElementClassName}.${field.name}\n'
          '      ? _value as ${field.type.dartType}\n'
          '      : null;\n',
        );
      }

      if (u.isImmutable) continue;

      buffer.write(
        '  set ${field.name}(${field.type.dartType} value) {\n'
        '    ${u.activeElementFieldName} = ${u.activeElementClassName}.${field.name};\n'
        '    _value = value;\n'
        '  }\n',
      );
    }
  }
}
