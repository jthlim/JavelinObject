import '../compiler_context.dart';
import '../generator.dart';
import '../generator_priority/module_generator_priority.dart';
import '../module.dart';

class ModuleEnumGenerator implements ModuleGenerator {
  const ModuleEnumGenerator();

  @override
  int get priority => ModuleGeneratorPriority.enums.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Module module) {
    for (final e in module.enums) {
      context.generateEnum(buffer, e);
    }
  }
}
