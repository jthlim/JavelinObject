import '../compiler_context.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';

class UnionDocumentationGenerator implements UnionGenerator {
  const UnionDocumentationGenerator();

  @override
  int get priority => ObjectGeneratorPriority.documentation.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    buffer.write('\n');
    for (final commentLine in u.documentationComments) {
      buffer.write('///$commentLine');
    }
  }
}
