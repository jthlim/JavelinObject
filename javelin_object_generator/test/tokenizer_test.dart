import 'package:javelin_object_generator/src/token.dart';
import 'package:javelin_object_generator/src/tokenizer.dart';
import 'package:test/test.dart';

void main() {
  group(Tokenizer, () {
    test('should tokenize simple tokens', () {
      final result = Tokenizer(',:;<=>?<>[]{}()', '').tokenize();

      expect(
        result.toList(),
        [
          const Token(data: TokenData.comma(), line: 1, column: 1),
          const Token(data: TokenData.colon(), line: 1, column: 2),
          const Token(data: TokenData.semicolon(), line: 1, column: 3),
          const Token(data: TokenData.leftAngleBracket(), line: 1, column: 4),
          const Token(data: TokenData.equals(), line: 1, column: 5),
          const Token(data: TokenData.rightAngleBracket(), line: 1, column: 6),
          const Token(data: TokenData.questionMark(), line: 1, column: 7),
          const Token(data: TokenData.leftAngleBracket(), line: 1, column: 8),
          const Token(data: TokenData.rightAngleBracket(), line: 1, column: 9),
          const Token(data: TokenData.leftSquareBracket(), line: 1, column: 10),
          const Token(
            data: TokenData.rightSquareBracket(),
            line: 1,
            column: 11,
          ),
          const Token(data: TokenData.leftCurlyBrace(), line: 1, column: 12),
          const Token(data: TokenData.rightCurlyBrace(), line: 1, column: 13),
          const Token(data: TokenData.leftParenthesis(), line: 1, column: 14),
          const Token(data: TokenData.rightParenthesis(), line: 1, column: 15),
        ],
      );
    });

    test('should tokenize strings', () {
      final result = Tokenizer('"Hello" "\r\n\t\f\b\v"', '').tokenize();

      expect(
        result.toList().map((token) => token.data),
        const [
          TokenData.stringValue('Hello'),
          TokenData.stringValue('\r\n\t\f\b\v'),
        ],
      );
    });

    test('should tokenize words', () {
      final result = Tokenizer('class myClass false true', '').tokenize();

      expect(
        result.toList(),
        const [
          Token(data: TokenData.classKeyword(), line: 1, column: 1),
          Token(data: TokenData.identifier('myClass'), line: 1, column: 7),
          Token(data: TokenData.boolValue(false), line: 1, column: 15),
          Token(data: TokenData.boolValue(true), line: 1, column: 21),
        ],
      );
    });

    test('should tokenize hex values correctly', () {
      final result = Tokenizer('0xff 0x10000', '').tokenize();
      expect(
        result.toList().map((token) => token.data),
        const [
          TokenData.intValue(255),
          TokenData.intValue(65536),
        ],
      );
    });

    test('should tokenize numbers correctly', () {
      final result = Tokenizer(
        '0 1 -1 1. -1. 1.2 -1.2 0.12 -0.12 .12 -.12 1.2e1 1.2e-1 '
            '1e10 -1.e10 1.2e10 -1.2e10 .1e10 -.1e-10',
        '',
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
      final result = Tokenizer(
        'class /* something */ myClass // false\n true',
        '',
      ).tokenize();

      expect(
        result.toList(),
        [
          const Token(data: TokenData.classKeyword(), line: 1, column: 1),
          const Token(
            data: TokenData.identifier('myClass'),
            line: 1,
            column: 23,
          ),
          const Token(data: TokenData.boolValue(true), line: 2, column: 2),
        ],
      );
    });
  });
}
