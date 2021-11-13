import 'dart:convert';
import 'dart:typed_data';

import 'package:javelin_object/jo_internal.dart';

import 'jo_bytes_builder.dart';

class JoBinaryEncoder {
  final _bytesBuilder = JoBytesBuilder();

  int get length => _bytesBuilder.length;
  Uint8List toBytes() => _bytesBuilder.toBytes();

  void writeBool(int fieldId, bool value) =>
      _writeFieldIdAndControlNibble(fieldId, value ? 1 : 0);

  void writeUint(int fieldId, int value) {
    if (0 <= value && value <= 3) {
      _writeFieldIdAndControlNibble(fieldId, value);
      return;
    }
    _writeIntValue(fieldId, value);
  }

  void writeInt(int fieldId, int value) {
    if (-1 <= value && value <= 2) {
      _writeFieldIdAndControlNibble(fieldId, _zigzag(value));
      return;
    }

    _writeIntValue(fieldId, _zigzag(value));
  }

  void writeString(int fieldId, String s) {
    switch (s.length) {
      case 0:
        _writeFieldIdAndControlNibble(fieldId, 0);
        return;

      case 1:
        final c = s.codeUnitAt(0);
        if (c <= 2) {
          _writeFieldIdAndControlNibble(fieldId, c + 1);
          return;
        }
        break;
    }

    final bytes = utf8.encode(s);
    _writeFieldIdAndLength(fieldId, bytes.length);
    _bytesBuilder.add(bytes);
  }

  void writeBytes(int fieldId, List<int> bytes) {
    if (bytes.isEmpty) {
      _writeFieldIdAndControlNibble(fieldId, 0);
      return;
    }
    if (bytes.length == 1) {
      final value = bytes[0];
      if (value <= 2) {
        _writeFieldIdAndControlNibble(fieldId, value + 1);
        return;
      }
    }

    _writeFieldIdAndLength(fieldId, bytes.length);
    _bytesBuilder.add(bytes);
  }

  void writeFloat(int fieldId, double value) {
    final intValue = value.toInt();
    if (intValue == value && -1 <= intValue && intValue <= 2) {
      _writeFieldIdAndControlNibble(fieldId, _zigzag(intValue));
      return;
    }

    final testData = _scratchpad;
    testData.setFloat32(0, value, Endian.little);

    _writeCompactFloat(fieldId, value, testData.getUint32(0, Endian.little));
  }

  void writeDouble(int fieldId, double value) {
    final intValue = value.toInt();
    if (intValue == value && -1 <= intValue && intValue <= 2) {
      _writeFieldIdAndControlNibble(fieldId, _zigzag(intValue));
      return;
    }

    final testData = _scratchpad;
    testData.setFloat32(0, value, Endian.little);
    if (testData.getFloat32(0, Endian.little) != value) {
      _writeFieldIdAndControlNibble(fieldId, 0xf);
      _bytesBuilder.addFloat64(value);
      return;
    }

    _writeCompactFloat(fieldId, value, testData.getUint32(0, Endian.little));
  }

  void writeOptional<T>(
    int fieldId,
    T? value,
    void Function(JoBinaryFieldlessEncoder, T) serializer,
  ) {
    if (value == null) {
      _writeFieldIdAndControlNibble(fieldId, 0);
      return;
    }

    final container = JoBinaryFieldlessEncoder();
    serializer(container, value);

    _writeBytesBuilder(fieldId, container._bytesBuilder);
  }

  void writeIterable<T>(
    int fieldId,
    Iterable<T> iterable,
    void Function(JoBinaryFieldlessEncoder, T) elementSerializer,
  ) {
    if (iterable.isEmpty) {
      _writeFieldIdAndControlNibble(fieldId, 0);
      return;
    }

    final container = JoBinaryFieldlessEncoder();
    for (final element in iterable) {
      elementSerializer(container, element);
    }

    _writeBytesBuilder(fieldId, container._bytesBuilder);
  }

  void writeMap<K, V>(
    int fieldId,
    Map<K, V> map,
    void Function(JoBinaryFieldlessEncoder, K) keySerializer,
    void Function(JoBinaryFieldlessEncoder, V) valueSerializer,
  ) {
    final container = JoBinaryFieldlessEncoder();
    map.forEach((k, v) {
      keySerializer(container, k);
      valueSerializer(container, v);
    });

    if (container.length == 0) {
      _writeFieldIdAndControlNibble(fieldId, 0);
      return;
    }

    final bytes = container.toBytes();
    if (bytes.length == 2 && bytes[0] < 3 && bytes[1] == 0) {
      // constant 1: 0, 0
      // constant 2: 0, 1
      // constant 3: 0, 2
      _writeFieldIdAndControlNibble(fieldId, bytes[0] + 1);
      return;
    }

    // TODO: Improve JoBytesBuilder to avoid O(N^2) encoding situations.
    _writeFieldIdAndLength(fieldId, bytes.length);
    _bytesBuilder.addBytesBuilder(container._bytesBuilder);
  }

  void writeObject(int fieldId, JoBinaryEncoder encoder) {
    _writeBytesBuilder(fieldId, encoder._bytesBuilder);
  }

  void _writeBytesBuilder(int fieldId, JoBytesBuilder bytesBuilder) {
    if (bytesBuilder.isEmpty) {
      _writeFieldIdAndControlNibble(fieldId, 0);
      return;
    }

    final length = bytesBuilder.length;
    if (length == 1) {
      final value = bytesBuilder.firstByte;
      if (value <= 2) {
        _writeFieldIdAndControlNibble(fieldId, value + 1);
        return;
      }
    }

    _writeFieldIdAndLength(fieldId, length);
    _bytesBuilder.addBytesBuilder(bytesBuilder);
  }

  void _writeCompactFloat(int fieldId, double value, int valueBits) {
    if ((valueBits & 0x1fff) == 0) {
      final exponent = ((valueBits >> 23) & 0xff) - 127;

      // First check if binary8 can represent it
      if ((valueBits & 0x7ffff) == 0 && -3 <= exponent && exponent <= 4) {
        // Can be represented as an 8-bit float.
        final binary8 = ((valueBits >> 24) & 0x80) |
            ((exponent + 3) << 4) |
            ((valueBits & 0x00780000) >> 19);

        _writeFieldIdAndControlNibble(fieldId, 0x8);
        _bytesBuilder.addByte(binary8);
        return;
      }

      if (-15 <= exponent && exponent <= 16) {
        // Can be represented as a 16-bit float.
        final binary16 = ((valueBits >> 16) & 0x8000) |
            ((exponent + 15) << 10) |
            ((valueBits & 0x007fe000) >> 13);

        _writeFieldIdAndControlNibble(fieldId, 0x9);
        _bytesBuilder.addUint16(binary16);
        return;
      }
    }

    _writeFieldIdAndControlNibble(fieldId, 0xb);
    _bytesBuilder.addFloat32(value);
  }

  void _writeIntValue(int fieldId, int value) {
    if (value < 0) {
      _writeFieldIdAndControlNibble(fieldId, 0xf);
      _bytesBuilder.addUint64(value);
    } else if (value < 0x100) {
      _writeFieldIdAndControlNibble(fieldId, 0x8);
      _bytesBuilder.addByte(value);
    } else if (value < 0x10000) {
      _writeFieldIdAndControlNibble(fieldId, 0x9);
      _bytesBuilder.addUint16(value);
    } else if (value < 0x1000000) {
      _writeFieldIdAndControlNibble(fieldId, 0xa);
      _bytesBuilder.addUint16(value);
      _bytesBuilder.addByte(value >> 16);
    } else if (value < 0x100000000) {
      _writeFieldIdAndControlNibble(fieldId, 0xb);
      _bytesBuilder.addUint32(value);
    } else if (value < 0x10000000000) {
      _writeFieldIdAndControlNibble(fieldId, 0xc);
      _bytesBuilder.addUint32(value);
      _bytesBuilder.addByte(value >> 32);
    } else if (value < 0x1000000000000) {
      _writeFieldIdAndControlNibble(fieldId, 0xd);
      _bytesBuilder.addUint32(value);
      _bytesBuilder.addUint16(value >> 32);
    } else if (value < 0x100000000000000) {
      _writeFieldIdAndControlNibble(fieldId, 0xe);
      _bytesBuilder.addUint32(value);
      _bytesBuilder.addUint16(value >> 32);
      _bytesBuilder.addByte(value >> 48);
    } else {
      _writeFieldIdAndControlNibble(fieldId, 0xf);
      _bytesBuilder.addUint64(value);
    }
  }

  void _writeFieldIdAndControlNibble(int fieldId, int controlNibble) {
    assert(fieldId >= 0);

    if (fieldId < 12) {
      _bytesBuilder.addByte((fieldId << 4) | controlNibble);
    } else if (fieldId < 0x100) {
      _bytesBuilder.addByte(0xc0 | controlNibble);
      _bytesBuilder.addByte(fieldId);
    } else if (fieldId < 0x10000) {
      _bytesBuilder.addByte(0xd0 | controlNibble);
      _bytesBuilder.addUint16(fieldId);
    } else if (fieldId < 0x100000000) {
      _bytesBuilder.addByte(0xe0 | controlNibble);
      _bytesBuilder.addUint32(fieldId);
    } else {
      _bytesBuilder.addByte(0xf0 | controlNibble);
      _bytesBuilder.addUint64(fieldId);
    }
  }

  void _writeFieldIdAndLength(int fieldId, int length) {
    assert(length >= 0);

    if (length <= 8) {
      if (length == 0) {
        _writeFieldIdAndControlNibble(fieldId, 0);
        return;
      }
      _writeFieldIdAndControlNibble(fieldId, length + 7);
      return;
    }

    if (length < 0x100) {
      _writeFieldIdAndControlNibble(fieldId, 4);
      _bytesBuilder.addByte(length);
    } else if (length < 0x10000) {
      _writeFieldIdAndControlNibble(fieldId, 5);
      _bytesBuilder.addUint16(length);
    } else if (length < 0x100000000) {
      _writeFieldIdAndControlNibble(fieldId, 6);
      _bytesBuilder.addUint32(length);
    } else {
      _writeFieldIdAndControlNibble(fieldId, 7);
      _bytesBuilder.addUint64(length);
    }
  }
}

class JoBinaryFieldlessEncoder {
  final _bytesBuilder = JoBytesBuilder();

  int get length => _bytesBuilder.length;
  Uint8List toBytes() => _bytesBuilder.toBytes();

  void writeBool(bool value) => _writeConstantId(value ? 1 : 0);

  void writeUint(int value) {
    if (0 <= value && value <= 0xbb) {
      _writeConstantId(value);
      return;
    }
    _writeIntValue(value);
  }

  void writeInt(int value) {
    value = _zigzag(value);
    writeUint(value);
  }

  void writeString(String s) {
    switch (s.length) {
      case 0:
        _writeConstantId(0);
        return;

      case 1:
        final c = s.codeUnitAt(0);
        if (c <= 0xba) {
          _writeConstantId(c + 1);
          return;
        }
        break;
    }

    final bytes = utf8.encode(s);
    _writeLength(bytes.length);
    _bytesBuilder.add(bytes);
  }

  void writeBytes(List<int> bytes) {
    if (bytes.isEmpty) {
      _writeConstantId(0);
      return;
    }
    if (bytes.length == 1) {
      final value = bytes[0];
      if (value <= 0xba) {
        _writeConstantId(value + 1);
        return;
      }
    }

    _writeLength(bytes.length);
    _bytesBuilder.add(bytes);
  }

  void writeFloat(double value) {
    var intValue = value.toInt();
    if (intValue == value) {
      intValue = _zigzag(intValue);
      if (0 <= intValue && intValue <= 0xbb) {
        _writeConstantId(intValue);
        return;
      }
    }

    final testData = _scratchpad;
    testData.setFloat32(0, value, Endian.little);

    _writeCompactFloat(value, testData.getUint32(0, Endian.little));
  }

  void writeDouble(double value) {
    var intValue = value.toInt();
    if (intValue == value) {
      intValue = _zigzag(intValue);
      if (0 <= intValue && intValue <= 0xbb) {
        _writeConstantId(intValue);
        return;
      }
    }

    final testData = _scratchpad;
    testData.setFloat32(0, value, Endian.little);
    if (testData.getFloat32(0, Endian.little) != value) {
      _writeLength(8);
      _bytesBuilder.addFloat64(value);
      return;
    }

    _writeCompactFloat(value, testData.getUint32(0, Endian.little));
  }

  void writeOptional<T>(
    T? value,
    void Function(JoBinaryFieldlessEncoder, T) serializer,
  ) {
    if (value == null) {
      _writeConstantId(0);
      return;
    }

    final container = JoBinaryFieldlessEncoder();
    serializer(container, value);

    _writeBytesBuilder(container._bytesBuilder);
  }

  void writeIterable<T>(
    Iterable<T> iterable,
    void Function(JoBinaryFieldlessEncoder, T) elementSerializer,
  ) {
    if (iterable.isEmpty) {
      _writeConstantId(0);
      return;
    }

    final container = JoBinaryFieldlessEncoder();
    for (final element in iterable) {
      elementSerializer(container, element);
    }

    _writeBytesBuilder(container._bytesBuilder);
  }

  void writeMap<K, V>(
    Map<K, V> map,
    void Function(JoBinaryFieldlessEncoder, K) keySerializer,
    void Function(JoBinaryFieldlessEncoder, V) valueSerializer,
  ) {
    if (map.isEmpty) {
      _writeConstantId(0);
      return;
    }

    final container = JoBinaryFieldlessEncoder();
    map.forEach((k, v) {
      keySerializer(container, k);
      valueSerializer(container, v);
    });

    final bytes = container.toBytes();

    final compactValue = bytes.length == 2
        ? bytes[0] + 14 * bytes[1]
        : 256; // Large number that will fail the next test

    if (compactValue <= 0xba) {
      _writeConstantId(compactValue + 1);
      return;
    }

    _writeLength(bytes.length);
    _bytesBuilder.addBytesBuilder(container._bytesBuilder);
  }

  void writeObject(JoBinaryEncoder encoder) {
    _writeBytesBuilder(encoder._bytesBuilder);
  }

  void _writeBytesBuilder(JoBytesBuilder bytesBuilder) {
    if (bytesBuilder.isEmpty) {
      _writeConstantId(0);
      return;
    }

    final length = bytesBuilder.length;
    if (length == 1) {
      final value = bytesBuilder.firstByte;

      if (value <= 0xba) {
        _writeConstantId(value + 1);
        return;
      }
    }

    _writeLength(length);
    _bytesBuilder.addBytesBuilder(bytesBuilder);
  }

  void _writeCompactFloat(double value, int valueBits) {
    if ((valueBits & 0x1fff) == 0) {
      final exponent = ((valueBits >> 23) & 0xff) - 127;

      // First check if binary8 can represent it
      if ((valueBits & 0x7ffff) == 0 && -3 <= exponent && exponent <= 4) {
        // Can be represented as an 8-bit float.
        final binary8 = ((valueBits >> 24) & 0x80) |
            ((exponent + 3) << 4) |
            ((valueBits & 0x00780000) >> 19);

        _writeLength(1);
        _bytesBuilder.addByte(binary8);
        return;
      }

      if (-15 <= exponent && exponent <= 16) {
        // Can be represented as a 16-bit float.
        final binary16 = ((valueBits >> 16) & 0x8000) |
            ((exponent + 15) << 10) |
            ((valueBits & 0x007fe000) >> 13);

        _writeLength(2);
        _bytesBuilder.addUint16(binary16);
        return;
      }
    }

    _writeLength(4);
    _bytesBuilder.addFloat32(value);
  }

  void _writeIntValue(int value) {
    if (value < 0) {
      _writeLength(8);
      _bytesBuilder.addUint64(value);
    } else if (value < 0x100) {
      _writeLength(1);
      _bytesBuilder.addByte(value);
    } else if (value < 0x10000) {
      _writeLength(2);
      _bytesBuilder.addUint16(value);
    } else if (value < 0x1000000) {
      _writeLength(3);
      _bytesBuilder.addUint16(value);
      _bytesBuilder.addByte(value >> 16);
    } else if (value < 0x100000000) {
      _writeLength(4);
      _bytesBuilder.addUint32(value);
    } else if (value < 0x10000000000) {
      _writeLength(5);
      _bytesBuilder.addUint32(value);
      _bytesBuilder.addByte(value >> 32);
    } else if (value < 0x1000000000000) {
      _writeLength(6);
      _bytesBuilder.addUint32(value);
      _bytesBuilder.addUint16(value >> 32);
    } else if (value < 0x100000000000000) {
      _writeLength(7);
      _bytesBuilder.addUint32(value);
      _bytesBuilder.addUint16(value >> 32);
      _bytesBuilder.addByte(value >> 48);
    } else {
      _writeLength(8);
      _bytesBuilder.addUint64(value);
    }
  }

  void _writeLength(int length) {
    assert(length > 0);

    if (length <= 64) {
      _bytesBuilder.addByte(0xbf + length);
      return;
    }

    if (length < 0x100) {
      _bytesBuilder.addByte(0xbc);
      _bytesBuilder.addByte(length);
    } else if (length < 0x10000) {
      _bytesBuilder.addByte(0xbd);
      _bytesBuilder.addUint16(length);
    } else if (length < 0x100000000) {
      _bytesBuilder.addByte(0xbe);
      _bytesBuilder.addUint32(length);
    } else {
      _bytesBuilder.addByte(0xbf);
      _bytesBuilder.addUint64(length);
    }
  }

  void _writeConstantId(int constantId) {
    assert(0 <= constantId && constantId <= 0xbb);
    _bytesBuilder.addByte(constantId);
  }
}

final _scratchpad = ByteData(4);

int _zigzag(int value) {
  value = -value;
  return (value << 1) ^ (value >> 63);
}
