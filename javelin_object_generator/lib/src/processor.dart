import 'annotation/annotations.jo.dart';
import 'compiler_context.dart';
import 'module.dart';

abstract class ModuleProcessor {
  void process(CompilerContext context, Module module);
}

abstract class ClassProcessor<T> {
  Type get annotationType;

  void process(
    CompilerContext context,
    Module module,
    Class c,
    ParsedAnnotation annotation,
  );
}

abstract class EnumProcessor<T> {
  Type get annotationType;

  void process(
    CompilerContext context,
    Module module,
    Enum e,
    ParsedAnnotation annotation,
  );
}

abstract class UnionProcessor<T> {
  Type get annotationType;

  void process(
    CompilerContext context,
    Module module,
    Union u,
    ParsedAnnotation annotation,
  );
}

abstract class FieldProcessor {
  Type get annotationType;

  void process(
    CompilerContext context,
    Module module,
    ObjectBase object,
    Field field,
    ParsedAnnotation annotation,
  );
}

abstract class MethodProcessor {
  Type get annotationType;

  void process(
    CompilerContext context,
    Module module,
    ObjectBase object,
    Method method,
    ParsedAnnotation annotation,
  );
}

abstract class EnumValueProcessor {
  Type get annotationType;

  void process(
    CompilerContext context,
    Module module,
    Enum e,
    EnumValue v,
    ParsedAnnotation annotation,
  );
}
