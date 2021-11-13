import '../compiler_context.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';

class EnumClosureGenerator implements EnumGenerator {
  const EnumClosureGenerator();

  @override
  int get priority => ObjectGeneratorPriority.classClosure.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Enum e) {
    buffer.write('}\n');
  }
}
