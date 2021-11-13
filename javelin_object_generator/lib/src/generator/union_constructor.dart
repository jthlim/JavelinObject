import '../annotation/annotation_module_extension.dart';
import '../compiler_context.dart';
import '../dart/dart_value_extension.dart';
import '../dart/data_type_format_extension.dart';
import '../data_type.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';

class UnionConstructorGenerator implements UnionGenerator {
  const UnionConstructorGenerator();

  @override
  int get priority => ObjectGeneratorPriority.constructor.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    var isFirstConstructor = true;

    for (final field in u.fields) {
      if (isFirstConstructor) {
        isFirstConstructor = false;
      } else {
        buffer.write('\n');
      }

      if (u.isImmutable) {
        buffer.write('  const ${u.name}.${field.name}(');
      } else {
        buffer.write('  ${u.name}.${field.name}(');
      }

      // Special case objects that have no fields and are immutable to not
      // take a parameter.
      if (field.canUseParameterlessConstructor) {
        buffer.write(
          ')\n'
          '    : ${u.activeElementFieldName} = ${u.activeElementClassName}.${field.name},\n'
          '      _value = const ${field.type.dartType}();\n',
        );
        continue;
      }

      final defaultValue = field.defaultValue;
      if (field.type.isOptional) {
        buffer.write('[${field.type.dartType} ${field.name}]');
      } else if (defaultValue != null) {
        final defaultValueString = u.isImmutable
            ? defaultValue.constValueString
            : defaultValue.valueString;
        buffer.write(
          '[${field.type.dartType} ${field.name} = $defaultValueString}]',
        );
      } else {
        buffer.write('${field.type.dartType} ${field.name}');
      }

      buffer.write(
        ')\n'
        '    : ${u.activeElementFieldName} = ${u.activeElementClassName}.${field.name},\n'
        '      _value = ${field.name};\n',
      );
    }
  }
}
