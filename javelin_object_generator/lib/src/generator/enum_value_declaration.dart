import 'package:javelin_object/jo_internal.dart';

import '../compiler_context.dart';
import '../dart/dart_module_extension.dart';
import '../dart/dart_value_extension.dart';
import '../generator.dart';
import '../generator_priority/field_generator_priority.dart';
import '../module.dart';
import '../value.jo.dart';

class EnumValueDeclarationGenerator implements EnumValueGenerator {
  const EnumValueDeclarationGenerator();

  @override
  int get priority => FieldGeneratorPriority.documentation.index;

  @override
  void generate(
    CompilerContext context,
    StringBuffer buffer,
    Enum e,
    EnumValue v,
  ) {
    for (final dartAnnotation in v.dartAnnotations) {
      buffer.write('  $dartAnnotation\n');
    }

    buffer.write(
      '  static const ${v.name} = ${e.name}._(\n'
      '    \$id: ${v.id},\n'
      '    \$name: ${v.name.dartEscapedString},\n',
    );

    final valueMap = _valueMap(e, v);
    valueMap.forEach((key, value) {
      buffer.write('    $key: ${value.constValueString},\n');
    });

    buffer.write('  );\n');
  }

  static Map<String, Value> _valueMap(Enum e, EnumValue v) {
    if (e.fields.isEmpty) return const {};

    return v.fieldValues.when(
      none: () => const {},
      list: (fieldValues) {
        final originalFields = e.originalFields;
        assert(fieldValues.length == originalFields.length);

        final fieldValueMap = <Field, Value>{
          for (var i = 0; i < originalFields.length; ++i)
            originalFields[i]: fieldValues[i],
        };

        return {
          for (final field in e.fields) field.name: fieldValueMap[field]!,
        };
      },
      map: (fieldValueMap) {
        return {
          for (final field in e.fields)
            field.name: fieldValueMap[field.name] ??
                field.defaultValue ??
                const Value.nullValue(),
        };
      },
    );
  }
}
