import '../compiler_context.dart';
import '../module.dart';
import '../processor.dart';

import 'annotations.jo.dart';

class AvailableClassAnnotation implements ClassProcessor {
  const AvailableClassAnnotation();

  @override
  Type get annotationType => Available;

  @override
  void process(
    CompilerContext context,
    Module module,
    Class c,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! Available) throw StateError('Internal error');

    if (!context.isConditionEnabled(annotation.available)) {
      module.classes.removeWhere((e) => identical(e, c));
    }
  }
}

class AvailableEnumAnnotation implements EnumProcessor {
  const AvailableEnumAnnotation();

  @override
  Type get annotationType => Available;

  @override
  void process(
    CompilerContext context,
    Module module,
    Enum e,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! Available) throw StateError('Internal error');

    if (!context.isConditionEnabled(annotation.available)) {
      module.enums.removeWhere((e) => identical(e, e));
    }
  }
}

class AvailableFieldAnnotation implements FieldProcessor {
  const AvailableFieldAnnotation();

  @override
  Type get annotationType => Available;

  @override
  void process(
    CompilerContext context,
    Module module,
    ObjectBase object,
    Field field,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! Available) throw StateError('Internal error');

    if (!context.isConditionEnabled(annotation.available)) {
      object.fields.removeWhere((e) => identical(e, field));
    }
  }
}

class AvailableEnumValueAnnotation implements EnumValueProcessor {
  const AvailableEnumValueAnnotation();

  @override
  Type get annotationType => Available;

  @override
  void process(
    CompilerContext context,
    Module module,
    Enum e,
    EnumValue value,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! Available) throw StateError('Internal error');

    if (!context.isConditionEnabled(annotation.available)) {
      e.values.removeWhere((e) => identical(e, value));
    }
  }
}

class AvailableUnionAnnotation implements UnionProcessor {
  const AvailableUnionAnnotation();

  @override
  Type get annotationType => Available;

  @override
  void process(
    CompilerContext context,
    Module module,
    Union u,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! Available) throw StateError('Internal error');

    if (!context.isConditionEnabled(annotation.available)) {
      module.unions.removeWhere((e) => identical(e, u));
    }
  }
}
