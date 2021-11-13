import '../compiler_context.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';

class EnumDocumentationGenerator implements EnumGenerator {
  const EnumDocumentationGenerator();

  @override
  int get priority => ObjectGeneratorPriority.documentation.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Enum e) {
    buffer.write('\n');
    for (final commentLine in e.documentationComments) {
      buffer.write('///$commentLine');
    }
  }
}
