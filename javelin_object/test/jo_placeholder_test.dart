import 'package:javelin_object/src/jo_placeholder.dart';
import 'package:test/test.dart';

void main() {
  group(JoPlaceholder, () {
    test('should throw when invalid method is invoked', () {
      final test = _PlaceholderTest();

      expect(() => test.test(), throwsArgumentError);
    });
  });
}

class _Test {
  void test() {}
}

class _PlaceholderTest extends JoPlaceholder implements _Test {}
