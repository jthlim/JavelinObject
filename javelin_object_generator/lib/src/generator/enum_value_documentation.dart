import '../compiler_context.dart';
import '../generator.dart';
import '../generator_priority/field_generator_priority.dart';
import '../module.dart';

class EnumValueDocumentationGenerator implements EnumValueGenerator {
  const EnumValueDocumentationGenerator();

  @override
  int get priority => FieldGeneratorPriority.documentation.index;

  @override
  void generate(
    CompilerContext context,
    StringBuffer buffer,
    Enum e,
    EnumValue v,
  ) {
    if (v.documentationComments.isNotEmpty) {
      buffer.write('\n');
      for (final commentLine in v.documentationComments) {
        buffer.write('  ///$commentLine');
      }
    }
  }
}
