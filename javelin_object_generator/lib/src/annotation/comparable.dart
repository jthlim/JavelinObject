import '../compiler_context.dart';
import '../dart/dart_module_extension.dart';
import '../dart/data_type_format_extension.dart';
import '../data_type.dart';
import '../generator.dart';
import '../generator_priority/object_generator_priority.dart';
import '../module.dart';
import '../processor.dart';

import 'annotation_module_extension.dart';
import 'annotations.jo.dart';

class ComparableClassAnnotation implements ClassProcessor {
  const ComparableClassAnnotation();

  @override
  Type get annotationType => ComparableClass;

  @override
  void process(
    CompilerContext context,
    Module module,
    Class c,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! ComparableClass) throw StateError('Internal error');

    final fieldNameMap = {
      for (final field in c.fields) field.name: field,
    };

    final fieldNames =
        annotation.fields ?? [for (final field in c.fields) field.name];

    if (fieldNames.isEmpty && !c.hasSuperclassMembers) {
      throw ArgumentError('@Comparable missing \'fields\' parameter');
    }

    for (final fieldName in fieldNames) {
      if (!fieldNameMap.containsKey(fieldName)) {
        throw ArgumentError('Field $fieldName doesn\'t exist in ${c.name}\n');
      }
    }

    final generateOrderedComparisons = annotation.orderedOperators;
    if (generateOrderedComparisons) {
      c.dartInterfaceNames.add('Comparable<${c.name}>');
    }

    context.addClassGenerator(
      _HashCodeAndEqualityClassGenerator(
        fields: {
          for (final fieldName in fieldNames)
            fieldName: fieldNameMap[fieldName]!,
        },
        generateOrderedComparisons: generateOrderedComparisons,
      ),
      c: c,
    );
  }
}

class _HashCodeAndEqualityClassGenerator implements ClassGenerator {
  _HashCodeAndEqualityClassGenerator({
    required this.fields,
    required this.generateOrderedComparisons,
  });

  final Map<String, Field> fields;
  final bool generateOrderedComparisons;

  @override
  int get priority => ObjectGeneratorPriority.hashCodeAndEquality.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    if (generateOrderedComparisons) {
      _generateOrderedComparisons(context, buffer, c);
    }
    if (c.fields.isNotEmpty) {
      _generateHashCode(context, buffer, c);
    }
    _generateEqualsOperator(context, buffer, c);
  }

  void _generateOrderedComparisons(
    CompilerContext context,
    StringBuffer buffer,
    Class c,
  ) {
    // Generate compareTo
    buffer.write(
      '\n'
      '  @override\n'
      '  int compareTo(${c.name} other) {\n',
    );
    var counter = 0;
    fields.forEach((fieldName, field) {
      final fieldKind = field.type.nonOptional.kind;
      if (fieldKind == DataTypeKind.bytesType ||
          fieldKind == DataTypeKind.listType ||
          fieldKind == DataTypeKind.setType ||
          fieldKind == DataTypeKind.mapType) {
        throw UnsupportedError(
          'Generating ordered comparisons for ${c.name}.$fieldName is not '
          'yet supported.',
        );
      }

      final temporaryName = '\$v$counter';
      buffer.write(
        '    final $temporaryName = $fieldName.compareTo(other.$fieldName);\n',
      );
      ++counter;

      buffer.write(
        '    if ($temporaryName != 0) return $temporaryName;\n'
        '\n',
      );
    });
    buffer.write(
      '    return 0;\n'
      '  }\n',
    );

    // Comparison operators
    buffer.write('\n');
    for (final o in const ['<', '<=', '>', '>=']) {
      buffer.write(
        '  bool operator$o(${c.name} other) => compareTo(other) $o 0;\n',
      );
    }
  }

  void _generateHashCode(
    CompilerContext context,
    StringBuffer buffer,
    Class c,
  ) {
    // Generate hashCode.
    final initialHashCode = c.hasSuperclassMembers ? 'super.hashCode' : '0';

    buffer.write(
      '\n'
      '  @override\n'
      '  int get hashCode {\n'
      '    var result = $initialHashCode;\n',
    );
    fields.forEach((fieldName, field) {
      final fieldType = field.type.nonOptional;
      final equality = _collectionEquality(fieldType);
      if (equality != '') {
        buffer.write(
          '    result = joCombineHashCode(result, const $equality.hash($fieldName));\n',
        );
      } else {
        buffer.write(
          '    result = joCombineHashCode(result, $fieldName.hashCode);\n',
        );
      }
    });
    buffer.write(
      '    return joFinalizeHashCode(result);\n'
      '  }\n',
    );
  }

  void _generateEqualsOperator(
    CompilerContext context,
    StringBuffer buffer,
    Class c,
  ) {
    buffer.write(
      '\n'
      '  @override\n'
      '  bool operator==(Object other) =>\n'
      '    other is ${c.name}',
    );

    if (c.hasSuperclassMembers) {
      buffer.write('\n    && super == other');
    }

    fields.forEach((fieldName, field) {
      final fieldType = field.type.nonOptional;
      final equality = _collectionEquality(fieldType);
      if (equality != '') {
        buffer.write(
          '\n    && const $equality.equals($fieldName, other.$fieldName)',
        );
      } else {
        buffer.write('\n    && $fieldName == other.$fieldName');
      }
    });
    buffer.write(';\n');
  }

  String _collectionEquality(DataType type) {
    switch (type.kind) {
      case DataTypeKind.optionalType:
        throw StateError('Internal error');

      case DataTypeKind.boolType:
      case DataTypeKind.int8Type:
      case DataTypeKind.int32Type:
      case DataTypeKind.int64Type:
      case DataTypeKind.uint8Type:
      case DataTypeKind.uint32Type:
      case DataTypeKind.uint64Type:
      case DataTypeKind.floatType:
      case DataTypeKind.doubleType:
      case DataTypeKind.stringType:
      case DataTypeKind.objectType:
        return '';

      case DataTypeKind.bytesType:
        return 'ListEquality()';

      case DataTypeKind.listType:
        return 'ListEquality(${_collectionEquality(type.listType)})';

      case DataTypeKind.setType:
        return 'SetEquality(${_collectionEquality(type.setType)})';

      case DataTypeKind.mapType:
        final keyEquality = _collectionEquality(type.mapType.keyType);
        final valueEquality = _collectionEquality(type.mapType.valueType);

        final parameters = <String>[
          if (keyEquality != '') 'keys: $keyEquality',
          if (valueEquality != '') 'values: $valueEquality',
        ].join(', ');

        return 'MapEquality($parameters)';
    }
  }
}

class ComparableUnionAnnotation implements UnionProcessor {
  const ComparableUnionAnnotation();

  @override
  Type get annotationType => ComparableUnion;

  @override
  void process(
    CompilerContext context,
    Module module,
    Union u,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! ComparableUnion) throw StateError('Internal error');

    context.addUnionGenerator(
      const _HashCodeAndEqualityUnionGenerator(),
      u: u,
    );
  }
}

class _HashCodeAndEqualityUnionGenerator implements UnionGenerator {
  const _HashCodeAndEqualityUnionGenerator();

  @override
  int get priority => ObjectGeneratorPriority.hashCodeAndEquality.index;

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    // Generate hashCode.
    if (u.fields.any((f) => _collectionEquality(f.type) != '')) {
      buffer.write(
        '\n'
        '  @override\n'
        '  int get hashCode {\n'
        '    switch (${u.activeElementFieldName}) {\n',
      );
      for (final field in u.fields) {
        final equality = _collectionEquality(field.type);
        if (equality == '') continue;
        buffer.write(
          '      case ${u.activeElementClassName}.${field.name}:\n'
          '        return joFinalizeHashCode(\n'
          '          joCombineHashCode(\n'
          '            ${u.activeElementFieldName}.hashCode,\n'
          '            const $equality.hash(_value as ${field.type.dartType}),\n'
          '          ),\n'
          '        );\n',
        );
      }
      buffer.write(
        '      default:\n'
        '        return joFinalizeHashCode(\n'
        '          joCombineHashCode(${u.activeElementFieldName}.hashCode, _value.hashCode),\n'
        '        );\n'
        '    }\n'
        '  }\n'
        '\n'
        '  @override\n'
        '  bool operator==(Object other) {\n'
        '    if (other is! ${u.name}) return false;\n'
        '    if (${u.activeElementFieldName} != other.${u.activeElementFieldName}) return false;\n'
        '    switch (${u.activeElementFieldName}) {\n',
      );
      for (final field in u.fields) {
        final equality = _collectionEquality(field.type);
        if (equality == '') continue;
        buffer.write(
          '      case ${u.activeElementClassName}.${field.name}:\n'
          '        return const $equality.equals(\n'
          '          _value as ${field.type.dartType},\n'
          '          other._value as ${field.type.dartType},\n'
          '        );\n',
        );
      }
      buffer.write(
        '      default:\n'
        '        return _value == other._value;\n'
        '    }\n'
        '  }\n',
      );
    } else {
      buffer.write(
        '\n'
        '  @override\n'
        '  int get hashCode => joFinalizeHashCode(\n'
        '    joCombineHashCode(${u.activeElementFieldName}.hashCode, _value.hashCode),\n'
        '  );\n'
        '\n'
        '  @override\n'
        '  bool operator==(Object other) {\n'
        '    if (other is! ${u.name}) return false;\n'
        '    return ${u.activeElementFieldName} == other.${u.activeElementFieldName}\n'
        '      && _value == other._value;\n'
        '  }\n',
      );
    }
  }

  String _collectionEquality(DataType type) {
    switch (type.kind) {
      case DataTypeKind.optionalType:
        return _collectionEquality(type.optionalType);

      case DataTypeKind.boolType:
      case DataTypeKind.int8Type:
      case DataTypeKind.int32Type:
      case DataTypeKind.int64Type:
      case DataTypeKind.uint8Type:
      case DataTypeKind.uint32Type:
      case DataTypeKind.uint64Type:
      case DataTypeKind.floatType:
      case DataTypeKind.doubleType:
      case DataTypeKind.stringType:
      case DataTypeKind.objectType:
        return '';

      case DataTypeKind.bytesType:
        return 'ListEquality()';

      case DataTypeKind.listType:
        return 'ListEquality(${_collectionEquality(type.listType)})';

      case DataTypeKind.setType:
        return 'ListEquality(${_collectionEquality(type.setType)})';

      case DataTypeKind.mapType:
        final keyEquality = _collectionEquality(type.mapType.keyType);
        final valueEquality = _collectionEquality(type.mapType.valueType);

        final parameters = <String>[
          if (keyEquality != '') 'keys: $keyEquality',
          if (valueEquality != '') 'values: $valueEquality',
        ].join(', ');

        return 'MapEquality($parameters)';
    }
  }
}
