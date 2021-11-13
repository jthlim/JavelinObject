import '../compiler_context.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';

class ClassFieldsGenerator implements ClassGenerator {
  const ClassFieldsGenerator();

  @override
  int get priority => ObjectGeneratorPriority.fields.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    if (c.fields.isEmpty) return;

    buffer.write('\n');
    for (final field in c.fields) {
      context.generateField(buffer, c, field);
    }
  }
}
