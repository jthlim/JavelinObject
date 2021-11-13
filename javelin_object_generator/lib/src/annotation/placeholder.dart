import '../compiler_context.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';
import '../processor.dart';

import 'annotations.jo.dart';

class PlaceholderClassAnnotation implements ClassProcessor {
  const PlaceholderClassAnnotation();

  @override
  Type get annotationType => Placeholder;

  @override
  void process(
    CompilerContext context,
    Module module,
    Class c,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! Placeholder) throw StateError('Internal error');

    context.addClassGenerator(
      _PlaceholderInstanceClassGenerator(annotation.placeholderName),
      c: c,
    );
    context.addClassGenerator(const _PlaceholderClassGenerator(), c: c);
  }
}

class _PlaceholderInstanceClassGenerator implements ClassGenerator {
  _PlaceholderInstanceClassGenerator(this.placeholderName);

  final String placeholderName;

  @override
  int get priority => ObjectGeneratorPriority.placeholderInstance.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    buffer.write(
      '\n'
      '  static const placeholder = _Placeholder${c.name}();\n',
    );
  }
}

class _PlaceholderClassGenerator implements ClassGenerator {
  const _PlaceholderClassGenerator();

  @override
  int get priority => ObjectGeneratorPriority.placeholderClass.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    buffer.write(
      '\n'
      'class _Placeholder${c.name} extends JoPlaceholder implements ${c.name} {\n'
      '  const _Placeholder${c.name}();\n'
      '}\n',
    );
  }
}

class PlaceholderUnionAnnotation implements UnionProcessor {
  const PlaceholderUnionAnnotation();

  @override
  Type get annotationType => Placeholder;

  @override
  void process(
    CompilerContext context,
    Module module,
    Union u,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! Placeholder) throw StateError('Internal error');

    context.addUnionGenerator(
      _PlaceholderInstanceUnionGenerator(annotation.placeholderName),
      u: u,
    );
    context.addUnionGenerator(const _PlaceholderUnionGenerator(), u: u);
  }
}

class _PlaceholderInstanceUnionGenerator implements UnionGenerator {
  _PlaceholderInstanceUnionGenerator(this.placeholderName);

  final String placeholderName;

  @override
  int get priority => ObjectGeneratorPriority.placeholderInstance.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    buffer.write(
      '\n'
      '  static const placeholder = _Placeholder${u.name}();\n',
    );
  }
}

class _PlaceholderUnionGenerator implements UnionGenerator {
  const _PlaceholderUnionGenerator();

  @override
  int get priority => ObjectGeneratorPriority.placeholderClass.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    buffer.write(
      '\n'
      'class _Placeholder${u.name} extends JoPlaceholder implements ${u.name} {\n'
      '  const _Placeholder${u.name}();\n'
      '}\n',
    );
  }
}
