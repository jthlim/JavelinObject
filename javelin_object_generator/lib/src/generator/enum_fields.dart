import '../compiler_context.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';

class EnumFieldsGenerator implements EnumGenerator {
  const EnumFieldsGenerator();

  @override
  int get priority => ObjectGeneratorPriority.fields.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Enum e) {
    buffer.write(
      '\n'
      '  final int \$id;\n'
      '  final String \$name;\n',
    );
    for (final field in e.fields) {
      context.generateField(buffer, e, field);
    }
  }
}
