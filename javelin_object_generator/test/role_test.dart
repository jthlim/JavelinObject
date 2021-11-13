import 'package:javelin_object_generator/src/role.dart';
import 'package:test/test.dart';

void main() {
  group(Role, () {
    test('should match when the role and rule are exact', () {
      final role = Role('user-server.server');
      final rule = Role('user-server.server');

      expect(role.matches(rule), isTrue);
    });

    test('should not match when the role and rule are different', () {
      final role = Role('user-server.server');
      final rule = Role('user-server.client');

      expect(role.matches(rule), isFalse);
    });

    test('should match when the rule has a wildcard', () {
      final role = Role('platform.mobile.ios');
      final rule = Role('platform.mobile.*');

      expect(role.matches(rule), isTrue);
    });
  });
}
