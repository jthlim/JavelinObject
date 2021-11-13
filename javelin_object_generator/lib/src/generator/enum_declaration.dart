import '../compiler_context.dart';
import '../dart/dart_module_extension.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';

class EnumDeclarationGenerator implements EnumGenerator {
  const EnumDeclarationGenerator();

  @override
  int get priority => ObjectGeneratorPriority.classDeclaration.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Enum e) {
    for (final dartAnnotation in e.dartAnnotations) {
      buffer.write('$dartAnnotation\n');
    }
    buffer.write('class ${e.name} {\n');
  }
}
