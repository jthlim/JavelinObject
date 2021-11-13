import '../compiler_context.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';

class UnionClosureGenerator implements UnionGenerator {
  const UnionClosureGenerator();

  @override
  int get priority => ObjectGeneratorPriority.classClosure.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    buffer.write('}\n');
  }
}
