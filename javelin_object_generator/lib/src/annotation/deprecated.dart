import 'package:javelin_object/jo_internal.dart';

import '../compiler_context.dart';
import '../dart/dart_module_extension.dart';
import '../module.dart';
import '../processor.dart';

import 'annotations.jo.dart';

class DeprecatedClassAnnotation implements ClassProcessor {
  const DeprecatedClassAnnotation();

  @override
  Type get annotationType => Deprecated;

  @override
  void process(
    CompilerContext context,
    Module module,
    Class c,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! Deprecated) throw StateError('Internal error');

    final message = annotation.message;
    c.dartAnnotations.add('@Deprecated(${message.dartEscapedString})');
  }
}

class DeprecatedFieldAnnotation implements FieldProcessor {
  const DeprecatedFieldAnnotation();

  @override
  Type get annotationType => Deprecated;

  @override
  void process(
    CompilerContext context,
    Module module,
    ObjectBase object,
    Field field,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! Deprecated) throw StateError('Internal error');

    final message = annotation.message;
    field.dartAnnotations.add('@Deprecated(${message.dartEscapedString})');
  }
}
