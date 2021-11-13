import 'package:javelin_object/jo_internal.dart';
import 'package:test/test.dart';

import 'binary_test.jo.dart';

void main() {
  group(Binary, () {
    test('should serialize object to the expected bytes', () {
      final b = Binary(
        b: true,
        i: 10,
        u: 20,
        f: 2.0,
        d: -100.0,
        bytes: Uint8List.fromList([1, 2, 3]),
        string: 'xyz',
        e: EnumValue.b,
      );

      expect(
        b.toBytes(),
        const [
          0x01, // true
          0x18, 0x13, // 10
          0x28, 0x14, // 20
          0x33, // 2.0
          0x49, 0x40, 0xd6, // -100.0
          0x5a, 0x01, 0x02, 0x03, // [1,2,3]
          0x6a, 0x78, 0x79, 0x7a, // 'xyz'
          0x71, // EnumValue.b
        ],
      );
    });

    group('when serializing bytes', () {
      test('should convert properly when there are no bytes', () {
        final b = Binary(bytes: Uint8List.fromList([]));

        expect(b.toBytes(), const [0x50]);
      });

      test('should convert properly when there is a single byte', () {
        final b0 = Binary(bytes: Uint8List.fromList([0]));
        final b1 = Binary(bytes: Uint8List.fromList([1]));
        final b2 = Binary(bytes: Uint8List.fromList([2]));
        final b3 = Binary(bytes: Uint8List.fromList([3]));

        expect(b0.toBytes(), const [0x51]);
        expect(b1.toBytes(), const [0x52]);
        expect(b2.toBytes(), const [0x53]);
        expect(b3.toBytes(), const [0x58, 0x03]);
      });
    });

    test('should deserialize the object to the same values', () {
      final b = Binary(
        b: true,
        i: 10,
        u: 20,
        f: 2.0,
        d: -100.0,
        bytes: Uint8List.fromList([1, 2, 3]),
        string: 'xyz',
        e: EnumValue.b,
      );

      final rebuilt = Binary.fromBytes(b.toBytes());
      expect(rebuilt, equals(b));
    });
  });

  group(ListTest, () {
    test('should serialize and deserialize a list of ints correctly', () {
      final listTest = ListTest();
      listTest.a = [1, 2, 3];

      expect(listTest.toBytes(), [0x0a, 0x01, 0x03, 0x05]);

      final rebuilt = ListTest.fromBytes(listTest.toBytes());
      expect(rebuilt, listTest);
    });

    test('should serialize and deserialize a list of list of ints correctly',
        () {
      final listTest = ListTest();
      listTest.b = [
        [1, 2, 3],
        [4, 5, 6]
      ];

      expect(
        listTest.toBytes(),
        [0x1f, 0xc2, 0x01, 0x03, 0x05, 0xc2, 0x07, 0x09, 0x0b],
      );

      final rebuilt = ListTest.fromBytes(listTest.toBytes());
      expect(rebuilt, listTest);
    });

    test('should serialize and deserialize a List of Person objects correctly',
        () {
      final listTest = ListTest();
      listTest.f = [
        Person(name: 'Amy', age: 20),
        Person(name: 'Bob', age: 30),
      ];

      expect(
        listTest.toBytes(),
        [
          0x54, 0x0e, // Field 'f'
          0xc5, 0x0a, 0x41, 0x6d, 0x79, 0x18, 0x14, // name: 'Amy', age: 20
          0xc5, 0x0a, 0x42, 0x6f, 0x62, 0x18, 0x1e, // name: 'Bob', age: 30
        ],
      );

      final rebuilt = ListTest.fromBytes(listTest.toBytes());
      expect(rebuilt, listTest);
    });

    test('should serialize and deserialize a List of maps correctly', () {
      final listTest = ListTest();
      listTest.g = [
        {1: 3, 10: 30},
        {2: 4, 20: 40},
      ];

      expect(
        listTest.toBytes(),
        [
          0x64, 0x0a, // Field 'g'
          0xc3, 0x01, 0x05, 0x13, 0x3b,
          0xc3, 0x03, 0x07, 0x27, 0x4f,
        ],
      );

      final rebuilt = ListTest.fromBytes(listTest.toBytes());
      expect(rebuilt, listTest);
    });

    test('should serialize and deserialize a List of compact maps correctly',
        () {
      final listTest = ListTest();
      listTest.g = [
        {1: 3},
        {2: 4},
      ];

      expect(
        listTest.toBytes(),
        [
          0x69, // Field 'g'
          0x48, // {1: 3}
          0x66, // {2: 4}
        ],
      );

      final rebuilt = ListTest.fromBytes(listTest.toBytes());
      expect(rebuilt, listTest);
    });

    test('should serialize and deserialize a list of strings correctly', () {
      final list1 = ListTest(c: []);
      final list2 = ListTest(c: ['a']);
      final list3 = ListTest(c: ['a', 'b']);
      final list4 = ListTest(c: ['a', 'b', '']);

      expect(list1.toBytes(), [0x20]);
      expect(list2.toBytes(), [0x28, 0x62]);
      expect(list3.toBytes(), [0x29, 0x62, 0x63]);
      expect(list4.toBytes(), [0x2a, 0x62, 0x63, 0x00]);

      expect(ListTest.fromBytes(list1.toBytes()), list1);
      expect(ListTest.fromBytes(list2.toBytes()), list2);
      expect(ListTest.fromBytes(list3.toBytes()), list3);
      expect(ListTest.fromBytes(list4.toBytes()), list4);
    });

    test('should serialize and deserialize a List of unions correctly', () {
      final listTest = ListTest();
      listTest.h = [
        Union.b(true),
        Union.string('abc'),
        Union.e(EnumValue.a),
      ];

      expect(
        listTest.toBytes(),
        [
          0x7e, // Field 'h'
          0x02, // true
          0xc3, 0x6a, 0x61, 0x62, 0x63, // string('abc')
          0x71, // EnumValue.a
        ],
      );

      final rebuilt = ListTest.fromBytes(listTest.toBytes());
      expect(rebuilt, listTest);
    });

    test('when deserializing a list of enums, should drop unknown values', () {
      final listTest =
          ListTest.fromBytes(Uint8List.fromList([0x4a, 0x03, 0x04, 0x05]));
      expect(listTest.e, hasLength(2));
      expect(listTest.e, [EnumValue.d, EnumValue.e]);
    });

    test('when deserializing a list of unions, should drop unknown values', () {
      final listTest = ListTest.fromBytes(Uint8List.fromList(
        [
          0x7e, // Field 'h'
          0x02, // true
          0xc3, 0x6a, 0x61, 0x62, 0x63, // string('abc')
          0x81, // Unknown enum value
        ],
      ));
      expect(listTest.h, hasLength(2));
      expect(listTest.h, [Union.b(true), Union.string('abc')]);
    });
  });

  group(MapTest, () {
    test('should serialize and deserialize a map of int->int correctly', () {
      final mapTest = MapTest();
      mapTest.a = {1: 3, 10: 30};

      expect(mapTest.toBytes(), [0x0b, 0x01, 0x05, 0x13, 0x3b]);

      final rebuilt = MapTest.fromBytes(mapTest.toBytes());
      expect(rebuilt, mapTest);
    });

    test('should serialize and deserialize a map of String->enum correctly',
        () {
      final mapTest = MapTest();
      mapTest.f = {'aaa': EnumValue.a, 'bbb': EnumValue.b};

      expect(
        mapTest.toBytes(),
        [
          0x54, 0x0a, // Field f
          0xc2, 0x61, 0x61, 0x61, 0x00,
          0xc2, 0x62, 0x62, 0x62, 0x01,
        ],
      );

      final rebuilt = MapTest.fromBytes(mapTest.toBytes());
      expect(rebuilt, mapTest);
    });
  });

  group(BoolWrapTest, () {
    test('should serialize and deserialize a wrapped bool correctly', () {
      final boolWrapTest = BoolWrapTest(b: BoolWrapper(b: true));

      // Encodes to field 0, constant 2,
      // which unwraps to a single byte of value 1.
      expect(boolWrapTest.toBytes(), [0x02]);

      final rebuilt = BoolWrapTest.fromBytes(boolWrapTest.toBytes());
      expect(rebuilt, boolWrapTest);
    });
  });

  group(Union, () {
    test('should serialize and deserialize unions to the same value', () {
      void testUnionEncoding(Union u, List<int> bytes) {
        expect(u.toBytes(), bytes);
        expect(Union.fromBytes(u.toBytes()), u);
      }

      testUnionEncoding(Union.b(false), [0x00]);
      testUnionEncoding(Union.b(true), [0x01]);
      testUnionEncoding(Union.i(1), [0x11]);
      testUnionEncoding(Union.i(100), [0x18, 0xc7]);
      testUnionEncoding(Union.u(1), [0x21]);
      testUnionEncoding(Union.u(100), [0x28, 0x64]);
      testUnionEncoding(Union.f(1.0), [0x31]);
      testUnionEncoding(Union.f(1.5), [0x38, 0x38]);
      testUnionEncoding(Union.d(1.0), [0x41]);
      testUnionEncoding(Union.d(1.5), [0x48, 0x38]);
      testUnionEncoding(Union.bytes(Uint8List(0)), [0x50]);
      testUnionEncoding(Union.bytes(Uint8List(1)..[0] = 1), [0x52]);
      testUnionEncoding(Union.string(''), [0x60]);
      testUnionEncoding(Union.string('abc'), [0x6a, 0x61, 0x62, 0x63]);
      testUnionEncoding(Union.e(EnumValue.a), [0x70]);
      testUnionEncoding(Union.e(EnumValue.e), [0x78, 0x04]);
      testUnionEncoding(Union.un(Union.b(false)), [0x81]);
      testUnionEncoding(Union.un(Union.e(EnumValue.e)), [0x89, 0x78, 0x04]);
    });
  });

  group(InlineUnion, () {
    test('should serialize and deserialize inline unions to the same value',
        () {
      void testUnionEncoding(InlineUnion u, List<int> bytes) {
        expect(u.toBytes(), bytes);
        expect(InlineUnion.fromBytes(u.toBytes()), u);
      }

      testUnionEncoding(InlineUnion.b(false), [0x00]);
      testUnionEncoding(InlineUnion.b(true), [0x01]);
      testUnionEncoding(InlineUnion.i(1), [0x11]);
      testUnionEncoding(InlineUnion.i(100), [0x18, 0xc7]);
      testUnionEncoding(InlineUnion.string(''), [0x20]);
      testUnionEncoding(InlineUnion.string('abc'), [0x2a, 0x61, 0x62, 0x63]);
    });
  });

  group(UnionWrapper, () {
    test('should serialize and deserialize unions to the same value', () {
      void testUnionEncoding(Union u, List<int> bytes) {
        final wrapper = UnionWrapper(u: u);
        expect(wrapper.toBytes(), bytes);
        expect(UnionWrapper.fromBytes(wrapper.toBytes()), wrapper);
      }

      testUnionEncoding(Union.b(false), [0x01]);
      testUnionEncoding(Union.b(true), [0x02]);
      testUnionEncoding(Union.i(1), [0x08, 0x11]);
      testUnionEncoding(Union.i(100), [0x09, 0x18, 0xc7]);
      testUnionEncoding(Union.u(1), [0x08, 0x21]);
      testUnionEncoding(Union.u(100), [0x09, 0x28, 0x64]);
      testUnionEncoding(Union.f(1.0), [0x08, 0x31]);
      testUnionEncoding(Union.f(1.5), [0x09, 0x38, 0x38]);
      testUnionEncoding(Union.d(1.0), [0x08, 0x41]);
      testUnionEncoding(Union.d(1.5), [0x09, 0x48, 0x38]);
      testUnionEncoding(Union.bytes(Uint8List(0)), [0x08, 0x50]);
      testUnionEncoding(Union.bytes(Uint8List(1)..[0] = 1), [0x08, 0x52]);
      testUnionEncoding(Union.string(''), [0x08, 0x60]);
      testUnionEncoding(Union.string('abc'), [0x0b, 0x6a, 0x61, 0x62, 0x63]);
      testUnionEncoding(Union.e(EnumValue.a), [0x08, 0x70]);
      testUnionEncoding(Union.e(EnumValue.e), [0x09, 0x78, 0x04]);
      testUnionEncoding(Union.un(Union.b(false)), [0x08, 0x81]);
      testUnionEncoding(
        Union.un(Union.e(EnumValue.e)),
        [0x0a, 0x89, 0x78, 0x04],
      );
    });
  });

  group(NullableUnionWrapper, () {
    test('should serialize and deserialize unions to the same value', () {
      void testUnionEncoding(Union? u, List<int> bytes) {
        final wrapper = NullableUnionWrapper(u: u);
        expect(wrapper.toBytes(), bytes);
        expect(NullableUnionWrapper.fromBytes(wrapper.toBytes()), wrapper);
      }

      testUnionEncoding(null, []);
      testUnionEncoding(Union.b(false), [0x01]);
      testUnionEncoding(Union.b(true), [0x02]);
      testUnionEncoding(Union.i(1), [0x08, 0x11]);
      testUnionEncoding(Union.i(100), [0x09, 0x18, 0xc7]);
      testUnionEncoding(Union.u(1), [0x08, 0x21]);
      testUnionEncoding(Union.u(100), [0x09, 0x28, 0x64]);
      testUnionEncoding(Union.f(1.0), [0x08, 0x31]);
      testUnionEncoding(Union.f(1.5), [0x09, 0x38, 0x38]);
      testUnionEncoding(Union.d(1.0), [0x08, 0x41]);
      testUnionEncoding(Union.d(1.5), [0x09, 0x48, 0x38]);
      testUnionEncoding(Union.bytes(Uint8List(0)), [0x08, 0x50]);
      testUnionEncoding(Union.bytes(Uint8List(1)..[0] = 1), [0x08, 0x52]);
      testUnionEncoding(Union.string(''), [0x08, 0x60]);
      testUnionEncoding(Union.string('abc'), [0x0b, 0x6a, 0x61, 0x62, 0x63]);
      testUnionEncoding(Union.e(EnumValue.a), [0x08, 0x70]);
      testUnionEncoding(Union.e(EnumValue.e), [0x09, 0x78, 0x04]);
      testUnionEncoding(Union.un(Union.b(false)), [0x08, 0x81]);
      testUnionEncoding(
        Union.un(Union.e(EnumValue.e)),
        [0x0a, 0x89, 0x78, 0x04],
      );
    });
  });

  group(InheritedClass, () {
    test('should serialize and deserialized a derived object correctly', () {
      const d = InheritedClass(i: 1, b: true, f: 3.0);

      expect(d.toBytes(), [
        0x0a, 0x01, 0x18, 0x48, // Derived class, f: 3.0
        0x11, // true
        0x38, 0x0a, // u: 10
      ]);
      expect(InheritedClass.fromBytes(d.toBytes()), d);
      expect(d.d, 20.0);
    });

    test(
        'should serialize derived class and deserialized it as its base class '
        'correctly', () {
      const d = InheritedClass(i: 1, b: true, f: 3.0);
      final b = BaseClass.fromBytes(d.toBytes());

      expect(b.i, 1);
    });
  });

  group(UnionWithOptionals, () {
    test('should serialize and deserialize optional int field properly', () {
      const a1 = UnionWithOptionals.a();
      const a2 = UnionWithOptionals.a(1);
      const a3 = UnionWithOptionals.a(10);

      expect(a1.toBytes(), [0x00]);
      expect(a2.toBytes(), [0x02]);
      expect(a3.toBytes(), [0x08, 0x13]);

      expect(UnionWithOptionals.fromBytes(a1.toBytes()), a1);
      expect(UnionWithOptionals.fromBytes(a2.toBytes()), a2);
      expect(UnionWithOptionals.fromBytes(a3.toBytes()), a3);
    });
  });
}
