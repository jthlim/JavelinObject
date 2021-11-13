import 'package:javelin_object/src/jo_containers.dart';
import 'package:test/test.dart';

void main() {
  group('JoImmutableList', () {
    test('should return a new list if the input is not a JoImmutableList', () {
      const values = [1, 2];
      expect(values, isNot(same(JoImmutableList.of(values))));
    });

    test('should return an identical list if the input is a JoImmutableList',
        () {
      const values = JoImmutableList([1, 2]);
      expect(values, same(JoImmutableList.of(values)));
    });
  });

  group('JoImmutableSet', () {
    test('should return a new set if the input is not a JoImmutableSet', () {
      const values = {1, 2};
      expect(values, isNot(same(JoImmutableSet.of(values))));
    });

    test('should return an identical set if the input is a JoImmutableSet', () {
      const values = JoImmutableSet({1, 2});
      expect(values, same(JoImmutableSet.of(values)));
    });
  });

  group('JoImmutableMap', () {
    test('should return a new map if the input is not a JoImmutableMap', () {
      const values = {1: 2};
      expect(values, isNot(same(JoImmutableMap.of(values))));
    });

    test('should return an identical map if the input is a JoImmutableMap', () {
      const values = JoImmutableMap({1: 2});
      expect(values, same(JoImmutableMap.of(values)));
    });
  });
}
