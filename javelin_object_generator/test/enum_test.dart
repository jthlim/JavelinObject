import 'package:test/test.dart';

import 'enum_test.jo.dart';

void main() {
  group(Avatar, () {
    test('should serialize and deserialize JSON to the same object', () {
      const original = Avatar(size: CircleSize.large, captionText: 'Winner');
      final intermediate = original.toJson();
      final reconstructed = Avatar.fromJson(intermediate);

      expect(reconstructed, equals(original));
    });

    test('should serialize and deserialize MAp to the same object', () {
      const original = Avatar(size: CircleSize.large, captionText: 'Winner');
      final intermediate = original.toMap();
      final reconstructed = Avatar.fromMap(intermediate);

      expect(reconstructed, equals(original));
    });
  });
}
