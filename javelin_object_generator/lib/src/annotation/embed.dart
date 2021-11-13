import 'package:javelin_object_generator/src/generator_priority/field_generator_priority.dart';

import '../compiler_context.dart';
import '../dart/dart_module_extension.dart';
import '../dart/data_type_format_extension.dart';
import '../data_type.dart';
import '../generator.dart';
import '../module.dart';
import '../processor.dart';

import 'annotation_module_extension.dart';
import 'annotations.jo.dart';

class EmbedFieldAnnotation implements FieldProcessor {
  const EmbedFieldAnnotation();

  @override
  Type get annotationType => Embed;

  @override
  void process(
    CompilerContext context,
    Module module,
    ObjectBase o,
    Field f,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! Embed) throw StateError('Internal error');

    if (o is! Class) {
      throw const FormatException('Embed can only be used for class fields');
    }

    f.dartAnnotations.add('@visibleForTesting');

    context.addFieldGenerator(
      _EmbedFieldGenerator(annotation),
      object: o,
      f: f,
    );
  }
}

class _EmbedFieldGenerator implements FieldGenerator {
  _EmbedFieldGenerator(this.annotation);

  final Embed annotation;

  @override
  int get priority => FieldGeneratorPriority.embedAccessors.index;

  @override
  void generate(
    CompilerContext context,
    StringBuffer buffer,
    ObjectBase o,
    Field f,
  ) {
    final nonOptionalType = f.type.nonOptional;
    if (nonOptionalType.kind != DataTypeKind.objectType) {
      throw const FormatException(
        'Embed can only be used on fields that are '
        'classes or unions',
      );
    }

    final objectBase = nonOptionalType.objectType.resolvedObject;
    if (objectBase is! Class && objectBase is! Union) {
      throw const FormatException(
        'Embed can only be used on fields that are '
        'classes or unions',
      );
    }

    final embedMap = <String, String>{};
    if (annotation.fields == null && annotation.map == null) {
      if (objectBase is Union) {
        embedMap[objectBase.activeElementFieldName] =
            objectBase.activeElementFieldName;
      }
      for (final field in objectBase.fields) {
        embedMap[field.name] = field.name;
      }
    } else {
      final fieldNames = annotation.fields;
      if (fieldNames != null) {
        for (final fieldName in fieldNames) {
          embedMap[fieldName] = fieldName;
        }
      }

      final map = annotation.map;
      if (map != null) embedMap.addAll(map);
    }

    if (objectBase is Class) {
      _generateClassEmbed(context, buffer, o as Class, f, objectBase, embedMap);
    } else if (objectBase is Union) {
      _generateUnionEmbed(context, buffer, o as Class, f, objectBase, embedMap);
    }
  }

  void _generateClassEmbed(
    CompilerContext context,
    StringBuffer buffer,
    Class c,
    Field f,
    Class embedClass,
    Map<String, String> embedMap,
  ) {
    final nameMap = <String, Field>{
      for (final field in embedClass.fields) field.name: field,
    };

    embedMap.forEach((name, fieldName) {
      final classField = nameMap[fieldName];
      if (classField != null) {
        buffer.write(
          '  ${classField.type.dartType} get $name => ${f.name}.$fieldName;\n',
        );
        if (!classField.isImmutable && !embedClass.isImmutable) {
          buffer.write(
            '  void set $name(${classField.type.dartType} \$newValue) => '
            /*  */ '${f.name}.$fieldName = \$newValue;\n',
          );
        }
      } else {
        throw FormatException(
          'Class ${embedClass.name} doesn\'t have a field \'$fieldName\'',
        );
      }
    });
  }

  void _generateUnionEmbed(
    CompilerContext context,
    StringBuffer buffer,
    Class c,
    Field f,
    Union embedUnion,
    Map<String, String> embedMap,
  ) {
    final nameMap = <String, Field>{
      for (final field in embedUnion.fields) field.name: field,
    };

    embedMap.forEach((name, fieldName) {
      final unionField = nameMap[fieldName];
      if (unionField != null) {
        buffer.write(
          '  ${unionField.type.dartType} get $name => ${f.name}.$fieldName;\n',
        );
        buffer.write(
          '  ${unionField.type.optional.dartType} get ${name}OrNull => '
          /*  */ '${f.name}.${fieldName}OrNull;\n',
        );
        if (!unionField.isImmutable && !embedUnion.isImmutable) {
          buffer.write(
            '  void set $name(${unionField.type.dartType} \$newValue) => '
            /*  */ '${f.name}.$fieldName = \$newValue;\n',
          );
        }
      } else if (fieldName == embedUnion.activeElementFieldName) {
        buffer.write(
          '  ${embedUnion.activeElementClassName} get $name =>\n'
          '      ${f.name}.$fieldName;\n',
        );
      } else {
        throw FormatException(
          'Union ${embedUnion.name} doesn\'t have a field \'$fieldName\'',
        );
      }
    });
    buffer.write('\n');
  }
}
