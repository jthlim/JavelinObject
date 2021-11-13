import 'package:test/test.dart';

import 'copy_with_test.jo.dart';

void main() {
  group(Simple, () {
    test('should copyWith on a non-optional field properly', () {
      const obj = Simple(b: true, d: 2.0, l: []);

      expect(obj.copyWith(d: 4.0), const Simple(b: true, d: 4.0, l: []));
      expect(obj.copyWith(i: 3), const Simple(b: true, i: 3, d: 2.0, l: []));
    });

    test('copyWith should set null properly', () {
      const obj = Simple(b: true, i: 10, d: 2.0, l: [], s: {1, 2, 3});

      expect(
        obj.copyWith(i: null),
        const Simple(b: true, d: 2.0, l: [], s: {1, 2, 3}),
      );
      expect(
        obj.copyWith(s: null),
        const Simple(b: true, i: 10, d: 2.0, l: []),
      );
    });
  });

  group('Nested classes', () {
    test('should copyWith on immediate fields', () {
      const obj = A(a1: true, b: B(b1: 10, c: C(c1: 2.0)));

      expect(
        obj.copyWith(a1: false),
        const A(a1: false, b: B(b1: 10, c: C(c1: 2.0))),
      );

      expect(
        obj.copyWith(a2: 'abc'),
        const A(a1: true, a2: 'abc', b: B(b1: 10, c: C(c1: 2.0))),
      );
    });

    test('should copyWith on subfields fields', () {
      const obj = A(a1: true, b: B(b1: 10, c: C(c1: 2.0)));

      expect(
        obj.copyWith.b(b2: -1.0),
        const A(a1: true, b: B(b1: 10, b2: -1.0, c: C(c1: 2.0))),
      );

      expect(
        obj.copyWith.b.c(c1: 100.0),
        const A(a1: true, b: B(b1: 10, c: C(c1: 100.0))),
      );

      expect(
        obj.copyWith.b.c(d: const D(d1: false)),
        const A(a1: true, b: B(b1: 10, c: C(c1: 2.0, d: D(d1: false)))),
      );

      expect(
        obj.copyWith.b.c.d(d1: false),
        const A(a1: true, b: B(b1: 10, c: C(c1: 2.0, d: D(d1: false)))),
      );
    });
  });
}
