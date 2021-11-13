import 'package:test/test.dart';

import 'dart_string_test.jo.dart';

void main() {
  group('toConstDartString()', () {
    test('return expected values for EnumValue', () {
      expect(EnumValue.a.toDartString(), 'EnumValue.a');
      expect(EnumValue.e.toDartString(), 'EnumValue.e');
    });

    test('return expected values for Person', () {
      expect(
        const Person(name: 'John', age: 10).toDartString(),
        'Person(name: \'John\',age: 10,)',
      );
    });

    test('return expected values for Union', () {
      expect(const Union.b(true).toDartString(), 'Union.b(true)');
      expect(
        const Union.string('abc').toDartString(),
        'Union.string(\'abc\')',
      );
    });

    test('return expected values for Optionals', () {
      expect(const Optionals().toDartString(), 'Optionals()');
      expect(
        const Optionals(b: true).toDartString(),
        'Optionals(b: true,)',
      );
      expect(
        const Optionals(intList: [1, 3, 5]).toDartString(),
        'Optionals(intList: [1,3,5],)',
      );
      expect(
        const Optionals(intSet: {1, 3, 5}).toDartString(),
        'Optionals(intSet: {1,3,5},)',
      );
      expect(
        const Optionals(personMap: {'abc': Person(name: 'a', age: 1)})
            .toDartString(),
        'Optionals(personMap: {\'abc\': Person(name: \'a\',age: 1,)},)',
      );
    });

    test('return expected values for InheritedClass', () {
      expect(
        const InheritedClass(f: 1.0, i: 2).toDartString(),
        'InheritedClass(i: 2,u: 10,f: 1.0,)',
      );
    });

    test('return expected values for Nested', () {
      expect(
        const Nested(p: Person(name: 'Peter', age: 10)).toDartString(),
        'Nested(p: Person(name: \'Peter\',age: 10,),)',
      );
    });
  });
}
