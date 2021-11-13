import '../compiler_context.dart';
import '../generator.dart';
import '../generator_priority/module_generator_priority.dart';
import '../module.dart';

class ModuleClassGenerator implements ModuleGenerator {
  const ModuleClassGenerator();

  @override
  int get priority => ModuleGeneratorPriority.classes.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Module module) {
    for (final c in module.classes) {
      context.generateClass(buffer, c);
    }
  }
}
