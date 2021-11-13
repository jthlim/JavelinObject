import '../compiler_context.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';

class ClassClosureGenerator implements ClassGenerator {
  const ClassClosureGenerator();

  @override
  int get priority => ObjectGeneratorPriority.classClosure.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    buffer.write('}\n');
  }
}
