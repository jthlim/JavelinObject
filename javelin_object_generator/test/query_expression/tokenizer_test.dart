import 'package:javelin_object_generator/src/query_expression/token.jo.dart';
import 'package:javelin_object_generator/src/query_expression/tokenizer.dart';
import 'package:test/test.dart';

void main() {
  group('Query Expression', () {
    group(Tokenizer, () {
      test('should tokenize simple tokens', () {
        final result = Tokenizer('< <= > >= == != . [] ()').tokenize();

        expect(
          result.toList(),
          [
            const Token(data: TokenData.lessThan(), offset: 0),
            const Token(data: TokenData.lessThanOrEquals(), offset: 2),
            const Token(data: TokenData.greaterThan(), offset: 5),
            const Token(data: TokenData.greaterThanOrEquals(), offset: 7),
            const Token(data: TokenData.equals(), offset: 10),
            const Token(data: TokenData.notEquals(), offset: 13),
            const Token(data: TokenData.dot(), offset: 16),
            const Token(data: TokenData.leftSquareBracket(), offset: 18),
            const Token(data: TokenData.rightSquareBracket(), offset: 19),
            const Token(data: TokenData.leftParenthesis(), offset: 21),
            const Token(data: TokenData.rightParenthesis(), offset: 22),
          ],
        );
      });

      test('should tokenize strings', () {
        final result = Tokenizer('"Hello" \'\r\n\t\f\b\v\'').tokenize();

        expect(
          result.toList().map((token) => token.data),
          const [
            TokenData.stringValue('Hello'),
            TokenData.stringValue('\r\n\t\f\b\v'),
          ],
        );
      });

      test('should tokenize words', () {
        final result = Tokenizer('false true value \$value').tokenize();

        expect(
          result.toList(),
          const [
            Token(data: TokenData.boolValue(false), offset: 0),
            Token(data: TokenData.boolValue(true), offset: 6),
            Token(data: TokenData.identifier('value'), offset: 11),
            Token(data: TokenData.parameter('value'), offset: 17),
          ],
        );
      });

      test('should tokenize numbers correctly', () {
        final result = Tokenizer(
          '0 1 -1 1. -1. 1.2 -1.2 0.12 -0.12 .12 -.12 1.2e1 1.2e-1 '
          '1e10 -1.e10 1.2e10 -1.2e10 .1e10 -.1e-10',
        ).tokenize();

        expect(
          result.toList().map((token) => token.data),
          const [
            TokenData.intValue(0),
            TokenData.intValue(1),
            TokenData.intValue(-1),
            TokenData.doubleValue(1),
            TokenData.doubleValue(-1),
            TokenData.doubleValue(1.2),
            TokenData.doubleValue(-1.2),
            TokenData.doubleValue(0.12),
            TokenData.doubleValue(-0.12),
            TokenData.doubleValue(0.12),
            TokenData.doubleValue(-0.12),
            TokenData.doubleValue(1.2e1),
            TokenData.doubleValue(1.2e-1),
            TokenData.doubleValue(1e10),
            TokenData.doubleValue(-1e10),
            TokenData.doubleValue(1.2e10),
            TokenData.doubleValue(-1.2e10),
            TokenData.doubleValue(.1e10),
            TokenData.doubleValue(-.1e-10),
          ],
        );
      });

      test('should ignore comments', () {
        final result =
            Tokenizer('class /* something */ myClass // false\n true')
                .tokenize();

        expect(
          result.toList(),
          [
            const Token(data: TokenData.identifier('class'), offset: 0),
            const Token(data: TokenData.identifier('myClass'), offset: 22),
            const Token(data: TokenData.boolValue(true), offset: 40),
          ],
        );
      });
    });
  });
}
