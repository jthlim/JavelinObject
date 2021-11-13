import '../annotation/annotation_module_extension.dart';
import '../compiler_context.dart';
import '../dart/dart_module_extension.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';

class ClassDeclarationGenerator implements ClassGenerator {
  const ClassDeclarationGenerator();

  @override
  int get priority => ObjectGeneratorPriority.classDeclaration.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    for (final dartAnnotation in c.dartAnnotations) {
      buffer.write('$dartAnnotation\n');
    }

    if (c.isAbstract) {
      buffer.write('abstract class ${c.name}');
    } else {
      buffer.write('class ${c.name}');
    }

    final baseClass = c.baseClass;
    if (baseClass != null) {
      buffer.write(' extends ${baseClass.objectName}');
    }

    if (c.dartInterfaceNames.isNotEmpty) {
      buffer.write(' implements');
      for (final interfaceName in c.dartInterfaceNames) {
        buffer.write(' $interfaceName');
      }
    }

    buffer.write(' {\n');
  }
}
