import '../compiler_context.dart';
import '../dart/data_type_format_extension.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';
import '../processor.dart';

import 'annotation_module_extension.dart';
import 'annotations.jo.dart';

class WhenAnnotation implements UnionProcessor, UnionGenerator {
  const WhenAnnotation();

  @override
  Type get annotationType => When;

  @override
  void process(
    CompilerContext context,
    Module module,
    Union u,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! When) throw StateError('Internal error');

    context.addUnionGenerator(this, u: u);
  }

  @override
  int get priority => ObjectGeneratorPriority.when.index;

  @override
  void generate(
    CompilerContext context,
    StringBuffer buffer,
    Union u,
  ) {
    buffer.write(
      '\n'
      '  T when<T>({\n',
    );
    for (final field in u.fields) {
      if (field.canUseParameterlessConstructor) {
        buffer.write('    required T Function() ${field.name},\n');
      } else {
        buffer.write(
          '    required T Function(${field.type.dartType}) ${field.name},\n',
        );
      }
    }
    buffer.write(
      '  }) {\n'
      '    switch (${u.activeElementFieldName}) {\n',
    );
    for (final field in u.fields) {
      if (field.canUseParameterlessConstructor) {
        buffer.write(
          '      case ${u.activeElementClassName}.${field.name}:\n'
          '        return ${field.name}();\n',
        );
      } else {
        buffer.write(
          '      case ${u.activeElementClassName}.${field.name}:\n'
          '        return ${field.name}(_value as ${field.type.dartType});\n',
        );
      }
    }
    buffer.write(
      '    }\n'
      '  }\n',
    );
  }
}
