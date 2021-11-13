import '../compiler_context.dart';
import '../dart/dart_module_extension.dart';
import '../generator.dart';
import '../generator_priority/module_generator_priority.dart';
import '../module.dart';

class ModuleRegisterGenerator implements ModuleGenerator {
  const ModuleRegisterGenerator();

  @override
  int get priority => ModuleGeneratorPriority.register.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Module module) {
    final registration = module.dartRegistration;
    final of =
        registration.isEmpty ? '' : '\n  final of = JoObjectFactory();\n';
    buffer.write(
      '\n'
      'void joRegister() {'
      '$of'
      '${registration.join('')}'
      '}\n',
    );
  }
}
