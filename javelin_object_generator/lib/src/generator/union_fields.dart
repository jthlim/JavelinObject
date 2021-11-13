import '../annotation/annotation_module_extension.dart';
import '../compiler_context.dart';
import '../data_type.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';

class UnionFieldsGenerator implements UnionGenerator {
  const UnionFieldsGenerator();

  @override
  int get priority => ObjectGeneratorPriority.fields.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    final hasOptionalField = u.fields.any((f) => f.type.isOptional);
    final storageType = hasOptionalField ? 'Object?' : 'Object';

    final fieldModifier = u.isImmutable ? 'final ' : '';
    buffer.write(
      '\n'
      '  $fieldModifier${u.activeElementClassName} ${u.activeElementFieldName};\n'
      '  $fieldModifier$storageType _value;\n',
    );
  }
}
