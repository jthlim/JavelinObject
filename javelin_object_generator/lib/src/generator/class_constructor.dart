import '../annotation/annotation_module_extension.dart';
import '../compiler_context.dart';
import '../dart/dart_value_extension.dart';
import '../dart/data_type_format_extension.dart';
import '../data_type.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';
import '../value.jo.dart';

class ClassConstructorGenerator implements ClassGenerator {
  const ClassConstructorGenerator();

  @override
  int get priority => ObjectGeneratorPriority.constructor.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    if (c.isAbstract) {
      buffer.write('  @protected\n');
    }
    if (c.isImmutable) {
      buffer.write('  const ${c.name}(');
    } else {
      buffer.write('  ${c.name}(');
    }

    if (c.fields.isEmpty && !c.hasSuperclassMembers) {
      buffer.write(');\n');
      return;
    }

    buffer.write('{\n');

    final fieldAssignments = <String, Value?>{};
    final allFields = c.allFields;

    allFields.forEach((field, cls) {
      final defaultValue = field.defaultValue;
      if (cls != c) {
        if (defaultValue?.type == ValueType.newValue) {
          buffer.write(
            '    ${field.type.nonOptional.dartType}? ${field.name},\n',
          );
        } else if (field.type.isOptional) {
          buffer.write(
            '    ${field.type.dartType} ${field.name},\n',
          );
        } else if (defaultValue != null) {
          buffer.write(
            '    ${field.type.dartType} ${field.name} = ${defaultValue.constValueString},\n',
          );
        } else {
          buffer.write(
            '    required ${field.type.dartType} ${field.name},\n',
          );
        }
      } else if (defaultValue != null) {
        if (defaultValue.type == ValueType.newValue) {
          if (c.isImmutable || field.type.isOptional) {
            throw FormatException(
              'Cannot use new value for field \'${field.name}\' in immutable '
              'class ${c.name}',
            );
          }
          buffer.write(
            '    ${field.type.nonOptional.dartType}? ${field.name},\n',
          );
          fieldAssignments[field.name] = defaultValue;
        } else if (field.type.isOptional) {
          fieldAssignments[field.name] = null;
          buffer.write(
            '    ${field.type.dartType} ${field.name},\n',
          );
        } else {
          buffer.write(
            '    this.${field.name} = ${defaultValue.constValueString},\n',
          );
        }
      } else if (field.type.isOptional) {
        buffer.write('    this.${field.name},\n');
      } else {
        buffer.write('    required this.${field.name},\n');
      }
    });

    buffer.write('  })');

    var isFirstTime = true;
    if (fieldAssignments.isNotEmpty) {
      fieldAssignments.forEach((fieldName, value) {
        if (isFirstTime) {
          isFirstTime = false;
          buffer.write('  : ');
        } else {
          buffer.write(',\n       ');
        }

        if (value != null) {
          buffer.write('$fieldName = $fieldName ?? ${value.valueString}');
        } else {
          buffer.write('_$fieldName = $fieldName');
        }
      });
    }

    if (allFields.length != c.fields.length) {
      if (isFirstTime) {
        isFirstTime = false;
        buffer.write('  : super(\n');
      } else {
        buffer.write(',\n       super(\n');
      }

      allFields.forEach((field, cls) {
        if (cls == c) return;
        buffer.write('         ${field.name}: ${field.name},\n');
      });

      buffer.write('       )');
    }

    buffer.write(';\n');
  }
}
