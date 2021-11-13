import '../compiler_context.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';

class EnumConstructorGenerator implements EnumGenerator {
  const EnumConstructorGenerator();

  @override
  int get priority => ObjectGeneratorPriority.constructor.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Enum e) {
    buffer.write(
      '  const ${e.name}._({\n'
      '    required this.\$id,\n'
      '    required this.\$name,\n',
    );
    for (final field in e.fields) {
      buffer.write('    required this.${field.name},\n');
    }
    buffer.write('  });\n');
  }
}
