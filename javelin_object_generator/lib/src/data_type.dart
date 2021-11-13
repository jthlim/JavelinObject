import 'data_type.jo.dart';
import 'module.jo.dart';

export 'data_type.jo.dart';

extension ObjectDataTypeExtension on ObjectType {
  static final _resolvedObjectExpando = Expando<ObjectBase>();

  ObjectBase get resolvedObject => _resolvedObjectExpando[this]!;
  set resolvedObject(ObjectBase b) => _resolvedObjectExpando[this] = b;
}

extension ClassTypeExtension on ClassType {
  Class get resolvedClass => resolvedObject as Class;
}

extension DataTypeExtension on DataType {
  bool get isOptional => kind == DataTypeKind.optionalType;

  DataType get optional =>
      kind == DataTypeKind.optionalType ? this : DataType.optionalType(this);

  DataType get nonOptional => optionalTypeOrNull ?? this;

  bool get canReturnNull {
    if (isOptional) return true;

    final object = objectTypeOrNull?.resolvedObject;
    if (object == null) return false;

    return object is Union || object is Enum;
  }
}
