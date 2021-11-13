import '../compiler_context.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';
import '../processor.dart';

import 'annotations.jo.dart';

class EnumValuesAnnotation implements EnumProcessor, EnumGenerator {
  const EnumValuesAnnotation();

  @override
  Type get annotationType => EnumValues;

  @override
  void process(
    CompilerContext context,
    Module module,
    Enum e,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! EnumValues) throw StateError('Internal error');

    context.addEnumGenerator(this, e: e);
  }

  @override
  int get priority => ObjectGeneratorPriority.enumValues.index;

  @override
  void generate(
    CompilerContext context,
    StringBuffer buffer,
    Enum e,
  ) {
    buffer.write(
      '\n'
      '  static const values = <${e.name}>[\n',
    );
    for (final value in e.values) {
      buffer.write('    ${value.name},\n');
    }
    buffer.write('  ];\n');
  }
}
