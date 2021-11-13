import '../data_type.dart';
import '../module.dart';

extension DartModuleExtension on Module {
  static final _dartModuleExpando = Expando<_DartModule>();

  List<String> get dartRegistration => _dartData.registration;
  Set<String> get dartPlaceholderImplements => _dartData.placeholderImplements;

  _DartModule get _dartData {
    var dartData = _dartModuleExpando[this];
    if (dartData == null) {
      dartData = _DartModule();
      _dartModuleExpando[this] = dartData;
    }
    return dartData;
  }
}

class _DartModule {
  final registration = <String>[];
  final placeholderImplements = <String>{};
}

extension DartObjectBaseExtension on ObjectBase {
  static final _dartObjectExpando = Expando<_DartObjectBase>();

  Set<String> get dartAnnotations => _dartData.dartAnnotations;
  Set<String> get dartInterfaceNames => _dartData.interfaceNames;

  _DartObjectBase get _dartData {
    var dartData = _dartObjectExpando[this];
    if (dartData == null) {
      dartData = _DartObjectBase();
      _dartObjectExpando[this] = dartData;
    }
    return dartData;
  }
}

class _DartObjectBase {
  final dartAnnotations = <String>{};
  final interfaceNames = <String>{};
}

extension DartFieldExtension on Field {
  static final _dartFieldExpando = Expando<_DartField>();

  Set<String> get dartAnnotations => _dartData.dartAnnotations;

  _DartField get _dartData {
    var dartData = _dartFieldExpando[this];
    if (dartData == null) {
      dartData = _DartField();
      _dartFieldExpando[this] = dartData;
    }
    return dartData;
  }

  String get storageName {
    if (defaultValue != null && type.isOptional) {
      return '_$name';
    }
    return name;
  }
}

class _DartField {
  final dartAnnotations = <String>{};
}

extension DartEnumValueExtension on EnumValue {
  static final _dartEnumValueExpando = Expando<_DartEnumValue>();

  Set<String> get dartAnnotations => _dartData.dartAnnotations;

  _DartEnumValue get _dartData {
    var dartData = _dartEnumValueExpando[this];
    if (dartData == null) {
      dartData = _DartEnumValue();
      _dartEnumValueExpando[this] = dartData;
    }
    return dartData;
  }
}

class _DartEnumValue {
  final dartAnnotations = <String>{};
}

extension FieldListExtension on List<Field> {
  void validateAllFieldsHaveIds(String identifier) {
    final ids = <int, Field>{};
    for (final field in this) {
      final fieldId = field.fieldId;
      if (fieldId == null) {
        throw FormatException(
          'Cannot serialize $identifier to binary as field ${field.name} has '
          'not been assigned a fieldId',
        );
      }
      if (ids.containsKey(fieldId)) {
        throw FormatException(
          'Cannot serialize $identifier to binary as field ${field.name} has '
          'a conflicting id with field ${ids[field.fieldId]!.name}',
        );
      }
      ids[fieldId] = field;
    }
  }
}
