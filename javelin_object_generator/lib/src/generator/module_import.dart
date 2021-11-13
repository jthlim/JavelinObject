import 'package:javelin_object/jo_internal.dart';

import '../compiler_context.dart';
import '../generator.dart';
import '../generator_priority/module_generator_priority.dart';
import '../module.dart';

class ModuleImportGenerator implements ModuleGenerator {
  const ModuleImportGenerator();

  @override
  int get priority => ModuleGeneratorPriority.imports.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Module module) {
    buffer.write(
      'import \'package:javelin_object/jo_internal.dart\';\n',
    );

    if (module.imports.isNotEmpty) {
      buffer.write('\n');

      final imports = module.imports.map((m) => '${m.filename}.dart');

      for (final import in imports) {
        buffer.write('import ${import.dartEscapedString};\n');
      }
    }
  }
}
