import 'package:collection/collection.dart';

import '../data_type.dart';
import '../module.dart';
import 'annotation_factory.dart';
import 'annotations.jo.dart';

extension AnnotationListExtension on List<Annotation> {
  List<T> annotationsOfType<T extends ParsedAnnotation>() {
    final result = <T>[];
    for (final annotation in this) {
      final parsed = annotation.parsed;
      if (parsed is T) result.add(parsed);
    }
    return result;
  }

  bool containsAnnotation<T extends ParsedAnnotation>() =>
      any((e) => e.parsed is T);
}

extension ParsedAnnotationExtension on Annotation {
  static final _parsedExpando = Expando<ParsedAnnotation>();

  ParsedAnnotation get parsed {
    final parsedAnnotation = _parsedExpando[this];
    if (parsedAnnotation == null) {
      throw StateError('Internal exception $name has not been parsed yet.');
    }
    return parsedAnnotation;
  }

  void parse() {
    _parsedExpando[this] = createAnnotation(name, parameters);
  }

  void parseForClass() {
    _parsedExpando[this] = createClassAnnotation(name, parameters);
  }

  void parseForEnum() {
    _parsedExpando[this] = createEnumAnnotation(name, parameters);
  }

  void parseForUnion() {
    _parsedExpando[this] = createUnionAnnotation(name, parameters);
  }
}

extension ObjectBaseExtension on ObjectBase {
  bool get isImmutable {
    if (this is Enum) return true;

    var o = this;
    for (;;) {
      if (o.annotations.containsAnnotation<Immutable>()) return true;

      if (o is! Class) break;
      final baseClass = o.baseClass;
      if (baseClass == null) break;

      o = baseClass.resolvedObject;
    }
    return false;
  }
}

extension ClassExtension on Class {
  bool get isAbstract => annotations.containsAnnotation<Abstract>();

  int get derivedFieldId {
    final convert = annotations.annotationsOfType<ConvertClass>();

    for (final c in convert) {
      final derivedFieldId = c.derivedFieldId;
      if (derivedFieldId != null) return derivedFieldId;
    }
    return 0;
  }

  int get typeId {
    final convert = annotations.annotationsOfType<ConvertClass>();

    for (final c in convert) {
      final typeId = c.typeId;
      if (typeId != null) return typeId;
    }

    throw FormatException(
      'Class $name does not define a typeId in @Convert which is necessary to '
      'serialize the object',
    );
  }

  int get typeIdFieldId {
    final convert = annotations.annotationsOfType<ConvertClass>();

    for (final c in convert) {
      final typeIdFieldId = c.typeIdFieldId;
      if (typeIdFieldId != null) return typeIdFieldId;
    }

    return 1;
  }

  /// Returns all of the derived fieldIds with [0] being the derivedFieldId for
  /// the root class.
  List<int> get derivedFieldIds {
    final derivedFieldIds = <int>[];

    for (final cls in superclasses) {
      derivedFieldIds.add(cls.derivedFieldId);
    }
    return derivedFieldIds.reversed.toList();
  }

  String get typeName {
    final convert = annotations.annotationsOfType<ConvertClass>();

    for (final c in convert) {
      final typeName = c.typeName;
      if (typeName != null) return typeName;
    }
    return name;
  }

  String get typeKey {
    final convert = annotations.annotationsOfType<ConvertClass>();

    for (final c in convert) {
      final typeKey = c.typeKey;
      if (typeKey != null) return typeKey;
    }
    return '\$t';
  }

  String get jsonTypeName {
    final convert = annotations.annotationsOfType<ConvertClass>();

    for (final c in convert) {
      final jsonTypeName = c.jsonTypeName;
      if (jsonTypeName != null) return jsonTypeName;
    }
    return typeName;
  }

  String get jsonTypeKey {
    final convert = annotations.annotationsOfType<ConvertClass>();

    for (final c in convert) {
      final jsonTypeKey = c.jsonTypeKey;
      if (jsonTypeKey != null) return jsonTypeKey;
    }
    return '\$t';
  }
}

extension EnumExtension on Enum {
  bool get hasJsonAlias =>
      values.any((f) => f.annotations.containsAnnotation<JsonAlias>());
}

extension FieldExtension on Field {
  bool get isImmutable => annotations.containsAnnotation<Immutable>();

  bool get canUseParameterlessConstructor {
    final objectType = type.objectTypeOrNull;
    if (objectType == null) return false;

    final object = objectType.resolvedObject;
    if (object is! Class) return false;

    if (!object.isImmutable) return false;

    if (object.fields.isNotEmpty) return false;
    if (object.hasSuperclassMembers) return false;

    return true;
  }

  Set<String> get aliases {
    final aliases = <String>{};

    for (final annotation in annotations.annotationsOfType<Alias>()) {
      aliases.add(annotation.alias);
    }

    return aliases;
  }

  /// Returns all JsonAlias annotations, or the current name if none are
  /// present.
  ///
  /// This is different from [aliases] which only returns the annotations.
  Set<String> get jsonAliases {
    final aliases = <String>{};

    for (final annotation in annotations.annotationsOfType<JsonAlias>()) {
      aliases.add(annotation.alias);
    }

    if (aliases.isEmpty) {
      aliases.add(name);
    }

    return aliases;
  }
}

extension EnumValueExtension on EnumValue {
  Set<String> get aliases {
    final aliases = <String>{};

    for (final annotation in annotations.annotationsOfType<Alias>()) {
      aliases.add(annotation.alias);
    }

    return aliases;
  }

  /// Returns all JsonAlias annotations, or the current name if none are
  /// present.
  ///
  /// This is different from [aliases] which only returns the annotations.
  Set<String> get jsonAliases {
    final aliases = <String>{};

    for (final annotation in annotations.annotationsOfType<JsonAlias>()) {
      aliases.add(annotation.alias);
    }

    if (aliases.isEmpty) {
      aliases.add(name);
    }

    return aliases;
  }
}

extension UnionExtension on Union {
  String get activeElementClassName {
    final activeElementAnnotations =
        annotations.annotationsOfType<ActiveElement>();
    final activeElementAnnotation = activeElementAnnotations.firstOrNull;
    if (activeElementAnnotation != null) {
      final className = activeElementAnnotation.className;
      if (className != null) {
        return className;
      }
    }

    return '${name}_ActiveElement';
  }

  String get activeElementFieldName {
    final activeElementAnnotations =
        annotations.annotationsOfType<ActiveElement>();
    final activeElementAnnotation = activeElementAnnotations.firstOrNull;
    if (activeElementAnnotation != null) {
      final fieldName = activeElementAnnotation.fieldName;
      if (fieldName != null) {
        return fieldName;
      }
    }

    return 'activeElement';
  }
}
