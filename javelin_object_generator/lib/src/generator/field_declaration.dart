import 'package:javelin_object_generator/src/value.jo.dart';

import '../annotation/annotation_module_extension.dart';
import '../compiler_context.dart';
import '../dart/dart_module_extension.dart';
import '../dart/dart_value_extension.dart';
import '../dart/data_type_format_extension.dart';
import '../data_type.dart';
import '../generator.dart';
import '../generator_priority/field_generator_priority.dart';
import '../module.dart';

class FieldDeclarationGenerator implements FieldGenerator {
  const FieldDeclarationGenerator();

  @override
  int get priority => FieldGeneratorPriority.fieldDeclaration.index;

  @override
  void generate(
    CompilerContext context,
    StringBuffer buffer,
    ObjectBase object,
    Field field,
  ) {
    for (final dartAnnotation in field.dartAnnotations) {
      buffer.write('  $dartAnnotation\n');
    }
    final defaultValue = field.defaultValue;
    final fieldType = field.type;

    if (defaultValue != null &&
        fieldType.isOptional &&
        defaultValue.type != ValueType.newValue) {
      if (object.isImmutable || field.isImmutable) {
        buffer.write(
            '  ${fieldType.nonOptional.dartType} get ${field.name} => _${field.name} ?? ${defaultValue.valueString};\n'
            '  final ${fieldType.dartType} _${field.name};\n');
      } else {
        buffer.write(
          '  ${fieldType.nonOptional.dartType} get ${field.name} => _${field.name} ?? ${defaultValue.valueString};\n'
          '  ${fieldType.dartType} _${field.name};\n'
          '  set ${field.name}(${fieldType.dartType} \$value) => _${field.name} = \$value;\n',
        );
      }
    } else if (object.isImmutable || field.isImmutable) {
      buffer.write('  final ${field.type.dartType} ${field.name};\n');
    } else {
      buffer.write('  ${field.type.dartType} ${field.name};\n');
    }
  }
}
