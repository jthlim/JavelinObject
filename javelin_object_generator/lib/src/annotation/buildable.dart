import '../compiler_context.dart';
import '../dart/dart_module_extension.dart';
import '../dart/data_type_format_extension.dart';
import '../data_type.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';
import '../processor.dart';

import 'annotations.jo.dart';

class BuildableAnnotation implements ClassProcessor {
  const BuildableAnnotation();

  @override
  Type get annotationType => Buildable;

  @override
  void process(
    CompilerContext context,
    Module module,
    Class c,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! Buildable) throw StateError('Internal error');

    if (annotation.includeFactory) {
      context.addClassGenerator(const _BuilderFactoryClassGenerator(), c: c);
    }
    if (annotation.includeToBuilder) {
      context.addClassGenerator(const _ToBuilderClassGenerator(), c: c);
    }

    if (annotation.includeFactory || annotation.includeToBuilder) {
      context.addClassGenerator(const _BuilderClassClassGenerator(), c: c);
    }
  }
}

class _BuilderFactoryClassGenerator implements ClassGenerator {
  const _BuilderFactoryClassGenerator();

  @override
  int get priority => ObjectGeneratorPriority.builderFactory.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    final builderClassName = '_${c.name}Builder';

    buffer.write(
      '\n'
      '  static $builderClassName builder() => $builderClassName();\n',
    );
  }
}

class _ToBuilderClassGenerator implements ClassGenerator {
  const _ToBuilderClassGenerator();

  @override
  int get priority => ObjectGeneratorPriority.toBuilder.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    final builderClassName = '_${c.name}Builder';

    buffer.write(
      '\n'
      '  $builderClassName toBuilder() {\n'
      '    return $builderClassName()',
    );
    for (final field in c.fields) {
      buffer.write('\n      ..${field.name} = ${field.name}');
    }
    buffer.write(
      ';\n'
      '  }\n',
    );
  }
}

class _BuilderClassClassGenerator implements ClassGenerator {
  const _BuilderClassClassGenerator();

  @override
  int get priority => ObjectGeneratorPriority.builderClass.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    final builderClassName = '_${c.name}Builder';
    buffer.write(
      '\n'
      'class $builderClassName {\n',
    );
    for (final field in c.fields) {
      final deprecatedAnnotation = _deprecatedAnnotation(field);
      if (deprecatedAnnotation != null) {
        buffer.write('  $deprecatedAnnotation\n');
      }
      final optionalType = field.type.optional;
      buffer.write('  ${optionalType.dartType} ${field.name};\n');
    }
    buffer.write(
      '\n'
      '  ${c.name} build() {\n'
      '    return ${c.name}(\n',
    );
    for (final field in c.fields) {
      if (field.type.isOptional) {
        buffer.write('      ${field.name}: ${field.name},\n');
      } else {
        buffer.write('      ${field.name}: ${field.name}!,\n');
      }
    }
    buffer.write(
      '    );\n'
      '  }\n'
      '}\n',
    );
  }

  static String? _deprecatedAnnotation(Field field) {
    for (final annotation in field.dartAnnotations) {
      if (annotation.startsWith('@Deprecated')) {
        return annotation;
      }
    }
    return null;
  }
}
