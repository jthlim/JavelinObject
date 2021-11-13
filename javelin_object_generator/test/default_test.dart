import 'package:test/test.dart';

import 'default_test.jo.dart';

void main() {
  group(DefaultValues, () {
    test('should construct with expected values', () {
      final a = DefaultValues();

      expect(a.nonNullInt32, 1);
      expect(a.nullableInt32, 2);
      expect(a.nonNullString, 'abc');
      expect(a.nullableString, 'xyz');
      expect(a.nonNullEnum, Enum.medium);
      expect(a.nullableEnum, Enum.large);
    });

    test('should convert from Map with expected values', () {
      final a = DefaultValues.fromMap(const {});

      expect(a.nonNullInt32, 1);
      expect(a.nullableInt32, 2);
      expect(a.nonNullString, 'abc');
      expect(a.nullableString, 'xyz');
      expect(a.nonNullEnum, Enum.medium);
      expect(a.nullableEnum, Enum.large);
    });

    test('should not serialize fields that are optional', () {
      final a = DefaultValues();

      expect(
        a.toBytes(),
        [
          0x01, // nonNullInt32 = 1
          0x2a, 0x61, 0x62, 0x63, // nonNullString = 'abc'
          0x41, // nonNullEnum = Enum.medium
          0x6c, // Object, 5 bytes
          0x0b, 0x41, 0x6c, 0x65, 0x78, // 'Person.name: 'Alex'
        ],
      );
    });
  });
}
