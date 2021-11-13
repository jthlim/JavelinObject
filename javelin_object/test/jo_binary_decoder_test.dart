import 'dart:typed_data';

import 'package:javelin_object/src/jo_binary_decoder.dart';
import 'package:test/test.dart';

void main() {
  group(JoBinaryDecoder, () {
    test('should decode empty proto', () {
      final result = parseJoBinary(Uint8List(0));
      expect(result, isEmpty);
    });

    test('should decode simple constants', () {
      final result = parseJoBinary(Uint8List.fromList([0x00, 0x11]));
      expect(result, hasLength(2));
      expect(result[0]!.constantId, 0);
      expect(result[1]!.constantId, 1);
    });

    test('should decode uint values correctly', () {
      final result = parseJoBinary(Uint8List.fromList([
        0x00, 0x11, 0x22, 0x33, // Constants
        0x48, 0x12, // 1 byte
        0x59, 0x34, 0x12, // 2 byte
        0x6a, 0x56, 0x34, 0x12, // 3 byte
        0x7b, 0x78, 0x56, 0x34, 0x12, // 4 byte
        0x8c, 0x9a, 0x78, 0x56, 0x34, 0x12, // 5 byte
        0x9d, 0xbc, 0x9a, 0x78, 0x56, 0x34, 0x12, // 6 byte
        0xae, 0xde, 0xbc, 0x9a, 0x78, 0x56, 0x34, 0x12, // 7 byte
        0xbf, 0xf0, 0xde, 0xbc, 0x9a, 0x78, 0x56, 0x34, 0x12, // 8 byte
      ]));
      expect(result, hasLength(12));
      expect(result.uintValue(0), 0);
      expect(result.uintValue(1), 1);
      expect(result.uintValue(2), 2);
      expect(result.uintValue(3), 3);
      expect(result.uintValue(4), 0x12);
      expect(result.uintValue(5), 0x1234);
      expect(result.uintValue(6), 0x123456);
      expect(result.uintValue(7), 0x12345678);
      expect(result.uintValue(8), 0x123456789a);
      expect(result.uintValue(9), 0x123456789abc);
      expect(result.uintValue(10), 0x123456789abcde);
      expect(result.uintValue(11), 0x123456789abcdef0);
    });

    test('should decode int values correctly', () {
      final result = parseJoBinary(Uint8List.fromList([
        0x00, 0x11, 0x22, 0x33, // Constants
        0x48, 0x12, // 1 byte negative int
        0x58, 0x11, // 1 byte int
        0x69, 0x34, 0x12, // 2 byte negative int
        0x79, 0x33, 0x12, // 2 byte int
        0x8a, 0x56, 0x34, 0x12, // 3 byte negative int
        0x9a, 0x55, 0x34, 0x12, // 3 byte int
        0xab, 0x78, 0x56, 0x34, 0x12, // 4 byte negative int
        0xbb, 0x77, 0x56, 0x34, 0x12, // 4 byte int
      ]));
      expect(result, hasLength(12));
      expect(result.intValue(0), 0);
      expect(result.intValue(1), 1);
      expect(result.intValue(2), -1);
      expect(result.intValue(3), 2);
      expect(result.intValue(4), -9);
      expect(result.intValue(5), 9);
      expect(result.intValue(6), -0x91a);
      expect(result.intValue(7), 0x91a);
      expect(result.intValue(8), -0x91a2b);
      expect(result.intValue(9), 0x91a2b);
      expect(result.intValue(10), -0x91a2b3c);
      expect(result.intValue(11), 0x91a2b3c);
    });

    test('should decode float values correctly', () {
      final result = parseJoBinary(Uint8List.fromList([
        0x00, 0x11, 0x22, 0x33, // Constants
        0x48, 0x38, 0x58, 0xb8, // 1.5, -1.5
        0x68, 0x74, 0x78, 0xf4, // 20.0, -20.0
        0x89, 0x40, 0x56, 0x99, 0x40, 0xd6, // 100, -100
        0xab, 0xab, 0xaa, 0xaa, 0x3e, 0xbb, 0xab, 0xaa, 0xaa, 0xbe,
      ]));

      expect(result, hasLength(12));
      expect(result.doubleValue(0), 0.0);
      expect(result.doubleValue(1), 1.0);
      expect(result.doubleValue(2), -1.0);
      expect(result.doubleValue(3), 2.0);
      expect(result.doubleValue(4), 1.5);
      expect(result.doubleValue(5), -1.5);
      expect(result.doubleValue(6), 20.0);
      expect(result.doubleValue(7), -20.0);
      expect(result.doubleValue(8), 100.0);
      expect(result.doubleValue(9), -100.0);
      expect(result.doubleValue(10), _truncateToFloat(1.0 / 3.0));
      expect(result.doubleValue(11), _truncateToFloat(-1.0 / 3.0));
    });

    test('should decode double values correctly', () {
      final result = parseJoBinary(Uint8List.fromList([
        0x00, 0x11, 0x22, 0x33, // Constants
        0x48, 0x38, 0x58, 0xb8, // 1.5, -1.5
        0x68, 0x74, 0x78, 0xf4, // 20.0, -20.0
        0x89, 0x40, 0x56, 0x99, 0x40, 0xd6, // 100, -100
        0xaf, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0xd5, 0x3f,
        0xbf, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0xd5, 0xbf,
      ]));

      expect(result, hasLength(12));
      expect(result.doubleValue(0), 0.0);
      expect(result.doubleValue(1), 1.0);
      expect(result.doubleValue(2), -1.0);
      expect(result.doubleValue(3), 2.0);
      expect(result.doubleValue(4), 1.5);
      expect(result.doubleValue(5), -1.5);
      expect(result.doubleValue(6), 20.0);
      expect(result.doubleValue(7), -20.0);
      expect(result.doubleValue(8), 100.0);
      expect(result.doubleValue(9), -100.0);
      expect(result.doubleValue(10), 1.0 / 3.0);
      expect(result.doubleValue(11), -1.0 / 3.0);
    });

    test('should decode String values correctly', () {
      final result = parseJoBinary(Uint8List.fromList([
        0x00, // Empty string
        0x18, 0x61,
        0x2b, 0xf0, 0x9f, 0x98, 0x80,

        // 16 bytes of 'a'
        0x34, 0x10, 0x61, 0x61, 0x61, 0x61, 0x61, 0x61, 0x61, 0x61, 0x61, 0x61,
        0x61, 0x61, 0x61, 0x61, 0x61, 0x61,
      ]));
      expect(result, hasLength(4));
      expect(result.stringValue(0), '');
      expect(result.stringValue(1), 'a');
      expect(result.stringValue(2), '😀');
      expect(result.stringValue(3), 'aaaaaaaaaaaaaaaa');
    });

    test('should decode embedded object correctly', () {
      final result = parseJoBinary(Uint8List.fromList([
        0x09, 0x08, 0x96, // Object wrapping another object with uint value 150.
      ]));

      expect(result, hasLength(1));
      final embeddedObject = result.embeddedObject(0)!;
      expect(embeddedObject, hasLength(1));
      expect(embeddedObject.uintValue(0), 150);
    });
  });
}

double _truncateToFloat(double value) {
  final byteData = ByteData(4);
  byteData.setFloat32(0, value, Endian.little);
  return byteData.getFloat32(0, Endian.little);
}
