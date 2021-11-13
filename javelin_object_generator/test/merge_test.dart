import 'package:test/test.dart';

import 'merge_test.jo.dart';

void main() {
  group(SimpleMerge, () {
    test('should not merge with fallback when value is set', () {
      const a = SimpleMerge(a: '1', b: '2');
      const b = SimpleMerge(a: '3', b: '4');
      const c = SimpleMerge(a: '5');

      expect(a.mergeWith(b), const SimpleMerge(a: '1', b: '2'));
      expect(a.mergeWith(c), const SimpleMerge(a: '1', b: '2'));
    });

    test('should merge with fallback when value is unset', () {
      const a = SimpleMerge(a: '1');
      const b = SimpleMerge(a: '3', b: '4');
      const c = SimpleMerge(a: '5');

      expect(a.mergeWith(b), const SimpleMerge(a: '1', b: '4'));
      expect(a.mergeWith(c), const SimpleMerge(a: '1'));
    });
  });

  group(Outer, () {
    test('should merge with inner objects properly when values are set', () {
      const a = Outer(
        a: Inner(x: '1', y: '2'),
        b: Inner(x: '3', y: '4'),
        c: Inner(x: '5', y: '6'),
        d: Inner(x: '7', y: '8'),
      );
      const b = Outer(
        a: Inner(x: '11', y: '22'),
        b: Inner(x: '33', y: '44'),
        c: Inner(x: '55', y: '66'),
        d: Inner(x: '77', y: '88'),
      );

      expect(a.mergeWith(b), a);
    });

    test(
        'should merge with inner objects properly when inner values have nulls',
        () {
      const a = Outer(
        a: Inner(x: '1'),
        b: Inner(x: '3'),
        c: Inner(x: '5'),
        d: Inner(x: '7'),
      );
      const b = Outer(
        a: Inner(x: '11', y: '22'),
        b: Inner(x: '33', y: '44'),
        c: Inner(x: '55', y: '66'),
        d: Inner(x: '77', y: '88'),
      );

      expect(
        a.mergeWith(b),
        const Outer(
          a: Inner(x: '1'),
          b: Inner(x: '3', y: '44'),
          c: Inner(x: '5'),
          d: Inner(x: '7', y: '88'),
        ),
      );
    });

    test(
        'should merge with inner objects properly when outer values have nulls',
        () {
      const a = Outer(
        a: Inner(x: '1'),
        b: Inner(x: '3'),
      );
      const b = Outer(
        a: Inner(x: '11', y: '22'),
        b: Inner(x: '33', y: '44'),
        c: Inner(x: '55', y: '66'),
        d: Inner(x: '77', y: '88'),
      );

      expect(
        a.mergeWith(b),
        const Outer(
          a: Inner(x: '1'),
          b: Inner(x: '3', y: '44'),
          c: Inner(x: '55', y: '66'),
          d: Inner(x: '77', y: '88'),
        ),
      );
    });

    test(
        'should merge with inner objects properly when inner and outer values '
        'have nulls', () {
      const a = Outer(
        a: Inner(x: '1'),
        b: Inner(x: '3'),
      );
      const b = Outer(
        a: Inner(x: '11', y: '22'),
        b: Inner(x: '33', y: '44'),
      );

      expect(
        a.mergeWith(b),
        const Outer(
          a: Inner(x: '1'),
          b: Inner(x: '3', y: '44'),
        ),
      );
    });
  });
}
