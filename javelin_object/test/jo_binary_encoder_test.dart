import 'dart:typed_data';

import 'package:javelin_object/src/jo_binary_encoder.dart';
import 'package:test/test.dart';

void main() {
  group(JoBinaryEncoder, () {
    test('should encode an empty binary', () {
      final encoder = JoBinaryEncoder();
      expect(encoder.toBytes(), Uint8List(0));
    });

    test('should encode simple constants', () {
      final encoder = JoBinaryEncoder();
      encoder.writeBool(0, false);
      encoder.writeBool(1, true);

      expect(encoder.toBytes(), Uint8List.fromList([0x00, 0x11]));
    });

    test('should encode uint values correctly', () {
      final encoder = JoBinaryEncoder();
      encoder.writeUint(0, 0);
      encoder.writeUint(1, 1);
      encoder.writeUint(2, 2);
      encoder.writeUint(3, 3);

      encoder.writeUint(4, 0x12);
      encoder.writeUint(5, 0x1234);
      encoder.writeUint(6, 0x123456);
      encoder.writeUint(7, 0x12345678);
      encoder.writeUint(8, 0x123456789a);
      encoder.writeUint(9, 0x123456789abc);
      encoder.writeUint(10, 0x123456789abcde);
      encoder.writeUint(11, 0x123456789abcdef0);

      expect(encoder.toBytes(), [
        0x00, 0x11, 0x22, 0x33, // Constants
        0x48, 0x12, // 1 byte
        0x59, 0x34, 0x12, // 2 byte
        0x6a, 0x56, 0x34, 0x12, // 3 byte
        0x7b, 0x78, 0x56, 0x34, 0x12, // 4 byte
        0x8c, 0x9a, 0x78, 0x56, 0x34, 0x12, // 5 byte
        0x9d, 0xbc, 0x9a, 0x78, 0x56, 0x34, 0x12, // 6 byte
        0xae, 0xde, 0xbc, 0x9a, 0x78, 0x56, 0x34, 0x12, // 7 byte
        0xbf, 0xf0, 0xde, 0xbc, 0x9a, 0x78, 0x56, 0x34, 0x12, // 8 byte
      ]);
    });

    test('should encode int values correctly', () {
      final encoder = JoBinaryEncoder();
      encoder.writeInt(0, 0);
      encoder.writeInt(1, 1);
      encoder.writeInt(2, -1);
      encoder.writeInt(3, 2);
      encoder.writeInt(4, -9);
      encoder.writeInt(5, 9);
      encoder.writeInt(6, -0x91a);
      encoder.writeInt(7, 0x91a);
      encoder.writeInt(8, -0x91a2b);
      encoder.writeInt(9, 0x91a2b);
      encoder.writeInt(10, -0x91a2b3c);
      encoder.writeInt(11, 0x91a2b3c);

      expect(encoder.toBytes(), [
        0x00, 0x11, 0x22, 0x33, // Constants
        0x48, 0x12, // 1 byte negative int
        0x58, 0x11, // 1 byte int
        0x69, 0x34, 0x12, // 2 byte negative int
        0x79, 0x33, 0x12, // 2 byte int
        0x8a, 0x56, 0x34, 0x12, // 3 byte negative int
        0x9a, 0x55, 0x34, 0x12, // 3 byte int
        0xab, 0x78, 0x56, 0x34, 0x12, // 4 byte negative int
        0xbb, 0x77, 0x56, 0x34, 0x12, // 4 byte int
      ]);
    });

    test('should encode float values correctly', () {
      final encoder = JoBinaryEncoder();
      encoder.writeFloat(0, 0);
      encoder.writeFloat(1, 1);
      encoder.writeFloat(2, -1);
      encoder.writeFloat(3, 2);

      encoder.writeFloat(4, 1.5);
      encoder.writeFloat(5, -1.5);
      encoder.writeFloat(6, 20);
      encoder.writeFloat(7, -20);
      encoder.writeFloat(8, 100);
      encoder.writeFloat(9, -100);
      encoder.writeFloat(10, 1.0 / 3.0);
      encoder.writeFloat(11, -1.0 / 3.0);

      expect(encoder.toBytes(), [
        0x00, 0x11, 0x22, 0x33, // Constants
        0x48, 0x38, 0x58, 0xb8, // 1.5, -1.5
        0x68, 0x74, 0x78, 0xf4, // 20.0, -20.0
        0x89, 0x40, 0x56, 0x99, 0x40, 0xd6, // 100, -100
        0xab, 0xab, 0xaa, 0xaa, 0x3e, 0xbb, 0xab, 0xaa, 0xaa, 0xbe,
      ]);
    });

    test('should encode double values correctly', () {
      final encoder = JoBinaryEncoder();
      encoder.writeDouble(0, 0);
      encoder.writeDouble(1, 1);
      encoder.writeDouble(2, -1);
      encoder.writeDouble(3, 2);

      encoder.writeDouble(4, 1.5);
      encoder.writeDouble(5, -1.5);
      encoder.writeDouble(6, 20);
      encoder.writeDouble(7, -20);
      encoder.writeDouble(8, 100);
      encoder.writeDouble(9, -100);
      encoder.writeDouble(10, 1.0 / 3.0);
      encoder.writeDouble(11, -1.0 / 3.0);

      expect(encoder.toBytes(), [
        0x00, 0x11, 0x22, 0x33, // Constants
        0x48, 0x38, 0x58, 0xb8, // 1.5, -1.5
        0x68, 0x74, 0x78, 0xf4, // 20.0, -20.0
        0x89, 0x40, 0x56, 0x99, 0x40, 0xd6, // 100, -100
        0xaf, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0xd5, 0x3f,
        0xbf, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0xd5, 0xbf,
      ]);
    });

    test('should encode String values correctly', () {
      final encoder = JoBinaryEncoder();
      encoder.writeString(0, '');
      encoder.writeString(1, 'a');
      encoder.writeString(2, '😀');
      encoder.writeString(3, 'aaaaaaaaaaaaaaaa');

      expect(encoder.toBytes(), [
        0x00, // Empty string
        0x18, 0x61,
        0x2b, 0xf0, 0x9f, 0x98, 0x80,

        // 16 bytes of 'a'
        0x34, 0x10, 0x61, 0x61, 0x61, 0x61, 0x61, 0x61, 0x61, 0x61, 0x61, 0x61,
        0x61, 0x61, 0x61, 0x61, 0x61, 0x61,
      ]);
    });
  });
}
