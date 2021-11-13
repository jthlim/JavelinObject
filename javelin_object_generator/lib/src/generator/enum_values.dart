import '../compiler_context.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';

class EnumValuesGenerator implements EnumGenerator {
  const EnumValuesGenerator();

  @override
  int get priority => ObjectGeneratorPriority.staticInstances.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Enum e) {
    buffer.write('\n');
    for (final value in e.values) {
      context.generateEnumValue(buffer, e, value);
    }
  }
}
