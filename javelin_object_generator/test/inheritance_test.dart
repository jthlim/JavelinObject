import 'package:test/test.dart';

import 'inheritance_test.jo.dart';
import 'inheritance_test.jo.dart' as inheritance_test show joRegister;

void main() {
  inheritance_test.joRegister();

  group(BaseClass, () {
    test('should serialize to and from JSON correctly', () {
      const obj = BaseClass(i: 1);
      expect(obj.toJson(), '{"\$t":"BaseClass","i":1,"u":10}');

      final rebuilt = BaseClass.fromJson(obj.toJson());
      expect(rebuilt, obj);
    });
  });

  group(Derived, () {
    test('should serialize to and from JSON correctly', () {
      const obj = Derived(i: 1, b: true, f: 3.0);
      expect(
        obj.toJson(),
        '{"\$t":"D","i":1,"u":10,"b":true,"f":3.0}',
      );

      final rebuilt = BaseClass.fromJson(obj.toJson());
      expect(rebuilt, obj);
    });

    test('should serialize to and from a string correctly', () {
      const obj = Derived(i: 1, b: true, f: 3.0);
      expect(
        obj.toString(pretty: false),
        '{\'\$t\':\'Derived\',\'i\':1,\'u\':10,\'b\':true,\'f\':3.0}',
      );

      final rebuilt = BaseClass.fromString(obj.toString());
      expect(rebuilt, obj);
    });

    test('should serialize to and from binary correctly', () {
      const obj = Derived(i: 1, b: true, f: 3.0);

      expect(
        obj.toBytes(),
        [
          0x0a, 0x01, 0x18, 0x48, // Derived object contents.
          0x11, // type: 1
          0x21, // i: 1
          0x48, 0x0a, // u: 10
        ],
      );

      final rebuilt = BaseClass.fromBytes(obj.toBytes());
      expect(rebuilt, obj);
    });
  });
}
