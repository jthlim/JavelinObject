import 'dart:typed_data';

class JoBytesBuilder {
  JoBytesBuilder() : this._(Uint8List(_initialBufferSize));

  JoBytesBuilder._(this._buffer) : _byteData = ByteData.view(_buffer.buffer);

  final _bytesBuilder = BytesBuilder(copy: false);

  Uint8List _buffer;
  ByteData _byteData;

  // The current size of [_buffer];
  //
  // This is set to zero when the buffer is flushed to indicate that the buffer
  // has been handed to [_bytesBuilder].
  var _bufferSize = _initialBufferSize;
  var _offset = 0;

  static const _initialBufferSize = 256;

  bool get isEmpty => _offset == 0 && _bytesBuilder.isEmpty;
  int get length => _bytesBuilder.length + _offset;

  // TODO: Improve this to be O(1).
  int get firstByte {
    _flushBuffer();
    return _bytesBuilder.toBytes()[0];
  }

  void add(List<int> values) {
    final length = values.length;
    if (_offset + length > _bufferSize) _nextBuffer();
    if (_offset == 0) {
      _bytesBuilder.add(values);
    } else {
      _buffer.setRange(_offset, _offset + length, values);
      _offset += length;
    }
  }

  void addBytesBuilder(JoBytesBuilder b) {
    // TODO: Improve this to avoid O(N^2) encoding situations.
    if (b.length == 0) return;

    add(b.toBytes());
  }

  void addByte(int value) {
    if (_offset >= _bufferSize) _nextBuffer();
    _buffer[_offset++] = value;
  }

  void addAsciiString(String s) {
    final length = s.length;
    if (_offset + length > _bufferSize) _nextBuffer();
    if (_offset == 0) {
      final buffer = Uint8List(length);
      for (var i = 0; i < length; ++i) {
        buffer[i] = s.codeUnitAt(i);
      }
      _bytesBuilder.add(buffer);
    } else {
      for (var i = 0; i < length; ++i) {
        _byteData.setUint8(_offset++, s.codeUnitAt(i));
      }
    }
  }

  Uint8List toBytes() {
    if (_bytesBuilder.isEmpty) {
      return Uint8List.view(_buffer.buffer, 0, _offset);
    }

    _flushBuffer();
    return _bytesBuilder.toBytes();
  }

  void addUint16(int value) {
    if (_offset + 2 > _bufferSize) _nextBuffer();
    _byteData.setUint16(_offset, value, Endian.little);
    _offset += 2;
  }

  void addUint32(int value) {
    if (_offset + 4 > _bufferSize) _nextBuffer();
    _byteData.setUint32(_offset, value, Endian.little);
    _offset += 4;
  }

  void addUint64(int value) {
    if (_offset + 8 > _bufferSize) _nextBuffer();
    _byteData.setUint64(_offset, value, Endian.little);
    _offset += 8;
  }

  void addFloat32(double value) {
    if (_offset + 4 > _bufferSize) _nextBuffer();
    _byteData.setFloat32(_offset, value, Endian.little);
    _offset += 4;
  }

  void addFloat64(double value) {
    if (_offset + 8 > _bufferSize) _nextBuffer();
    _byteData.setFloat64(_offset, value, Endian.little);
    _offset += 8;
  }

  void _nextBuffer() {
    _flushBuffer();
    if (_bufferSize <= _initialBufferSize) {
      _bufferSize = _initialBufferSize;
    } else {
      _bufferSize *= 2;
    }
    _newBuffer(_bufferSize);
  }

  void _newBuffer(int size) {
    _buffer = Uint8List(size);
    _byteData = ByteData.view(_buffer.buffer);
    _offset = 0;
  }

  void _flushBuffer() {
    if (_bufferSize != 0 && _offset != 0) {
      _bytesBuilder.add(Uint8List.view(_buffer.buffer, 0, _offset));
      _bufferSize = 0;
    }
  }
}
