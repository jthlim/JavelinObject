import '../compiler_context.dart';
import '../module.dart';
import '../processor.dart';

import 'annotations.jo.dart';

class IgnoreClassAnnotation implements ClassProcessor {
  const IgnoreClassAnnotation({required this.annotationType});

  @override
  final Type annotationType;

  @override
  void process(
    CompilerContext context,
    Module module,
    Class c,
    ParsedAnnotation annotation,
  ) {}
}

class IgnoreEnumAnnotation implements EnumProcessor {
  const IgnoreEnumAnnotation({required this.annotationType});

  @override
  final Type annotationType;

  @override
  void process(
    CompilerContext context,
    Module module,
    Enum e,
    ParsedAnnotation annotation,
  ) {}
}

class IgnoreFieldAnnotation implements FieldProcessor {
  const IgnoreFieldAnnotation({required this.annotationType});

  @override
  final Type annotationType;

  @override
  void process(
    CompilerContext context,
    Module module,
    ObjectBase object,
    Field field,
    ParsedAnnotation annotation,
  ) {}
}

class IgnoreEnumValueAnnotation implements EnumValueProcessor {
  const IgnoreEnumValueAnnotation({required this.annotationType});

  @override
  final Type annotationType;

  @override
  void process(
    CompilerContext context,
    Module module,
    Enum e,
    EnumValue value,
    ParsedAnnotation annotation,
  ) {}
}

class IgnoreUnionAnnotation implements UnionProcessor {
  const IgnoreUnionAnnotation({required this.annotationType});

  @override
  final Type annotationType;

  @override
  void process(
    CompilerContext context,
    Module module,
    Union u,
    ParsedAnnotation annotation,
  ) {}
}
