import '../compiler_context.dart';
import '../generator.dart';
import '../generator_priority/module_generator_priority.dart';
import '../module.dart';

class ModuleUnionGenerator implements ModuleGenerator {
  const ModuleUnionGenerator();

  @override
  int get priority => ModuleGeneratorPriority.unions.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Module module) {
    for (final u in module.unions) {
      context.generateUnion(buffer, u);
    }
  }
}
