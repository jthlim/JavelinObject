import '../compiler_context.dart';
import '../dart/dart_module_extension.dart';
import '../module.dart';
import '../processor.dart';

import 'annotations.jo.dart';

class ImmutableClassAnnotation implements ClassProcessor {
  const ImmutableClassAnnotation();

  @override
  Type get annotationType => Immutable;

  @override
  void process(
    CompilerContext context,
    Module module,
    Class c,
    ParsedAnnotation annotation,
  ) {
    c.dartAnnotations.add('@immutable');
  }
}

class ImmutableUnionAnnotation implements UnionProcessor {
  const ImmutableUnionAnnotation();

  @override
  Type get annotationType => Immutable;

  @override
  void process(
    CompilerContext context,
    Module module,
    Union u,
    ParsedAnnotation annotation,
  ) {
    u.dartAnnotations.add('@immutable');
  }
}
