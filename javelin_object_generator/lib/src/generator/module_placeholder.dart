import '../compiler_context.dart';
import '../dart/dart_identifier_string_extension.dart';
import '../dart/dart_module_extension.dart';
import '../generator.dart';
import '../generator_priority/module_generator_priority.dart';
import '../module.dart';

class ModulePlaceholderGenerator implements ModuleGenerator {
  const ModulePlaceholderGenerator();

  @override
  int get priority => ModuleGeneratorPriority.placeholderHelper.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Module module) {
    final placeholderImplements = module.dartPlaceholderImplements;

    if (placeholderImplements.isEmpty) return;

    buffer.write(
      '\n'
      'class _Placeholder {\n'
      '  const _Placeholder();\n'
      '  void noSuchMethod(Invocation invocation) {}\n'
      '  String toString({bool pretty = true}) => \'\';\n'
      '}\n',
    );

    for (final implements in placeholderImplements.where((e) => e.isNotEmpty)) {
      final identifier = '_Placeholder\$${implements.dartIdentifier}';
      buffer.write(
        '\n'
        'class $identifier extends _Placeholder implements $implements {\n'
        '  const $identifier();\n'
        '}\n',
      );
    }
  }
}
