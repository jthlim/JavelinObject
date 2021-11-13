import '../../compiler_context.dart';
import '../../generator.dart';
import '../../generator_priority/object_generator_priority.dart';
import '../../module.dart';

class FromIdEnumGenerator implements EnumGenerator {
  const FromIdEnumGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Enum e) {
    buffer.write(
      '\n'
      '  factory ${e.name}.fromId(int id) =>\n'
      '    fromIdOrNull(id)!;\n'
      '\n'
      '  static ${e.name}? fromIdOrNull(int id) {\n'
      '    switch(id) {\n',
    );

    for (final value in e.values) {
      buffer.write(
        '    case ${value.id}:\n'
        '      return ${value.name};\n',
      );
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
