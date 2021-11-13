import '../annotation/annotation_module_extension.dart';
import '../compiler_context.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';

class UnionActiveElementEnumGenerator implements UnionGenerator {
  const UnionActiveElementEnumGenerator();

  @override
  int get priority => ObjectGeneratorPriority.activeElementEnum.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    buffer.write(
      '\n'
      'enum ${u.activeElementClassName} {\n',
    );

    var isFirstTime = true;
    for (final field in u.fields) {
      if (field.documentationComments.isNotEmpty) {
        if (!isFirstTime) buffer.write('\n');
        for (final commentLine in field.documentationComments) {
          buffer.write('  ///$commentLine');
        }
      }
      buffer.write('  ${field.name},\n');

      isFirstTime = false;
    }

    buffer.write('}\n');
  }
}
