import '../compiler_context.dart';
import '../data_type.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';
import '../processor.dart';

import 'annotation_module_extension.dart';
import 'annotations.jo.dart';

class MergeClassAnnotation implements ClassProcessor, ClassGenerator {
  const MergeClassAnnotation();

  @override
  Type get annotationType => MergeWith;

  @override
  void process(
    CompilerContext context,
    Module module,
    Class c,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! MergeWith) throw StateError('Internal error');

    if (!c.fields.any(_optionalFieldFilter)) {
      print(
        'Merge used on a class ${c.name} which has no optional fields. '
        'Ignoring',
      );
      return;
    }
    context.addClassGenerator(this, c: c);
  }

  @override
  int get priority => ObjectGeneratorPriority.merge.index;

  @override
  void generate(
    CompilerContext context,
    StringBuffer buffer,
    Class c,
  ) {
    buffer.write(
      '\n'
      '  ${c.name} mergeWith(${c.name} fallback) {\n'
      '    return ${c.name}(\n',
    );
    for (final field in c.fields) {
      final fieldName = field.name;

      if (field.annotations.containsAnnotation<MergeWith>()) {
        final cls = field.type.nonOptional.objectType.resolvedObject;
        if (cls is! Class) {
          throw FormatException(
            '${cls.name}.$fieldName is of type ${cls.name}, which is '
            'not a Class',
          );
        }
        if (field.type.isOptional) {
          buffer.write(
            '      $fieldName: $fieldName == null\n'
            '         ? fallback.$fieldName\n'
            '         : fallback.$fieldName == null\n'
            '           ? $fieldName\n'
            '           : $fieldName!.mergeWith(fallback.$fieldName!),\n',
          );
        } else {
          buffer.write(
            '      $fieldName: $fieldName.mergeWith(fallback.$fieldName),\n',
          );
        }
      } else if (field.type.isOptional) {
        buffer.write('      $fieldName: $fieldName ?? fallback.$fieldName,\n');
      } else {
        buffer.write('      $fieldName: $fieldName,\n');
      }
    }
    buffer.write(
      '    );\n'
      '  }\n',
    );
  }

  static bool _optionalFieldFilter(Field f) => f.type.isOptional;
}

class MergeFieldAnnotation implements FieldProcessor {
  const MergeFieldAnnotation();

  @override
  Type get annotationType => MergeWith;

  @override
  void process(
    CompilerContext context,
    Module module,
    ObjectBase object,
    Field field,
    ParsedAnnotation annotation,
  ) {
    if (object is! Class) {
      throw StateError('MergeWith fields only supported on classes');
    }

    if (field.type.nonOptional.kind != DataTypeKind.objectType) {
      throw FormatException(
        'Field ${object.name}.${field.name} is annotated with @CopyWith, '
        'but is not a class type',
      );
    }

    if (!object.annotations.containsAnnotation<MergeWith>()) {
      throw FormatException(
        'Field ${object.name}.${field.name} is annotated with @CopyWith, '
        'but class ${object.name} is not @CopyWith',
      );
    }
  }
}
