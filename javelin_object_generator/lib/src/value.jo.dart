// ** WARNING **
// This file is autogenerated by Javelin Object Compiler (joc).
// Do not edit it directly.
//
// ignore_for_file: annotate_overrides
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: directives_ordering
// ignore_for_file: prefer_const_constructors_in_immutables
// ignore_for_file: sort_constructors_first
// ignore_for_file: unused_import
import 'package:javelin_object/jo_internal.dart';

import 'data_type.jo.dart';
import 'void.jo.dart';

@immutable
class ClassObjectValue {
  const ClassObjectValue({
    required this.objectType,
    required this.parameters,
  });

  factory ClassObjectValue.fromString(String s) => ClassObjectValue.fromMap(fromJoText(s));

  factory ClassObjectValue.fromBytes(Uint8List bytes) => ClassObjectValue.fromJoFieldMap0(parseJoBinary(bytes));

  ClassObjectValue.fromJoFieldMap0(Map<int, JoFieldData> map)
    : objectType = _objectTypeFromJoFieldMap(map),
      parameters = _parametersFromJoFieldMap(map);

  ClassObjectValue.fromMap(Map<Object?, Object?> map)
    : objectType = _objectTypeFromMap(map),
      parameters = _parametersFromMap(map);

  final ObjectType objectType;
  final Map<String, Value> parameters;

  Uint8List toBytes() => encodeBytes().toBytes();

  JoBinaryEncoder encodeBytes([JoBinaryEncoder? $derivedEncoder]) {
    final encoder = JoBinaryEncoder();
    encoder.writeObject(0, objectType.encodeBytes(null, false));
    encoder.writeMap<String, Value>(1, parameters, (enc, e) => enc.writeString(e), (enc, e) {
        final objectEncoder = JoBinaryEncoder();
        e.encodeBytes(objectEncoder);
        enc.writeObject(objectEncoder);
      });
    return encoder;
  }

  Map<String, Object?> toMap() {
    final $objectType = objectType;
    final $parameters = parameters;

    return {
      'objectType': $objectType.toMap(false),
      'parameters': $parameters.map((k, v) => MapEntry(k, v.toMap())),
    };
  }

  @override
  String toString({bool pretty = true}) =>
    toJoText(toMap(), pretty: pretty);

  static ObjectType _objectTypeFromJoFieldMap(Map<int, JoFieldData> map) {
    final $objectType = map.bytesValue(0);
    return ObjectType.fromBytes($objectType!);
  }
  static Map<String, Value> _parametersFromJoFieldMap(Map<int, JoFieldData> map) =>
    map.mapValue(1, (fieldData) => fieldData.stringValue, (fieldData) => Value.fromJoFieldMapOrNull(fieldData.embeddedObject), true)!;

  static ObjectType _objectTypeFromMap(Map<Object?, Object?> map) {
    final lookup = map.joLookupValue<Map>(fieldName: 'objectType');
    return ObjectType.fromMap(lookup);
  }
  static Map<String, Value> _parametersFromMap(Map<Object?, Object?> map) {
    final lookup = map.joLookupValue<Map>(fieldName: 'parameters');
    return lookup.joMapNotNull((k) => k as String, (v) => Value.fromMapOrNull(v as Map));
  }
}

@immutable
class EnumObjectValue {
  const EnumObjectValue({
    required this.objectType,
    required this.valueName,
  });

  factory EnumObjectValue.fromString(String s) => EnumObjectValue.fromMap(fromJoText(s));

  factory EnumObjectValue.fromBytes(Uint8List bytes) => EnumObjectValue.fromJoFieldMap0(parseJoBinary(bytes));

  EnumObjectValue.fromJoFieldMap0(Map<int, JoFieldData> map)
    : objectType = _objectTypeFromJoFieldMap(map),
      valueName = _valueNameFromJoFieldMap(map);

  EnumObjectValue.fromMap(Map<Object?, Object?> map)
    : objectType = _objectTypeFromMap(map),
      valueName = _valueNameFromMap(map);

  final ObjectType objectType;
  final String valueName;

  Uint8List toBytes() => encodeBytes().toBytes();

  JoBinaryEncoder encodeBytes([JoBinaryEncoder? $derivedEncoder]) {
    final encoder = JoBinaryEncoder();
    encoder.writeObject(0, objectType.encodeBytes(null, false));
    encoder.writeString(1, valueName);
    return encoder;
  }

  Map<String, Object?> toMap() {
    final $objectType = objectType;
    final $valueName = valueName;

    return {
      'objectType': $objectType.toMap(false),
      'valueName': $valueName,
    };
  }

  @override
  String toString({bool pretty = true}) =>
    toJoText(toMap(), pretty: pretty);

  static ObjectType _objectTypeFromJoFieldMap(Map<int, JoFieldData> map) {
    final $objectType = map.bytesValue(0);
    return ObjectType.fromBytes($objectType!);
  }
  static String _valueNameFromJoFieldMap(Map<int, JoFieldData> map) =>
    map.stringValue(1)!;

  static ObjectType _objectTypeFromMap(Map<Object?, Object?> map) {
    final lookup = map.joLookupValue<Map>(fieldName: 'objectType');
    return ObjectType.fromMap(lookup);
  }
  static String _valueNameFromMap(Map<Object?, Object?> map) =>
    map.joLookupValue<String>(fieldName: 'valueName');
}

@immutable
class UnionObjectValue {
  const UnionObjectValue({
    required this.objectType,
    required this.activeElementName,
    this.value,
  });

  factory UnionObjectValue.fromString(String s) => UnionObjectValue.fromMap(fromJoText(s));

  factory UnionObjectValue.fromBytes(Uint8List bytes) => UnionObjectValue.fromJoFieldMap0(parseJoBinary(bytes));

  UnionObjectValue.fromJoFieldMap0(Map<int, JoFieldData> map)
    : objectType = _objectTypeFromJoFieldMap(map),
      activeElementName = _activeElementNameFromJoFieldMap(map),
      value = _valueFromJoFieldMap(map);

  UnionObjectValue.fromMap(Map<Object?, Object?> map)
    : objectType = _objectTypeFromMap(map),
      activeElementName = _activeElementNameFromMap(map),
      value = _valueFromMap(map);

  final ObjectType objectType;
  final String activeElementName;
  final Value? value;

  Uint8List toBytes() => encodeBytes().toBytes();

  JoBinaryEncoder encodeBytes([JoBinaryEncoder? $derivedEncoder]) {
    final encoder = JoBinaryEncoder();
    encoder.writeObject(0, objectType.encodeBytes(null, false));
    encoder.writeString(1, activeElementName);
    final $value = value;
    if ($value != null) {
      final $valueEncoder = JoBinaryEncoder();
      $value.encodeBytes($valueEncoder);
      encoder.writeObject(2, $valueEncoder);
    }
    return encoder;
  }

  Map<String, Object?> toMap() {
    final $objectType = objectType;
    final $activeElementName = activeElementName;
    final $value = value;

    return {
      'objectType': $objectType.toMap(false),
      'activeElementName': $activeElementName,
      if ($value != null)
        'value': $value.toMap(),
    };
  }

  @override
  String toString({bool pretty = true}) =>
    toJoText(toMap(), pretty: pretty);

  static ObjectType _objectTypeFromJoFieldMap(Map<int, JoFieldData> map) {
    final $objectType = map.bytesValue(0);
    return ObjectType.fromBytes($objectType!);
  }
  static String _activeElementNameFromJoFieldMap(Map<int, JoFieldData> map) =>
    map.stringValue(1)!;
  static Value? _valueFromJoFieldMap(Map<int, JoFieldData> map) {
    final $value = map.bytesValue(2);
    if ($value == null) return null;
    return Value.fromBytes($value);
  }

  static ObjectType _objectTypeFromMap(Map<Object?, Object?> map) {
    final lookup = map.joLookupValue<Map>(fieldName: 'objectType');
    return ObjectType.fromMap(lookup);
  }
  static String _activeElementNameFromMap(Map<Object?, Object?> map) =>
    map.joLookupValue<String>(fieldName: 'activeElementName');
  static Value? _valueFromMap(Map<Object?, Object?> map) {
    final lookup = map.joLookupValue<Map?>(fieldName: 'value');
    if (lookup == null) return null;
    return Value.fromMapOrNull(lookup);
  }
}

enum ValueType {
  newValue,
  nullValue,
  boolValue,
  intValue,
  doubleValue,
  stringValue,
  listValue,
  setValue,
  mapValue,
  classValue,
  enumValue,
  unionValue,
}

@immutable
class Value {
  const Value.newValue(Value newValue)
    : type = ValueType.newValue,
      _value = newValue;

  const Value.nullValue()
    : type = ValueType.nullValue,
      _value = const Void();

  const Value.boolValue(bool boolValue)
    : type = ValueType.boolValue,
      _value = boolValue;

  const Value.intValue(int intValue)
    : type = ValueType.intValue,
      _value = intValue;

  const Value.doubleValue(double doubleValue)
    : type = ValueType.doubleValue,
      _value = doubleValue;

  const Value.stringValue(String stringValue)
    : type = ValueType.stringValue,
      _value = stringValue;

  const Value.listValue(List<Value> listValue)
    : type = ValueType.listValue,
      _value = listValue;

  const Value.setValue(Set<Value> setValue)
    : type = ValueType.setValue,
      _value = setValue;

  const Value.mapValue(Map<Value, Value> mapValue)
    : type = ValueType.mapValue,
      _value = mapValue;

  const Value.classValue(ClassObjectValue classValue)
    : type = ValueType.classValue,
      _value = classValue;

  const Value.enumValue(EnumObjectValue enumValue)
    : type = ValueType.enumValue,
      _value = enumValue;

  const Value.unionValue(UnionObjectValue unionValue)
    : type = ValueType.unionValue,
      _value = unionValue;

  static Value? fromMapOrNull(Map<Object?, Object?> map) {
    final entries = map.entries;
    if (entries.length != 1) return null;
    final entry = entries.first;
    switch (entry.key) {
      case 'newValue':
        return _newValueFromValue(entry.value);
      case 'nullValue':
        return _nullValueFromValue(entry.value);
      case 'boolValue':
        return _boolValueFromValue(entry.value);
      case 'intValue':
        return _intValueFromValue(entry.value);
      case 'doubleValue':
        return _doubleValueFromValue(entry.value);
      case 'stringValue':
        return _stringValueFromValue(entry.value);
      case 'listValue':
        return _listValueFromValue(entry.value);
      case 'setValue':
        return _setValueFromValue(entry.value);
      case 'mapValue':
        return _mapValueFromValue(entry.value);
      case 'classValue':
        return _classValueFromValue(entry.value);
      case 'enumValue':
        return _enumValueFromValue(entry.value);
      case 'unionValue':
        return _unionValueFromValue(entry.value);
      default:
        return null;
    }
  }

  factory Value.fromBytes(Uint8List bytes) =>
    Value.fromJoFieldMapOrNull(parseJoBinary(bytes))!;

  static Value? fromJoFieldMapOrNull(Map<int, JoFieldData> map) {
    final entries = map.entries;
    if (entries.length != 1) return null;
    final entry = entries.first;
    switch (entry.key) {
      case 0:
        return _newValueFromJoField(entry.value);
      case 1:
        return _nullValueFromJoField();
      case 2:
        return _boolValueFromJoField(entry.value);
      case 3:
        return _intValueFromJoField(entry.value);
      case 4:
        return _doubleValueFromJoField(entry.value);
      case 5:
        return _stringValueFromJoField(entry.value);
      case 6:
        return _listValueFromJoField(entry.value);
      case 7:
        return _setValueFromJoField(entry.value);
      case 8:
        return _mapValueFromJoField(entry.value);
      case 9:
        return _classValueFromJoField(entry.value);
      case 10:
        return _enumValueFromJoField(entry.value);
      case 11:
        return _unionValueFromJoField(entry.value);
      default:
        return null;
    }
  }

  factory Value.fromString(String s) =>
    Value.fromMapOrNull(fromJoText(s))!;

  T when<T>({
    required T Function(Value) newValue,
    required T Function() nullValue,
    required T Function(bool) boolValue,
    required T Function(int) intValue,
    required T Function(double) doubleValue,
    required T Function(String) stringValue,
    required T Function(List<Value>) listValue,
    required T Function(Set<Value>) setValue,
    required T Function(Map<Value, Value>) mapValue,
    required T Function(ClassObjectValue) classValue,
    required T Function(EnumObjectValue) enumValue,
    required T Function(UnionObjectValue) unionValue,
  }) {
    switch (type) {
      case ValueType.newValue:
        return newValue(_value as Value);
      case ValueType.nullValue:
        return nullValue();
      case ValueType.boolValue:
        return boolValue(_value as bool);
      case ValueType.intValue:
        return intValue(_value as int);
      case ValueType.doubleValue:
        return doubleValue(_value as double);
      case ValueType.stringValue:
        return stringValue(_value as String);
      case ValueType.listValue:
        return listValue(_value as List<Value>);
      case ValueType.setValue:
        return setValue(_value as Set<Value>);
      case ValueType.mapValue:
        return mapValue(_value as Map<Value, Value>);
      case ValueType.classValue:
        return classValue(_value as ClassObjectValue);
      case ValueType.enumValue:
        return enumValue(_value as EnumObjectValue);
      case ValueType.unionValue:
        return unionValue(_value as UnionObjectValue);
    }
  }

  final ValueType type;
  final Object _value;

  Value get newValue => newValueOrNull!;
  Value? get newValueOrNull =>
    type == ValueType.newValue
      ? _value as Value
      : null;

  Void get nullValue => nullValueOrNull!;
  Void? get nullValueOrNull =>
    type == ValueType.nullValue
      ? _value as Void
      : null;

  bool get boolValue => boolValueOrNull!;
  bool? get boolValueOrNull =>
    type == ValueType.boolValue
      ? _value as bool
      : null;

  int get intValue => intValueOrNull!;
  int? get intValueOrNull =>
    type == ValueType.intValue
      ? _value as int
      : null;

  double get doubleValue => doubleValueOrNull!;
  double? get doubleValueOrNull =>
    type == ValueType.doubleValue
      ? _value as double
      : null;

  String get stringValue => stringValueOrNull!;
  String? get stringValueOrNull =>
    type == ValueType.stringValue
      ? _value as String
      : null;

  List<Value> get listValue => listValueOrNull!;
  List<Value>? get listValueOrNull =>
    type == ValueType.listValue
      ? _value as List<Value>
      : null;

  Set<Value> get setValue => setValueOrNull!;
  Set<Value>? get setValueOrNull =>
    type == ValueType.setValue
      ? _value as Set<Value>
      : null;

  Map<Value, Value> get mapValue => mapValueOrNull!;
  Map<Value, Value>? get mapValueOrNull =>
    type == ValueType.mapValue
      ? _value as Map<Value, Value>
      : null;

  ClassObjectValue get classValue => classValueOrNull!;
  ClassObjectValue? get classValueOrNull =>
    type == ValueType.classValue
      ? _value as ClassObjectValue
      : null;

  EnumObjectValue get enumValue => enumValueOrNull!;
  EnumObjectValue? get enumValueOrNull =>
    type == ValueType.enumValue
      ? _value as EnumObjectValue
      : null;

  UnionObjectValue get unionValue => unionValueOrNull!;
  UnionObjectValue? get unionValueOrNull =>
    type == ValueType.unionValue
      ? _value as UnionObjectValue
      : null;

  Uint8List toBytes() {
    final encoder = JoBinaryEncoder();
    encodeBytes(encoder);
    return encoder.toBytes();
  }

  void encodeBytes(JoBinaryEncoder encoder) {
    switch (type) {
     case ValueType.newValue:
       final $newValueEncoder = JoBinaryEncoder();
       newValue.encodeBytes($newValueEncoder);
       encoder.writeObject(0, $newValueEncoder);
       break;
     case ValueType.nullValue:
       encoder.writeObject(1, nullValue.encodeBytes());
       break;
     case ValueType.boolValue:
       encoder.writeBool(2, boolValue);
       break;
     case ValueType.intValue:
       encoder.writeInt(3, intValue);
       break;
     case ValueType.doubleValue:
       encoder.writeDouble(4, doubleValue);
       break;
     case ValueType.stringValue:
       encoder.writeString(5, stringValue);
       break;
     case ValueType.listValue:
       encoder.writeIterable<Value>(6, listValue, (enc, e) {
        final objectEncoder = JoBinaryEncoder();
        e.encodeBytes(objectEncoder);
        enc.writeObject(objectEncoder);
      });
       break;
     case ValueType.setValue:
       encoder.writeIterable<Value>(7, setValue, (enc, e) {
        final objectEncoder = JoBinaryEncoder();
        e.encodeBytes(objectEncoder);
        enc.writeObject(objectEncoder);
      });
       break;
     case ValueType.mapValue:
       encoder.writeMap<Value, Value>(8, mapValue, (enc, e) {
        final objectEncoder = JoBinaryEncoder();
        e.encodeBytes(objectEncoder);
        enc.writeObject(objectEncoder);
      }, (enc, e) {
        final objectEncoder = JoBinaryEncoder();
        e.encodeBytes(objectEncoder);
        enc.writeObject(objectEncoder);
      });
       break;
     case ValueType.classValue:
       encoder.writeObject(9, classValue.encodeBytes());
       break;
     case ValueType.enumValue:
       encoder.writeObject(10, enumValue.encodeBytes());
       break;
     case ValueType.unionValue:
       encoder.writeObject(11, unionValue.encodeBytes());
       break;
    }
  }

  Map<String, Object?> toMap() {
    switch (type) {
      case ValueType.newValue:
        final $newValue = _value as Value;
        return { 'newValue': $newValue.toMap() };
      case ValueType.nullValue:
        final $nullValue = _value as Void;
        return { 'nullValue': $nullValue.toMap() };
      case ValueType.boolValue:
        final $boolValue = _value as bool;
        return { 'boolValue': $boolValue };
      case ValueType.intValue:
        final $intValue = _value as int;
        return { 'intValue': $intValue };
      case ValueType.doubleValue:
        final $doubleValue = _value as double;
        return { 'doubleValue': $doubleValue };
      case ValueType.stringValue:
        final $stringValue = _value as String;
        return { 'stringValue': $stringValue };
      case ValueType.listValue:
        final $listValue = _value as List<Value>;
        return { 'listValue': $listValue.map((e) => e.toMap()).toList() };
      case ValueType.setValue:
        final $setValue = _value as Set<Value>;
        return { 'setValue': $setValue.map((e) => e.toMap()).toSet() };
      case ValueType.mapValue:
        final $mapValue = _value as Map<Value, Value>;
        return { 'mapValue': $mapValue.map((k, v) => MapEntry(k.toMap(), v.toMap())) };
      case ValueType.classValue:
        final $classValue = _value as ClassObjectValue;
        return { 'classValue': $classValue.toMap() };
      case ValueType.enumValue:
        final $enumValue = _value as EnumObjectValue;
        return { 'enumValue': $enumValue.toMap() };
      case ValueType.unionValue:
        final $unionValue = _value as UnionObjectValue;
        return { 'unionValue': $unionValue.toMap() };
    }
  }
  @override
  String toString({bool pretty = true}) =>
    toJoText(toMap(), pretty: pretty);

  static Value? _newValueFromValue(Object? value) {
    if (value is! Map) return null;
    final unionValue = Value.fromMapOrNull(value);
    if (unionValue == null) return null;
    return Value.newValue(unionValue);
   }
  static Value _nullValueFromValue(Object? value) =>
    const Value.nullValue();
  static Value _boolValueFromValue(Object? value) =>
    Value.boolValue(value as bool);
  static Value _intValueFromValue(Object? value) =>
    Value.intValue(value as int);
  static Value _doubleValueFromValue(Object? value) =>
    Value.doubleValue(value as double);
  static Value _stringValueFromValue(Object? value) =>
    Value.stringValue(value as String);
  static Value _listValueFromValue(Object? value) =>
    Value.listValue((value as Iterable).joMapNotNull((e) => Value.fromMapOrNull(e as Map)).toList());
  static Value _setValueFromValue(Object? value) =>
    Value.setValue((value as Iterable).joMapNotNull((e) => Value.fromMapOrNull(e as Map)).toSet());
  static Value _mapValueFromValue(Object? value) =>
    Value.mapValue((value as Map).joMapNotNull((k) => Value.fromMapOrNull(k as Map), (v) => Value.fromMapOrNull(v as Map)));
  static Value _classValueFromValue(Object? value) =>
    Value.classValue(ClassObjectValue.fromMap(value as Map));
  static Value _enumValueFromValue(Object? value) =>
    Value.enumValue(EnumObjectValue.fromMap(value as Map));
  static Value _unionValueFromValue(Object? value) =>
    Value.unionValue(UnionObjectValue.fromMap(value as Map));

  static Value? _newValueFromJoField(JoFieldData data) {
    final result = Value.fromJoFieldMapOrNull(data.embeddedObject);
    if (result == null) return null;
    return Value.newValue(result);
  }
  static Value _nullValueFromJoField() =>
    const Value.nullValue();
  static Value _boolValueFromJoField(JoFieldData data) =>
    Value.boolValue(data.boolValue);
  static Value _intValueFromJoField(JoFieldData data) =>
    Value.intValue(data.intValue);
  static Value _doubleValueFromJoField(JoFieldData data) =>
    Value.doubleValue(data.doubleValue);
  static Value _stringValueFromJoField(JoFieldData data) =>
    Value.stringValue(data.stringValue);
  static Value _listValueFromJoField(JoFieldData data) =>
    Value.listValue(data.listValue((fieldData) => Value.fromJoFieldMapOrNull(fieldData.embeddedObject), true));
  static Value _setValueFromJoField(JoFieldData data) =>
    Value.setValue(data.setValue((fieldData) => Value.fromJoFieldMapOrNull(fieldData.embeddedObject), true));
  static Value _mapValueFromJoField(JoFieldData data) =>
    Value.mapValue(data.mapValue((fieldData) => Value.fromJoFieldMapOrNull(fieldData.embeddedObject), (fieldData) => Value.fromJoFieldMapOrNull(fieldData.embeddedObject), true));
  static Value _classValueFromJoField(JoFieldData data) =>
    Value.classValue(ClassObjectValue.fromJoFieldMap0(data.embeddedObject));
  static Value _enumValueFromJoField(JoFieldData data) =>
    Value.enumValue(EnumObjectValue.fromJoFieldMap0(data.embeddedObject));
  static Value _unionValueFromJoField(JoFieldData data) =>
    Value.unionValue(UnionObjectValue.fromJoFieldMap0(data.embeddedObject));
}

void joRegister() {}