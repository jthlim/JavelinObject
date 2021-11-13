import 'data_type.dart';
import 'module.dart';
import 'token.dart';
import 'value.jo.dart';

mixin DataTypeResolverMixin {
  final typeMap = <String, ObjectBase>{};

  void gatherDataTypes(Module module) {
    final processedModules = <Module>{};
    _gatherDataTypes(module, processedModules);
  }

  void _gatherDataTypes(Module module, Set<Module> processedModules) {
    if (processedModules.contains(module)) return;
    processedModules.add(module);

    for (final import in module.imports) {
      _gatherDataTypes(import, processedModules);
    }

    for (final c in module.classes) {
      final fullyQualifiedName = _fullyQualifiedName(module, c.name);
      if (typeMap.containsKey(fullyQualifiedName)) {
        throw FormatException('${c.name} already defined');
      }
      typeMap[fullyQualifiedName] = c;
    }

    for (final e in module.enums) {
      final fullyQualifiedName = _fullyQualifiedName(module, e.name);
      if (typeMap.containsKey(fullyQualifiedName)) {
        throw FormatException('${e.name} already defined');
      }
      typeMap[fullyQualifiedName] = e;
    }

    for (final u in module.unions) {
      final fullyQualifiedName = _fullyQualifiedName(module, u.name);
      if (typeMap.containsKey(fullyQualifiedName)) {
        throw FormatException('${u.name} already defined');
      }
      typeMap[fullyQualifiedName] = u;
    }
  }

  void resolveDataTypes(Module module) {
    final processedModules = <Module>{};
    _resolveDataTypes(module, processedModules);
  }

  void _resolveDataTypes(Module module, Set<Module> processedModules) {
    if (processedModules.contains(module)) return;
    processedModules.add(module);

    for (final import in module.imports) {
      _resolveDataTypes(import, processedModules);
    }

    for (final c in module.classes) {
      _resolveClassDataTypes(module, c);
    }
    for (final e in module.enums) {
      _resolveEnumDataTypes(module, e);
    }
    for (final u in module.unions) {
      _resolveUnionDataTypes(module, u);
    }
  }

  void _resolveClassDataTypes(Module module, Class c) {
    try {
      final baseClass = c.baseClass;
      if (baseClass != null) {
        _resolveObjectDataType(module, baseClass);
        if (baseClass.resolvedObject is! Class) {
          throw FormatException('Invalid base class: ${baseClass.objectName}');
        }
      }
      for (final f in c.fields) {
        _resolveDataType(module, f.type);
        _resolveValue(module, f.defaultValue);
      }
    } on FormatException catch (e) {
      final message = e.message;
      throw FormatException(
        '$message while validating class ${c.name} '
        '${c.nameToken.locator(module.filename)}',
      );
    }
  }

  void _resolveUnionDataTypes(Module module, Union u) {
    try {
      for (final f in u.fields) {
        _resolveDataType(module, f.type);
        _resolveValue(module, f.defaultValue);
      }
    } on FormatException catch (e) {
      final message = e.message;
      throw FormatException(
        '$message while validating union ${u.name} '
        '${u.nameToken.locator(module.filename)}',
      );
    }
  }

  void _resolveEnumDataTypes(Module module, Enum e) {
    try {
      for (final f in e.fields) {
        _resolveDataType(module, f.type);
      }
    } on FormatException catch (ex) {
      final message = ex.message;
      throw FormatException(
        '$message while validating enum ${e.name} '
        '${e.nameToken.locator(module.filename)}',
      );
    }
  }

  void _resolveDataType(Module module, DataType dataType) {
    switch (dataType.kind) {
      case DataTypeKind.optionalType:
        _resolveDataType(module, dataType.optionalType);
        return;

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
      case DataTypeKind.bytesType:
        return;

      case DataTypeKind.listType:
        _resolveDataType(module, dataType.listType);
        return;

      case DataTypeKind.setType:
        _resolveDataType(module, dataType.setType);
        return;

      case DataTypeKind.mapType:
        _resolveDataType(module, dataType.mapType.keyType);
        _resolveDataType(module, dataType.mapType.valueType);
        return;

      case DataTypeKind.objectType:
        _resolveObjectDataType(module, dataType.objectType);
        return;
    }
  }

  void _resolveObjectDataType(Module module, ObjectType objectDataType) {
    final objectName = objectDataType.objectName;
    final resolvedObject = resolveObject(module, objectName);
    if (resolvedObject == null) {
      throw FormatException(
        'Unable to resolve object name $objectName '
        '${objectDataType.token.locator(module.filename)}.\n'
        'Internal supported types are: Object, Bool, Int8, Uint8, Int32, '
        'Uint32, Int64, Uint64, Float, Double, Bytes, String, Set<T>, '
        'List<T> and Map<K, V>.',
      );
    }
    objectDataType.resolvedObject = resolvedObject;
    return;
  }

  void _resolveValue(Module module, Value? value) {
    if (value == null) return;
    switch (value.type) {
      case ValueType.newValue:
        _resolveValue(module, value.newValue);
        break;
      case ValueType.nullValue:
      case ValueType.boolValue:
      case ValueType.intValue:
      case ValueType.doubleValue:
      case ValueType.stringValue:
        break;
      case ValueType.listValue:
        for (final v in value.listValue) {
          _resolveValue(module, v);
        }
        break;
      case ValueType.setValue:
        for (final v in value.setValue) {
          _resolveValue(module, v);
        }
        break;
      case ValueType.mapValue:
        value.mapValue.forEach((k, v) {
          _resolveValue(module, k);
          _resolveValue(module, v);
        });
        break;
      case ValueType.classValue:
        _resolveObjectDataType(module, value.classValue.objectType);
        break;
      case ValueType.enumValue:
        _resolveObjectDataType(module, value.enumValue.objectType);
        break;
      case ValueType.unionValue:
        _resolveObjectDataType(module, value.unionValue.objectType);
        break;
    }
  }

  ObjectBase? resolveObject(Module module, String name) =>
      typeMap[_fullyQualifiedName(module, name)] ?? typeMap[name];

  static String _fullyQualifiedName(Module module, String name) {
    return [...module.package.packageParts, name].join('.');
  }
}
