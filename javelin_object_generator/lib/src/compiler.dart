import 'package:javelin_object_generator/src/annotation/available.dart';
import 'package:javelin_object_generator/src/role.dart';

import 'annotation/annotation_module_extension.dart';
import 'annotation/annotations.jo.dart' as jo;
import 'annotation/buildable.dart';
import 'annotation/comparable.dart';
import 'annotation/convert.dart';
import 'annotation/copy_with.dart';
import 'annotation/deprecated.dart';
import 'annotation/embed.dart';
import 'annotation/enum_values.dart';
import 'annotation/ignore.dart';
import 'annotation/immutable.dart';
import 'annotation/merge_with.dart';
import 'annotation/placeholder.dart';
import 'annotation/storable.dart';
import 'annotation/when.dart';
import 'common_keywords.dart';
import 'compiler_context.dart';
import 'compiler_options.jo.dart' as jo;
import 'data_type.dart';
import 'data_type_resolver_mixin.dart';
import 'generator.dart';
import 'generator/class_closure.dart';
import 'generator/class_constructor.dart';
import 'generator/class_declaration.dart';
import 'generator/class_documentation.dart';
import 'generator/class_fields.dart';
import 'generator/enum_closure.dart';
import 'generator/enum_constructor.dart';
import 'generator/enum_declaration.dart';
import 'generator/enum_documentation.dart';
import 'generator/enum_fields.dart';
import 'generator/enum_value_declaration.dart';
import 'generator/enum_value_documentation.dart';
import 'generator/enum_values.dart';
import 'generator/field_declaration.dart';
import 'generator/field_documentation.dart';
import 'generator/module_class.dart';
import 'generator/module_enum.dart';
import 'generator/module_header.dart';
import 'generator/module_import.dart';
import 'generator/module_placeholder.dart';
import 'generator/module_register.dart';
import 'generator/module_union.dart';
import 'generator/union_accessors.dart';
import 'generator/union_active_element_enum.dart';
import 'generator/union_closure.dart';
import 'generator/union_constructor.dart';
import 'generator/union_declaration.dart';
import 'generator/union_documentation.dart';
import 'generator/union_fields.dart';
import 'module.dart';
import 'processor.dart';

class Compiler with DataTypeResolverMixin implements CompilerContext {
  Compiler({required this.options})
      : roles = [for (final role in options.roles) Role(role)] {
    addClassProcessor(const AvailableClassAnnotation());
    addClassProcessor(const BuildableAnnotation());
    addClassProcessor(const ComparableClassAnnotation());
    addClassProcessor(const ConvertClassAnnotation());
    addClassProcessor(const CopyWithAnnotation());
    addClassProcessor(const DeprecatedClassAnnotation());
    addClassProcessor(const IgnoreClassAnnotation(annotationType: jo.Abstract));
    addClassProcessor(const ImmutableClassAnnotation());
    addClassProcessor(const MergeClassAnnotation());
    addClassProcessor(const PlaceholderClassAnnotation());
    addClassProcessor(const StorableAnnotation());

    addEnumProcessor(const AvailableEnumAnnotation());
    addEnumProcessor(const ConvertEnumAnnotation());
    addEnumProcessor(const EnumValuesAnnotation());

    addUnionProcessor(const AvailableUnionAnnotation());
    addUnionProcessor(const ComparableUnionAnnotation());
    addUnionProcessor(const ConvertUnionAnnotation());
    addUnionProcessor(
      const IgnoreUnionAnnotation(annotationType: jo.ActiveElement),
    );
    addUnionProcessor(const ImmutableUnionAnnotation());
    addUnionProcessor(const PlaceholderUnionAnnotation());
    addUnionProcessor(const WhenAnnotation());

    addClassFieldProcessor(const AvailableFieldAnnotation());
    addClassFieldProcessor(const DeprecatedFieldAnnotation());
    addClassFieldProcessor(const EmbedFieldAnnotation());
    addClassFieldProcessor(
      const IgnoreFieldAnnotation(annotationType: jo.Alias),
    );
    addClassFieldProcessor(
      const IgnoreFieldAnnotation(annotationType: jo.Column),
    );
    addClassFieldProcessor(
      const IgnoreFieldAnnotation(annotationType: jo.JsonAlias),
    );
    addClassFieldProcessor(
      const IgnoreFieldAnnotation(annotationType: jo.Immutable),
    );
    addClassFieldProcessor(const MergeFieldAnnotation());

    addEnumFieldProcessor(const AvailableFieldAnnotation());

    addEnumValueProcessor(const AvailableEnumValueAnnotation());
    addEnumValueProcessor(
      const IgnoreEnumValueAnnotation(annotationType: jo.Alias),
    );
    addEnumValueProcessor(
      const IgnoreEnumValueAnnotation(annotationType: jo.JsonAlias),
    );

    addUnionFieldProcessor(const AvailableFieldAnnotation());
    addUnionFieldProcessor(
      const IgnoreFieldAnnotation(annotationType: jo.Alias),
    );
    addUnionFieldProcessor(
      const IgnoreFieldAnnotation(annotationType: jo.Column),
    );
    addUnionFieldProcessor(
      const IgnoreFieldAnnotation(annotationType: jo.JsonAlias),
    );

    addModuleGenerator(const ModuleHeaderGenerator());
    addModuleGenerator(const ModuleImportGenerator());
    addModuleGenerator(const ModuleClassGenerator());
    addModuleGenerator(const ModuleEnumGenerator());
    addModuleGenerator(const ModuleUnionGenerator());
    addModuleGenerator(const ModulePlaceholderGenerator());
    addModuleGenerator(const ModuleRegisterGenerator());

    addClassGenerator(const ClassDocumentationGenerator());
    addClassGenerator(const ClassDeclarationGenerator());
    addClassGenerator(const ClassConstructorGenerator());
    addClassGenerator(const ClassFieldsGenerator());
    addClassGenerator(const ClassClosureGenerator());

    addEnumGenerator(const EnumDocumentationGenerator());
    addEnumGenerator(const EnumDeclarationGenerator());
    addEnumGenerator(const EnumConstructorGenerator());
    addEnumGenerator(const EnumValuesGenerator());
    addEnumGenerator(const EnumFieldsGenerator());
    addEnumGenerator(const EnumClosureGenerator());

    addUnionGenerator(const UnionActiveElementEnumGenerator());
    addUnionGenerator(const UnionDocumentationGenerator());
    addUnionGenerator(const UnionDeclarationGenerator());
    addUnionGenerator(const UnionConstructorGenerator());
    addUnionGenerator(const UnionFieldsGenerator());
    addUnionGenerator(const UnionAccessorsGenerator());
    addUnionGenerator(const UnionClosureGenerator());

    addFieldGenerator(const FieldDocumentationGenerator());
    addFieldGenerator(const FieldDeclarationGenerator());

    addEnumValueGenerator(const EnumValueDocumentationGenerator());
    addEnumValueGenerator(const EnumValueDeclarationGenerator());
  }

  final jo.CompilerOptions options;

  final moduleProcessors = <ModuleProcessor>[];
  final classProcessors = <Type, ClassProcessor>{};
  final enumProcessors = <Type, EnumProcessor>{};
  final unionProcessors = <Type, UnionProcessor>{};
  final classFieldProcessors = <Type, FieldProcessor>{};
  final enumFieldProcessors = <Type, FieldProcessor>{};
  final unionFieldProcessors = <Type, FieldProcessor>{};
  final classMethodProcessors = <Type, MethodProcessor>{};
  final enumValueProcessors = <Type, EnumValueProcessor>{};

  final moduleGenerators = <ModuleGenerator>[];
  final classGenerators = <Class?, List<ClassGenerator>>{};
  final classMethodGenerators =
      <ObjectBase?, Map<Method?, List<MethodGenerator>>>{};
  final unionGenerators = <Union?, List<UnionGenerator>>{};
  final enumGenerators = <Enum?, List<EnumGenerator>>{};
  final fieldGenerators = <ObjectBase?, Map<Field?, List<FieldGenerator>>>{};
  final enumValueGenerators =
      <Enum?, Map<EnumValue?, List<EnumValueGenerator>>>{};

  final List<Role> roles;

  @override
  void addModuleProcessor(ModuleProcessor processor) =>
      moduleProcessors.add(processor);

  @override
  void addModuleGenerator(ModuleGenerator generator) =>
      moduleGenerators.add(generator);

  @override
  void addClassGenerator(ClassGenerator generator, {Class? c}) {
    classGenerators.putIfAbsent(c, () => []).add(generator);
  }

  @override
  void addEnumGenerator(EnumGenerator generator, {Enum? e}) =>
      enumGenerators.putIfAbsent(e, () => []).add(generator);

  @override
  void addUnionGenerator(UnionGenerator generator, {Union? u}) =>
      unionGenerators.putIfAbsent(u, () => []).add(generator);

  @override
  void addClassProcessor(ClassProcessor processor) =>
      classProcessors[processor.annotationType] = processor;

  @override
  void addEnumProcessor(EnumProcessor processor) =>
      enumProcessors[processor.annotationType] = processor;

  @override
  void addUnionProcessor(UnionProcessor processor) =>
      unionProcessors[processor.annotationType] = processor;

  @override
  void addFieldGenerator(
    FieldGenerator generator, {
    ObjectBase? object,
    Field? f,
  }) =>
      fieldGenerators
          .putIfAbsent(object, () => {})
          .putIfAbsent(f, () => [])
          .add(generator);

  @override
  void addClassFieldProcessor(FieldProcessor processor) =>
      classFieldProcessors[processor.annotationType] = processor;

  @override
  void addEnumFieldProcessor(FieldProcessor processor) =>
      enumFieldProcessors[processor.annotationType] = processor;

  @override
  void addUnionFieldProcessor(FieldProcessor processor) =>
      unionFieldProcessors[processor.annotationType] = processor;

  @override
  void addMethodGenerator(
    MethodGenerator generator, {
    ObjectBase? object,
    Method? m,
  }) {
    classMethodGenerators
        .putIfAbsent(object, () => {})
        .putIfAbsent(m, () => [])
        .add(generator);
  }

  @override
  void addMethodProcessor(MethodProcessor processor) =>
      classMethodProcessors[processor.annotationType] = processor;

  @override
  void addEnumValueGenerator(EnumValueGenerator generator,
          {Enum? e, EnumValue? v}) =>
      enumValueGenerators
          .putIfAbsent(e, () => {})
          .putIfAbsent(v, () => [])
          .add(generator);

  @override
  void addEnumValueProcessor(EnumValueProcessor processor) =>
      enumValueProcessors[processor.annotationType] = processor;

  @override
  void processModule(Module module) {
    parseModuleAnnotations(module);

    _processModule(module);

    gatherDataTypes(module);
    resolveDataTypes(module);

    verifyModule(module);
  }

  void _processModule(Module module) {
    for (final processor in moduleProcessors) {
      processor.process(this, module);
    }
    for (final i in module.imports) {
      _processModule(i);
    }
    for (final c in [...module.classes]) {
      processClass(module, c);
    }
    for (final e in [...module.enums]) {
      processEnum(module, e);
    }
    for (final u in [...module.unions]) {
      processUnion(module, u);
    }
  }

  void verifyModule(Module module) {
    for (final c in module.classes) {
      verifyClass(module, c);
    }
  }

  void parseModuleAnnotations(Module module) {
    for (final annotation in module.package.annotations) {
      annotation.parse();
    }
    module.package.annotations.removeWhere(_isAnnotationDisabled);

    for (final import in module.imports) {
      parseModuleAnnotations(import);
    }

    for (final c in module.classes) {
      parseClassAnnotations(c);
    }
    for (final e in module.enums) {
      parseEnumAnnotations(e);
    }
    for (final u in module.unions) {
      parseUnionAnnotations(u);
    }
  }

  void parseClassAnnotations(Class c) {
    for (final annotation in c.annotations) {
      annotation.parseForClass();
    }
    c.annotations.removeWhere(_isAnnotationDisabled);
    for (final method in c.methods) {
      parseMethod(method);
    }
    parseObjectBaseAnnotations(c);
  }

  void parseObjectBaseAnnotations(ObjectBase o) {
    for (final field in o.fields) {
      parseFieldAnnotations(field);
    }
  }

  void parseMethod(Method method) {
    for (final annotation in method.annotations) {
      annotation.parse();
    }
    method.annotations.removeWhere(_isAnnotationDisabled);
  }

  void parseFieldAnnotations(Field f) {
    for (final annotation in f.annotations) {
      annotation.parse();
    }
    f.annotations.removeWhere(_isAnnotationDisabled);
  }

  void parseEnumAnnotations(Enum e) {
    for (final annotation in e.annotations) {
      annotation.parseForEnum();
    }
    e.annotations.removeWhere(_isAnnotationDisabled);
    for (final value in e.values) {
      parseEnumValueAnnotation(value);
    }
    parseObjectBaseAnnotations(e);
  }

  void parseEnumValueAnnotation(EnumValue v) {
    for (final annotation in v.annotations) {
      annotation.parse();
    }
    v.annotations.removeWhere(_isAnnotationDisabled);
  }

  void parseUnionAnnotations(Union u) {
    for (final annotation in u.annotations) {
      annotation.parseForUnion();
    }
    u.annotations.removeWhere(_isAnnotationDisabled);
    parseObjectBaseAnnotations(u);
  }

  void processClass(Module module, Class c) {
    for (final annotation in [...c.annotations]) {
      final parsedAnnotation = annotation.parsed;
      final processor = classProcessors[parsedAnnotation.runtimeType];
      if (processor == null) {
        print('Warning: No handler for class annotation $annotation');
        continue;
      }
      try {
        processor.process(this, module, c, parsedAnnotation);
      } on Exception catch (e) {
        throw AnnotationProcessingException(annotation: annotation, reason: e);
      }
    }

    processClassFields(module, c);
  }

  void verifyClass(Module module, Class c) {
    final baseClass = c.baseClass;
    if (baseClass != null) {
      if (baseClass is! ObjectType) {
        throw StateError('Internal error');
      }
      final object = baseClass.resolvedObject;
      if (object is! Class) {
        throw FormatException(
          'Class ${c.name} extends ${object.name} which is not a class',
        );
      }

      if (!object.isExtendable) {
        throw FormatException(
          'Class ${c.name} extends ${object.name}, but ${object.name} is not '
          'marked as virtual or extendable',
        );
      }
    }

    final fields = <String, Class>{};
    for (final c in c.classAndSuperclasses) {
      for (final field in c.fields) {
        for (final fieldName in [field.name, ...field.aliases]) {
          final lookup = fields[fieldName];
          if (lookup != null) {
            throw FormatException(
              'Class ${lookup.name} defines a field named \'$fieldName\' which '
              'is already defined in ${c.name}',
            );
          }
          fields[fieldName] = c;
        }
      }
    }
  }

  void processClassFields(Module module, Class c) {
    for (final field in [...c.fields]) {
      processClassField(module, c, field);
    }
  }

  void processClassField(Module module, Class c, Field field) {
    if (commonKeywords.contains(field.name)) {
      throw FormatException(
        '\'${field.name}\' is a common keyword and cannot be used as a '
        'field name',
      );
    }

    for (final annotation in [...field.annotations]) {
      final parsedAnnotation = annotation.parsed;
      final processor = classFieldProcessors[parsedAnnotation.runtimeType];
      if (processor == null) {
        print('Warning: No handler for class field annotation $annotation');
        continue;
      }
      processor.process(this, module, c, field, parsedAnnotation);
    }
  }

  void processEnum(Module module, Enum e) {
    e.originalFields = [...e.fields];

    for (final annotation in [...e.annotations]) {
      final parsedAnnotation = annotation.parsed;
      final processor = enumProcessors[parsedAnnotation.runtimeType];
      if (processor == null) {
        print('Warning: No handler for enum annotation $annotation');
        continue;
      }
      try {
        processor.process(this, module, e, parsedAnnotation);
      } on Exception catch (e) {
        throw AnnotationProcessingException(annotation: annotation, reason: e);
      }
    }

    // Validate fields before annotation processing occurs, which can remove
    // fields.
    validateEnumValues(module, e);

    processEnumFields(module, e);
    processEnumValues(module, e);
  }

  void processEnumFields(Module module, Enum e) {
    for (final field in [...e.fields]) {
      processEnumField(module, e, field);
    }
  }

  void processEnumField(Module module, Enum e, Field field) {
    if (commonKeywords.contains(field.name)) {
      throw FormatException(
        '\'${field.name}\' is a common keyword and cannot be used as a '
        'field name',
      );
    }

    for (final annotation in [...field.annotations]) {
      final parsedAnnotation = annotation.parsed;
      final processor = enumFieldProcessors[parsedAnnotation.runtimeType];
      if (processor == null) {
        print('Warning: No handler for enum field annotation $annotation');
        continue;
      }
      processor.process(this, module, e, field, parsedAnnotation);
    }
  }

  void validateEnumValues(Module module, Enum e) {
    final validFieldNames = <String>{
      for (final field in e.fields) field.name,
    };

    for (final value in e.values) {
      value.fieldValues.when(
        none: () {},
        list: (fieldValues) {
          if (fieldValues.length != e.fields.length) {
            throw FormatException(
              '${e.name}.${value.name} needs ${e.fields.length} '
              'parameters, but ${fieldValues.length} were specified',
            );
          }
        },
        map: (fieldValuesMap) {
          for (final key in fieldValuesMap.keys) {
            if (!validFieldNames.contains(key)) {
              throw FormatException(
                '$key is not a valid field name in ${e.name}.${value.name}',
              );
            }
          }
        },
      );
    }
  }

  void processEnumValues(Module module, Enum e) {
    for (final value in [...e.values]) {
      processEnumValue(module, e, value);
    }
  }

  void processEnumValue(Module module, Enum e, EnumValue value) {
    if (commonKeywords.contains(value.name)) {
      throw FormatException(
        '\'${value.name}\' is a common keyword and cannot be used as an '
        'enum value',
      );
    }

    for (final annotation in [...value.annotations]) {
      final parsedAnnotation = annotation.parsed;
      final processor = enumValueProcessors[parsedAnnotation.runtimeType];
      if (processor == null) {
        print('Warning: No handler for enum value annotation $annotation');
        continue;
      }
      processor.process(this, module, e, value, parsedAnnotation);
    }
  }

  void processUnion(Module module, Union u) {
    for (final annotation in [...u.annotations]) {
      final parsedAnnotation = annotation.parsed;
      final processor = unionProcessors[parsedAnnotation.runtimeType];
      if (processor == null) {
        print('Warning: No handler for union annotation $annotation');
        continue;
      }
      try {
        processor.process(this, module, u, parsedAnnotation);
      } on Exception catch (e) {
        throw AnnotationProcessingException(annotation: annotation, reason: e);
      }
    }

    processUnionFields(module, u);
  }

  void processUnionFields(Module module, Union u) {
    for (final field in [...u.fields]) {
      processUnionField(module, u, field);
    }
  }

  void processUnionField(Module module, Union u, Field field) {
    if (commonKeywords.contains(field.name)) {
      throw FormatException(
        '\'${field.name}\' is a common keyword and cannot be used as a '
        'field name',
      );
    }

    for (final annotation in [...field.annotations]) {
      final parsedAnnotation = annotation.parsed;
      final processor = unionFieldProcessors[parsedAnnotation.runtimeType];
      if (processor == null) {
        print('Warning: No handler for union field annotation $annotation');
        continue;
      }
      processor.process(this, module, u, field, parsedAnnotation);
    }
  }

  @override
  void generateModule(StringBuffer buffer, Module module) {
    final generators = [...moduleGenerators]..sort(Generator.compare);

    for (final generator in generators) {
      generator.generate(this, buffer, module);
    }
  }

  @override
  void generateClass(StringBuffer buffer, Class c) {
    final generators = {
      ...?classGenerators[null],
      ...?classGenerators[c],
    }.toList()
      ..sort(Generator.compare);

    for (final generator in generators) {
      generator.generate(this, buffer, c);
    }
  }

  @override
  void generateEnum(StringBuffer buffer, Enum e) {
    final generators = {
      ...?enumGenerators[null],
      ...?enumGenerators[e],
    }.toList()
      ..sort(Generator.compare);

    for (final generator in generators) {
      generator.generate(this, buffer, e);
    }
  }

  @override
  void generateUnion(StringBuffer buffer, Union u) {
    final generators = {
      ...?unionGenerators[null],
      ...?unionGenerators[u],
    }.toList()
      ..sort(Generator.compare);

    for (final generator in generators) {
      generator.generate(this, buffer, u);
    }
  }

  @override
  void generateField(StringBuffer buffer, ObjectBase object, Field f) {
    final generators = {
      ...?fieldGenerators[null]?[null],
      ...?fieldGenerators[object]?[null],
      ...?fieldGenerators[object]?[f],
    }.toList()
      ..sort(Generator.compare);

    for (final generator in generators) {
      generator.generate(this, buffer, object, f);
    }
  }

  @override
  void generateMethod(StringBuffer buffer, ObjectBase object, Method m) {
    final generators = {
      ...?classMethodGenerators[null]?[null],
      ...?classMethodGenerators[object]?[null],
      ...?classMethodGenerators[object]?[m],
    }.toList()
      ..sort(Generator.compare);

    for (final generator in generators) {
      generator.generate(this, buffer, object, m);
    }
  }

  @override
  void generateEnumValue(StringBuffer buffer, Enum e, EnumValue v) {
    final generators = {
      ...?enumValueGenerators[null]?[null],
      ...?enumValueGenerators[e]?[null],
      ...?enumValueGenerators[e]?[v],
    }.toList()
      ..sort(Generator.compare);

    for (final generator in generators) {
      generator.generate(this, buffer, e, v);
    }
  }

  @override
  bool isConditionEnabled(jo.BoolOrCondition condition) {
    return condition.when(
      enabled: (value) => value,
      includedRoles: (includedRoles) => includedRoles.matches(roles),
      condition: (condition) {
        final included = condition.includedRoles.matches(roles);
        final excluded = condition.excludedRoles.matches(roles);
        if (included == excluded) {
          throw FormatException(
            'Condition for annotation has both included and excluded as '
            '$included',
          );
        }
        return included && !excluded;
      },
    );
  }

  bool _isAnnotationDisabled(Annotation annotation) =>
      !isConditionEnabled(annotation.parsed.enabled);
}

class AnnotationProcessingException implements Exception {
  AnnotationProcessingException({
    required this.annotation,
    required this.reason,
  });

  final Annotation annotation;
  final Exception reason;

  @override
  String toString() =>
      'Exception occurred while processing annotation $annotation: $reason';
}
