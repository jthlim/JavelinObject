import 'package:test/test.dart';

import 'json_test.jo.dart';

void main() {
  group(NonStringMap, () {
    test('should serialize to JSON correctly', () {
      final map = NonStringMap(a: {1: 2, 3: 4});
      expect(map.toJson(), '{"a":[{"k":1,"v":2},{"k":3,"v":4}]}');
    });

    test('should serialize from JSON correctly', () {
      final map = NonStringMap(a: {1: 2, 3: 4});
      expect(NonStringMap.fromJson(map.toJson()), map);
    });
  });

  group(Basic, () {
    test('should use json aliases', () {
      final a = Basic(enumValue: Enum.second);
      expect(a.toJson(), '{"e":"2"}');

      final b = Basic.fromJson(a.toJson());
      expect(b, a);
    });
  });

  group(UnionWithOptionals, () {
    test('should serialize and deserialize optional int field properly', () {
      const a1 = UnionWithOptionals.a();
      const a2 = UnionWithOptionals.a(1);
      const a3 = UnionWithOptionals.a(10);

      expect(a1.toJson(pretty: false), '{"a":null}');
      expect(a2.toJson(pretty: false), '{"a":1}');
      expect(a3.toJson(pretty: false), '{"a":10}');

      expect(a1.toString(pretty: false), '{\'a\':null}');
      expect(a2.toString(pretty: false), '{\'a\':1}');
      expect(a3.toString(pretty: false), '{\'a\':10}');

      expect(UnionWithOptionals.fromJson(a1.toJson()), a1);
      expect(UnionWithOptionals.fromJson(a2.toJson()), a2);
      expect(UnionWithOptionals.fromJson(a3.toJson()), a3);

      expect(UnionWithOptionals.fromString(a1.toString()), a1);
      expect(UnionWithOptionals.fromString(a2.toString()), a2);
      expect(UnionWithOptionals.fromString(a3.toString()), a3);
    });
  });
}
