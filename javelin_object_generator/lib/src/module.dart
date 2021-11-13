import 'data_type.dart';
import 'module.jo.dart';

export 'module.jo.dart';

extension ClassExtension on Class {
  Map<Field, Class> get allFields {
    final result = <Field, Class>{};
    _gatherAllFields(this, result);
    return result;
  }

  bool get hasVirtualFactory {
    var cls = this;
    for (;;) {
      if (cls.isVirtual) return true;
      final baseClass = cls.baseClass;
      if (baseClass == null) return false;
      cls = baseClass.resolvedClass;
    }
  }

  bool get hasSuperclass => baseClass != null;

  bool get canDefaultConstruct {
    for (final c in classAndSuperclasses) {
      for (final f in c.fields) {
        if (f.type.isOptional) continue;
        if (f.defaultValue != null) continue;
        return false;
      }
    }
    return true;
  }

  Class get rootClass => superclasses.last;

  bool get hasSuperclassMembers => superclasses.any((c) => c.fields.isNotEmpty);

  int get depth => superclasses.length;

  Iterable<Class> get superclasses sync* {
    var c = this;
    for (;;) {
      final baseClass = c.baseClass;
      if (baseClass == null) return;

      c = baseClass.resolvedClass;
      yield c;
    }
  }

  Iterable<Class> get classAndSuperclasses sync* {
    var c = this;
    for (;;) {
      yield c;

      final baseClass = c.baseClass;
      if (baseClass == null) return;

      c = baseClass.resolvedClass;
    }
  }

  static void _gatherAllFields(Class c, Map<Field, Class> fields) {
    for (final cls in c.classAndSuperclasses.toList().reversed) {
      for (final field in cls.fields) {
        fields[field] = cls;
      }
    }
  }
}

extension EnumExtension on Enum {
  static final _originalFieldsExpando = Expando<List<Field>>();

  List<Field> get originalFields {
    final parsedAnnotation = _originalFieldsExpando[this];
    if (parsedAnnotation == null) {
      throw StateError('Internal error -- no field names set for $name.');
    }
    return parsedAnnotation;
  }

  set originalFields(List<Field> values) =>
      _originalFieldsExpando[this] = values;
}
