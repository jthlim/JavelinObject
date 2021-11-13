import '../compiler_context.dart';
import '../generator.dart';
import '../generator_priority/field_generator_priority.dart';
import '../module.dart';

class FieldDocumentationGenerator implements FieldGenerator {
  const FieldDocumentationGenerator();

  @override
  int get priority => FieldGeneratorPriority.documentation.index;

  @override
  void generate(
    CompilerContext context,
    StringBuffer buffer,
    ObjectBase object,
    Field field,
  ) {
    if (field.documentationComments.isNotEmpty) {
      buffer.write('\n');
      for (final commentLine in field.documentationComments) {
        buffer.write('  ///$commentLine');
      }
    }
  }
}
