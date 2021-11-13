import 'dart:convert';
import 'dart:typed_data';

import 'package:javelin_object/src/jo_containers.dart';

Map<int, JoFieldData> parseJoBinary(Uint8List bytes) =>
    JoBinaryDecoder(bytes).decode();

class JoFieldData {
  const JoFieldData({
    required this.constantId,
    required this.length,
    required this.dataOffset,
    this.data,
  });

  final int constantId;
  final int length;
  final int dataOffset;
  final ByteData? data;

  static final _emptyBytes = Uint8List(0);

  T? optionalValue<T>(T? Function(JoFieldData) factory) {
    if (length == 0 && constantId == 0) return null;

    return factory(_collection.first);
  }

  bool get boolValue {
    if (length != 0) {
      throw StateError('Invalid bool length $length');
    }
    switch (constantId) {
      case 0:
        return false;
      case 1:
        return true;
      default:
        throw StateError('Invalid bool constant $constantId');
    }
  }

  int get uintValue {
    if (length == 0) return constantId;
    return _rawIntValue;
  }

  int get intValue {
    if (length == 0) return _unzigzag(constantId);
    return _unzigzag(_rawIntValue);
  }

  double get doubleValue {
    switch (length) {
      case 0:
        return _unzigzag(constantId).toDouble();
      case 1:
        final bits = data!.getUint8(dataOffset);
        final exponent = ((bits >> 4) & 7) + 124;
        final binary32 =
            ((bits & 0x80) << 24) | (exponent << 23) | ((bits & 0xf) << 19);
        _scratchpad.setUint32(0, binary32, Endian.little);
        return _scratchpad.getFloat32(0, Endian.little);
      case 2:
        final bits = data!.getUint16(dataOffset, Endian.little);
        final exponent = ((bits >> 10) & 0x1f) + 112;
        final binary32 =
            ((bits & 0x8000) << 16) | (exponent << 23) | ((bits & 0x3ff) << 13);
        _scratchpad.setUint32(0, binary32, Endian.little);
        return _scratchpad.getFloat32(0, Endian.little);
      case 4:
        return data!.getFloat32(dataOffset, Endian.little);
      case 8:
        return data!.getFloat64(dataOffset, Endian.little);
      default:
        throw StateError('Invalid double length $length');
    }
  }

  Uint8List get bytesValue {
    if (length == 0) {
      if (constantId == 0) return _emptyBytes;
      return Uint8List(1)..[0] = constantId - 1;
    }

    final data = this.data!;
    return data.buffer.asUint8List(dataOffset, length);
  }

  String get stringValue {
    if (length == 0) {
      if (constantId == 0) return '';
      return String.fromCharCode(constantId - 1);
    }

    final data = this.data!;
    final bytes = data.buffer.asUint8List(dataOffset, length);

    return utf8.decode(bytes);
  }

  List<T> listValue<T>(T? Function(JoFieldData) factory, bool immutable) {
    if (length == 0 && constantId == 0) {
      return immutable ? const JoImmutableList([]) : [];
    }

    final result = <T>[];
    for (final object in _collection) {
      final element = factory(object);
      if (element != null) result.add(element);
    }
    return immutable ? JoImmutableList(result) : result;
  }

  Set<T> setValue<T>(T? Function(JoFieldData) factory, bool immutable) {
    if (length == 0 && constantId == 0) {
      return immutable ? const JoImmutableSet({}) : {};
    }

    final result = <T>{};
    for (final object in _collection) {
      final element = factory(object);
      if (element != null) result.add(element);
    }
    return immutable ? JoImmutableSet(result) : result;
  }

  Map<K, V> mapValue<K, V>(
    K? Function(JoFieldData) keyFactory,
    V? Function(JoFieldData) valueFactory,
    bool immutable,
  ) {
    final JoBinaryFieldlessDecoder decoder;

    if (length == 0) {
      if (constantId == 0) {
        return immutable ? const JoImmutableMap({}) : {};
      }

      final byte1 = (constantId - 1) % 14;
      final byte2 = (constantId - 1) ~/ 14;

      decoder = JoBinaryFieldlessDecoder(Uint8List.fromList([byte1, byte2]));
    } else {
      decoder = JoBinaryFieldlessDecoder.byteData(data!, dataOffset, length);
    }

    final objects = decoder.decode();
    final objectCount = objects.length;
    final result = <K, V>{};
    for (var i = 0; i < objectCount; i += 2) {
      final key = keyFactory(objects[i]);
      final value = valueFactory(objects[i + 1]);
      if (key != null && value != null) {
        result[key] = value;
      }
    }

    return immutable ? JoImmutableMap(result) : result;
  }

  Map<int, JoFieldData> get embeddedObject {
    final JoBinaryDecoder decoder;
    if (length == 0) {
      if (constantId == 0) return const {};

      decoder = JoBinaryDecoder(Uint8List.fromList([constantId - 1]));
    } else {
      decoder = JoBinaryDecoder.byteData(data!, dataOffset, length);
    }
    return decoder.decode();
  }

  int get _rawIntValue {
    final data = this.data!;
    switch (length) {
      case 1:
        return data.getUint8(dataOffset);
      case 2:
        return data.getUint16(dataOffset, Endian.little);
      case 3:
        // The control byte must exist, so read one byte earlier and shift
        return data.getUint32(dataOffset - 1, Endian.little) >> 8;
      case 4:
        return data.getUint32(dataOffset, Endian.little);
      case 5:
        return data.getUint32(dataOffset, Endian.little) |
            (data.getUint8(dataOffset + 4) << 32);
      case 6:
        return data.getUint32(dataOffset, Endian.little) |
            (data.getUint16(dataOffset + 4, Endian.little) << 32);
      case 7:
        // The control byte must exist, so read one byte earlier and shift
        return data.getUint64(dataOffset - 1, Endian.little) >> 8;
      case 8:
        return data.getUint64(dataOffset, Endian.little);
      default:
        throw StateError('Internal error');
    }
  }

  List<JoFieldData> get _collection {
    if (length == 0) {
      if (constantId == 0) return const [];
      return [
        JoFieldData(constantId: constantId - 1, length: 0, dataOffset: 0)
      ];
    }
    return JoBinaryFieldlessDecoder.byteData(data!, dataOffset, length)
        .decode();
  }
}

class JoBinaryDecoderBase {
  JoBinaryDecoderBase(Uint8List data)
      : _data = ByteData.view(data.buffer),
        _offset = data.offsetInBytes,
        _end = data.offsetInBytes + data.length;

  JoBinaryDecoderBase.byteData(this._data, this._offset, int length)
      : _end = _offset + length;

  final ByteData _data;
  final int _end;

  int _offset;

  int _readUint8() => _data.getUint8(_offset++);

  int _readUint16() {
    final value = _data.getUint16(_offset, Endian.little);
    _offset += 2;
    return value;
  }

  int _readUint32() {
    final value = _data.getUint32(_offset, Endian.little);
    _offset += 4;
    return value;
  }

  int _readUint64() {
    final value = _data.getUint64(_offset, Endian.little);
    _offset += 8;
    return value;
  }
}

class JoBinaryDecoder extends JoBinaryDecoderBase {
  JoBinaryDecoder(Uint8List data) : super(data);

  JoBinaryDecoder.byteData(ByteData data, int offset, int length)
      : super.byteData(data, offset, length);

  Map<int, JoFieldData> decode() {
    final end = _end;
    if (_offset == end) return const {};

    final result = <int, JoFieldData>{};
    while (_offset < end) {
      final controlByte = _readUint8();

      final fieldId = readFieldId(controlByte);
      final data = readFieldData(controlByte);

      result[fieldId] = data;
    }
    return result;
  }

  int readFieldId(int controlByte) {
    final fieldId = controlByte >> 4;
    switch (fieldId) {
      case 12:
        return _readUint8();
      case 13:
        return _readUint16();
      case 14:
        return _readUint32();
      case 15:
        return _readUint64();
      default:
        return fieldId;
    }
  }

  JoFieldData readFieldData(int controlByte) {
    final lengthControlNibble = controlByte & 0xf;
    if (lengthControlNibble < 4) {
      return JoFieldData(
        constantId: lengthControlNibble,
        length: 0,
        dataOffset: 0,
      );
    } else {
      final int length;
      if (lengthControlNibble >= 8) {
        length = lengthControlNibble - 7;
      } else if (lengthControlNibble == 4) {
        length = _readUint8();
      } else if (lengthControlNibble == 5) {
        length = _readUint16();
      } else if (lengthControlNibble == 6) {
        length = _readUint32();
      } else {
        assert(lengthControlNibble == 7);
        length = _readUint64();
      }

      assert(length != 0);
      final data = JoFieldData(
        constantId: 0,
        length: length,
        dataOffset: _offset,
        data: _data,
      );
      _offset += length;

      return data;
    }
  }
}

class JoBinaryFieldlessDecoder extends JoBinaryDecoderBase {
  JoBinaryFieldlessDecoder(Uint8List data) : super(data);

  JoBinaryFieldlessDecoder.byteData(ByteData data, int offset, int length)
      : super.byteData(data, offset, length);

  List<JoFieldData> decode() {
    final end = _end;
    if (_offset == end) return const [];

    final result = <JoFieldData>[];
    while (_offset < end) {
      final controlByte = _readUint8();
      final data = readFieldData(controlByte);

      result.add(data);
    }
    return result;
  }

  JoFieldData readFieldData(int controlByte) {
    if (controlByte <= 0xbb) {
      return JoFieldData(
        constantId: controlByte,
        length: 0,
        dataOffset: 0,
      );
    } else {
      final int length;
      if (controlByte >= 0xc0) {
        length = controlByte - 0xbf;
      } else if (controlByte == 0xbc) {
        length = _readUint8();
      } else if (controlByte == 0xbd) {
        length = _readUint16();
      } else if (controlByte == 0xbe) {
        length = _readUint32();
      } else {
        assert(controlByte == 0xbf);
        length = _readUint64();
      }

      assert(length != 0);
      final data = JoFieldData(
        constantId: 0,
        length: length,
        dataOffset: _offset,
        data: _data,
      );
      _offset += length;

      return data;
    }
  }
}

extension JoBinaryDataDecodeMapExtension on Map<int, JoFieldData> {
  T? optionalValue<T>(int fieldId, T? Function(JoFieldData) factory) =>
      this[fieldId]?.optionalValue(factory);

  bool? boolValue(int fieldId, {bool? defaultValue}) =>
      this[fieldId]?.boolValue ?? defaultValue;

  int? uintValue(int fieldId, {int? defaultValue}) =>
      this[fieldId]?.uintValue ?? defaultValue;

  int? intValue(int fieldId, {int? defaultValue}) =>
      this[fieldId]?.intValue ?? defaultValue;

  double? doubleValue(int fieldId, {double? defaultValue}) =>
      this[fieldId]?.doubleValue ?? defaultValue;

  Uint8List? bytesValue(int fieldId, {Uint8List? defaultValue}) =>
      this[fieldId]?.bytesValue ?? defaultValue;

  String? stringValue(int fieldId, {String? defaultValue}) =>
      this[fieldId]?.stringValue ?? defaultValue;

  List<T>? listValue<T>(
    int fieldId,
    T? Function(JoFieldData) factory,
    bool immutable,
  ) =>
      this[fieldId]?.listValue(factory, immutable);

  Set<T>? setValue<T>(
    int fieldId,
    T? Function(JoFieldData) factory,
    bool immutable,
  ) =>
      this[fieldId]?.setValue(factory, immutable);

  Map<K, V>? mapValue<K, V>(
    int fieldId,
    K? Function(JoFieldData) keyFactory,
    V? Function(JoFieldData) valueFactory,
    bool immutable,
  ) =>
      this[fieldId]?.mapValue(keyFactory, valueFactory, immutable);

  Map<int, JoFieldData>? embeddedObject(int fieldId) {
    final data = this[fieldId];
    return data?.embeddedObject;
  }

  T? enumValue<T>(int fieldId, T? Function(int) fromId, {T? defaultValue}) {
    final data = this[fieldId];
    if (data == null) return defaultValue;

    return fromId(data.uintValue);
  }
}

int _unzigzag(int value) {
  value = ((value >> 1) ^ (value << 63 >> 63));
  return -value;
}

final _scratchpad = ByteData(4);
