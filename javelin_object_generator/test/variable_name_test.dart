import 'package:javelin_object_generator/src/variable_name.dart';
import 'package:test/test.dart';

void main() {
  group(VariableName, () {
    test('should return expected values for single word name', () {
      final variableName = VariableName.fromCamelCase('test');

      expect(variableName.lowerCamelCase, 'test');
      expect(variableName.upperCamelCase, 'Test');
      expect(variableName.lowerSnakeCase, 'test');
      expect(variableName.upperSnakeCase, 'TEST');
    });

    test('should return expected values for two word name', () {
      final variableName = VariableName.fromCamelCase('testUser');

      expect(variableName.lowerCamelCase, 'testUser');
      expect(variableName.upperCamelCase, 'TestUser');
      expect(variableName.lowerSnakeCase, 'test_user');
      expect(variableName.upperSnakeCase, 'TEST_USER');
    });

    test('should return expected values for name with digits', () {
      final variableName = VariableName.fromCamelCase('testUser2');

      expect(variableName.lowerCamelCase, 'testUser2');
      expect(variableName.upperCamelCase, 'TestUser2');
      expect(variableName.lowerSnakeCase, 'test_user_2');
      expect(variableName.upperSnakeCase, 'TEST_USER_2');
    });

    test('should return expected values for snake case names', () {
      final variableName = VariableName.fromSnakeCase('test_user');

      expect(variableName.lowerCamelCase, 'testUser');
      expect(variableName.upperCamelCase, 'TestUser');
      expect(variableName.lowerSnakeCase, 'test_user');
      expect(variableName.upperSnakeCase, 'TEST_USER');
    });
  });
}
