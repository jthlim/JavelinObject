import '../compiler_context.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';

class ClassDocumentationGenerator implements ClassGenerator {
  const ClassDocumentationGenerator();

  @override
  int get priority => ObjectGeneratorPriority.documentation.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    buffer.write('\n');
    for (final commentLine in c.documentationComments) {
      buffer.write('///$commentLine');
    }
  }
}
