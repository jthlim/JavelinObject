import 'package:javelin_object_generator/src/generator_priority/module_generator_priority.dart';

import '../compiler_context.dart';
import '../dart/dart_identifier_string_extension.dart';
import '../dart/dart_module_extension.dart';
import '../dart/data_type_format_extension.dart';
import '../data_type.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';
import '../processor.dart';

import 'annotation_module_extension.dart';
import 'annotations.jo.dart';

class CopyWithAnnotation implements ClassProcessor, ClassGenerator {
  const CopyWithAnnotation();

  @override
  Type get annotationType => CopyWith;

  @override
  void process(
    CompilerContext context,
    Module module,
    Class c,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! CopyWith) throw StateError('Internal error');

    final allFields = c.allFields;
    if (allFields.isEmpty) {
      print('CopyWith used on a class ${c.name} which has no fields. Ignoring');
      return;
    }
    context.addClassGenerator(this, c: c);
    context.addModuleGenerator(CopyWithHelperClassModuleGenerator(c));

    for (final field in allFields.keys) {
      switch (field.type.placeholderType) {
        case PlaceholderType.primitive:
          break;
        case PlaceholderType.optionalPrimitive:
          module.dartPlaceholderImplements.add('');
          break;
        case PlaceholderType.object:
          module.dartPlaceholderImplements.add(field.type.nonOptional.dartType);
          break;
      }
    }
  }

  @override
  int get priority => ObjectGeneratorPriority.copyWith.index;

  @override
  void generate(
    CompilerContext context,
    StringBuffer buffer,
    Class c,
  ) {
    buffer.write(
      '\n'
      '  ${c.name}\$CopyWith get copyWith => ${c.name}\$CopyWith(this, (v) => v);\n',
    );
  }
}

class CopyWithHelperClassModuleGenerator extends ModuleGenerator {
  CopyWithHelperClassModuleGenerator(this.c);

  final Class c;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Module module) {
    buffer.write('\n'
        'class ${c.name}\$CopyWith<T> {\n'
        '  ${c.name}\$CopyWith(this._value, this._creator);\n'
        '\n'
        '  final ${c.name} _value;\n'
        '  final T Function(${c.name}) _creator;\n');

    final allFields = c.allFields;

    for (final field in allFields.keys) {
      final nonOptionalType = field.type.nonOptional;
      final baseObject = nonOptionalType.objectTypeOrNull;
      if (baseObject == null) continue;

      final cls = baseObject.resolvedObject as Class?;
      if (cls == null) continue;

      if (!cls.annotations.containsAnnotation<CopyWith>()) continue;

      final optional = cls.canDefaultConstruct
          ? (cls.isImmutable ? ' ?? const ${cls.name}()' : ' ?? ${cls.name}()')
          : (field.type.isOptional ? '!' : '');

      buffer.write(
        '\n'
        '  ${cls.name}\$CopyWith<T> get ${field.name} =>\n'
        '    ${cls.name}\$CopyWith(_value.${field.name}$optional, (v) => this(${field.name}: v));\n',
      );
    }

    buffer.write(
      '\n'
      '  T call({\n',
    );
    for (final field in allFields.keys) {
      switch (field.type.placeholderType) {
        case PlaceholderType.primitive:
          final optionalType = field.type.optional;
          buffer.write('    ${optionalType.dartType} ${field.name},\n');
          break;
        case PlaceholderType.optionalPrimitive:
          buffer.write('    Object? ${field.name} = const _Placeholder(),\n');
          break;
        case PlaceholderType.object:
          final placeholder =
              '_Placeholder\$${field.type.nonOptional.dartType.dartIdentifier}';
          buffer.write(
            '    ${field.type.dartType} ${field.name} = const $placeholder(),\n',
          );
          break;
      }
    }
    buffer.write(
      '  }) {\n'
      '    return _creator(\n'
      '      ${c.name}(\n',
    );
    for (final field in allFields.keys) {
      final fieldName = field.name;
      switch (field.type.placeholderType) {
        case PlaceholderType.primitive:
          buffer.write(
            '        $fieldName: $fieldName ?? _value.$fieldName,\n',
          );
          break;
        case PlaceholderType.optionalPrimitive:
          buffer.write(
            '        $fieldName: identical($fieldName, const _Placeholder())\n'
            '          ? _value.$fieldName\n'
            '          : $fieldName as ${field.type.dartType},\n',
          );
          break;
        case PlaceholderType.object:
          final placeholder =
              '_Placeholder\$${field.type.nonOptional.dartType.dartIdentifier}';
          buffer.write(
            '        $fieldName: identical($fieldName, const $placeholder())\n'
            '          ? _value.$fieldName\n'
            '          : $fieldName,\n',
          );
          break;
      }
    }
    buffer.write(
      '      ),\n'
      '    );\n'
      '  }\n'
      '}\n',
    );
  }

  @override
  int get priority => ModuleGeneratorPriority.copyWithHelper.index;
}

enum PlaceholderType {
  primitive,
  optionalPrimitive,
  object,
}

extension PlaceholderTypeDataTypeExtension on DataType {
  PlaceholderType get placeholderType {
    return when(
      optionalType: (type) => type._placeholderForOptionalType,
      boolType: () => PlaceholderType.primitive,
      int8Type: () => PlaceholderType.primitive,
      int32Type: () => PlaceholderType.primitive,
      int64Type: () => PlaceholderType.primitive,
      uint8Type: () => PlaceholderType.primitive,
      uint32Type: () => PlaceholderType.primitive,
      uint64Type: () => PlaceholderType.primitive,
      floatType: () => PlaceholderType.primitive,
      doubleType: () => PlaceholderType.primitive,
      stringType: () => PlaceholderType.primitive,
      bytesType: () => PlaceholderType.object,
      listType: (_) => PlaceholderType.object,
      setType: (_) => PlaceholderType.object,
      mapType: (_) => PlaceholderType.object,
      objectType: (_) => PlaceholderType.object,
    );
  }

  PlaceholderType get _placeholderForOptionalType {
    return when(
      optionalType: (_) => throw StateError('Internal error'),
      boolType: () => PlaceholderType.optionalPrimitive,
      int8Type: () => PlaceholderType.optionalPrimitive,
      int32Type: () => PlaceholderType.optionalPrimitive,
      int64Type: () => PlaceholderType.optionalPrimitive,
      uint8Type: () => PlaceholderType.optionalPrimitive,
      uint32Type: () => PlaceholderType.optionalPrimitive,
      uint64Type: () => PlaceholderType.optionalPrimitive,
      floatType: () => PlaceholderType.optionalPrimitive,
      doubleType: () => PlaceholderType.optionalPrimitive,
      stringType: () => PlaceholderType.optionalPrimitive,
      bytesType: () => PlaceholderType.object,
      listType: (_) => PlaceholderType.object,
      setType: (_) => PlaceholderType.object,
      mapType: (_) => PlaceholderType.object,
      objectType: (_) => PlaceholderType.object,
    );
  }
}
