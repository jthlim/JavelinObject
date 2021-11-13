import '../compiler_context.dart';
import '../dart/dart_module_extension.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';

class UnionDeclarationGenerator implements UnionGenerator {
  const UnionDeclarationGenerator();

  @override
  int get priority => ObjectGeneratorPriority.classDeclaration.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    for (final dartAnnotation in u.dartAnnotations) {
      buffer.write('$dartAnnotation\n');
    }
    buffer.write('class ${u.name} {\n');
  }
}
