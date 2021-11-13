import '../compiler_context.dart';
import '../module.dart';
import '../processor.dart';

import 'annotations.jo.dart';
import 'convert/binary_convert.dart';
import 'convert/dart_string.dart';
import 'convert/id_convert.dart';
import 'convert/json_convert.dart';
import 'convert/map_convert.dart';
import 'convert/object_convert.dart';
import 'convert/string_convert.dart';
import 'convert/yaml_convert.dart';

class ConvertClassAnnotation implements ClassProcessor {
  const ConvertClassAnnotation();

  @override
  Type get annotationType => ConvertClass;

  @override
  void process(
    CompilerContext context,
    Module module,
    Class c,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! ConvertClass) throw StateError('Internal error');

    if (annotation.includeFromJson) {
      FromJsonFactoryClassGenerator.processFromJsonConvertAnnotation(
        context,
        module,
        c,
        annotation,
      );
    }

    if (annotation.includeToJson) {
      context.addClassGenerator(const JsonTypeClassGenerator(), c: c);
      context.addClassGenerator(const ToJsonClassGenerator(), c: c);
    }

    if (annotation.includeFromYaml) {
      context.addClassGenerator(const FromYamlClassGenerator(), c: c);
    }

    if (annotation.includeFromString) {
      context.addClassGenerator(const FromStringClassGenerator(), c: c);
    }

    if (annotation.includeToString) {
      context.addClassGenerator(const ToStringClassGenerator(), c: c);
    }

    if (annotation.includeFromBinary) {
      FromBinaryFactoryClassGenerator.processFromBinaryConvertAnnotation(
        context,
        module,
        c,
        annotation,
      );
    }

    if (annotation.includeToBinary) {
      context.addClassGenerator(const BinaryTypeIdClassGenerator(), c: c);
      context.addClassGenerator(const ToBinaryClassGenerator(), c: c);
    }

    if (annotation.includeFromMap ||
        annotation.includeFromYaml ||
        annotation.includeFromString) {
      FromMapFactoryClassGenerator.processFromMapConvertAnnotation(
        context,
        module,
        c,
        annotation,
      );
    }

    if (annotation.includeToMap || annotation.includeToString) {
      context.addClassGenerator(const JoTypeClassGenerator(), c: c);
      context.addClassGenerator(const ToMapClassGenerator(), c: c);
    }

    if (annotation.includeToDartString) {
      context.addClassGenerator(
        const ToDartStringClassGenerator(),
        c: c,
      );
    }
  }
}

class ConvertEnumAnnotation implements EnumProcessor {
  const ConvertEnumAnnotation();

  @override
  Type get annotationType => ConvertEnum;

  @override
  void process(
    CompilerContext context,
    Module module,
    Enum e,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! ConvertEnum) throw StateError('Internal error');

    if (annotation.includeFromString) {
      context.addEnumGenerator(const FromStringEnumGenerator(), e: e);
    }

    if (annotation.includeToString) {
      context.addEnumGenerator(const ToStringEnumGenerator(), e: e);
    }

    if (annotation.includeFromId) {
      context.addEnumGenerator(const FromIdEnumGenerator(), e: e);
    }

    if (annotation.includeFromJson) {
      context.addEnumGenerator(const FromJsonEnumGenerator(), e: e);
    }

    if (annotation.includeToJson) {
      context.addEnumGenerator(const ToJsonEnumGenerator(), e: e);
    }

    if (annotation.includeToDartString) {
      context.addEnumGenerator(
        const ToDartStringEnumGenerator(),
        e: e,
      );
    }
  }
}

class ConvertUnionAnnotation implements UnionProcessor {
  const ConvertUnionAnnotation();

  @override
  Type get annotationType => ConvertUnion;

  @override
  void process(
    CompilerContext context,
    Module module,
    Union u,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! ConvertUnion) throw StateError('Internal error');

    if (annotation.includeFromJson) {
      context.addUnionGenerator(const FromJsonFactoryUnionGenerator(), u: u);
      context.addUnionGenerator(
        const FromJsonFactoryHelperUnionGenerator(),
        u: u,
      );
    }

    if (annotation.includeToJson) {
      context.addUnionGenerator(const ToJsonUnionGenerator(), u: u);
    }

    if (annotation.includeFromYaml) {
      context.addUnionGenerator(const FromYamlUnionGenerator(), u: u);
    }

    if (annotation.includeFromObject ||
        (annotation.includeFromString && u.isInline) ||
        (annotation.includeFromYaml && u.isInline)) {
      context.addUnionGenerator(const FromObjectUnionGenerator(), u: u);
    }

    if (annotation.includeFromMap ||
        (annotation.includeFromString && !u.isInline) ||
        (annotation.includeFromYaml && !u.isInline)) {
      context.addUnionGenerator(const FromMapFactoryUnionGenerator(), u: u);
      context.addUnionGenerator(
        const FromMapFactoryHelperUnionGenerator(),
        u: u,
      );
    }

    if (annotation.includeFromBinary) {
      context.addUnionGenerator(const FromBinaryFactoryUnionGenerator(), u: u);
      context.addUnionGenerator(
        const FromBinaryFactoryHelperUnionGenerator(),
        u: u,
      );
    }

    if (annotation.includeToBinary) {
      context.addUnionGenerator(const ToBinaryUnionGenerator(), u: u);
    }

    if (annotation.includeToMap ||
        (annotation.includeToString && !u.isInline)) {
      context.addUnionGenerator(const ToMapUnionGenerator(), u: u);
    }

    if (annotation.includeToObject ||
        (annotation.includeToString && u.isInline)) {
      context.addUnionGenerator(const ToObjectUnionGenerator(), u: u);
    }

    if (annotation.includeFromString) {
      context.addUnionGenerator(const FromStringUnionGenerator(), u: u);
    }

    if (annotation.includeToString) {
      context.addUnionGenerator(const ToStringUnionGenerator(), u: u);
    }

    if (annotation.includeToDartString) {
      context.addUnionGenerator(
        const ToDartStringUnionGenerator(),
        u: u,
      );
    }
  }
}
