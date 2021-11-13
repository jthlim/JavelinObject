import 'dart:math';

import 'token.dart';

class Tokenizer {
  Tokenizer(String input)
      : _input = input,
        _length = input.length;

  final String _input;
  final int _length;

  var _offset = 0;
  var _line = 1;
  var _column = 0;

  Iterable<Token> tokenize() sync* {
    while (_offset < _length) {
      final c = _input.codeUnitAt(_offset++);
      _column++;

      switch (c) {
        case 0x09: // Tab
          _column = (_column + 1) & -2;
          continue;

        case 0x20: // Space
          continue;

        case 0x0d: // CR
          _column = 0;
          continue;

        case 0x0a: // LF
          _column = 0;
          ++_line;
          continue;

        case 0x22: // Double quote
        case 0x27: // Single quote
          yield ValueToken(
            _parseString(closingCharacter: c),
            line: _line,
            column: _column,
          );
          continue;

        case 0x2c: // ','
          yield Token(
            TokenType.comma,
            line: _line,
            column: _column,
          );
          continue;

        case 0x2d: // '-'
        case 0x2e: // '.'
          yield _parseNumber(c);
          continue;

        case 0x2f: // '/'
          if (_offset >= _length) {
            throw const FormatException('Unexpected end of input');
          }
          _column++;
          switch (_input.codeUnitAt(_offset++)) {
            case 0x2a: // '/*' -- skip to first '*/'
              var hasAsterisk = false;
              while (true) {
                if (_offset >= _length) {
                  throw const FormatException('Unexpected end of input');
                }

                final c = _input.codeUnitAt(_offset++);
                _column++;
                if (c == 0x2f && hasAsterisk) break;

                hasAsterisk = c == 0x2a;
              }
              break;

            case 0x2f: // '//' -- skip to end of line
              while (_offset < _length && _input.codeUnitAt(_offset) != 0x0a) {
                ++_offset;
                ++_column;
              }
              break;

            default:
              throw const FormatException('Unexpected input after \'/\'');
          }
          continue;

        case 0x3a: // ':'
          yield Token(TokenType.colon, line: _line, column: _column);
          continue;

        case 0x3c: // '<'
          yield Token(TokenType.leftAngleBracket, line: _line, column: _column);
          continue;

        case 0x3e: // '>'
          yield Token(
            TokenType.rightAngleBracket,
            line: _line,
            column: _column,
          );
          continue;

        case 0x5b: // '['
          yield Token(
            TokenType.leftSquareBracket,
            line: _line,
            column: _column,
          );
          continue;

        case 0x5d: // ']'
          yield Token(
            TokenType.rightSquareBracket,
            line: _line,
            column: _column,
          );
          continue;

        case 0x7b: // '{'
          yield Token(TokenType.leftCurlyBrace, line: _line, column: _column);
          continue;

        case 0x7d: // '}'
          yield Token(TokenType.rightCurlyBrace, line: _line, column: _column);
          continue;

        default:
          if (_isDigit(c)) {
            yield _parseNumber(c);
            continue;
          }

          if (!_isInitialIdentifierCodeUnit(c)) {
            throw FormatException(
              'Unexpected value in input $c at line $_line',
            );
          }
          final startOffset = _offset - 1;
          while (_offset < _length) {
            if (!_isIdentifierCodeUnit(_input.codeUnitAt(_offset))) break;
            ++_offset;
            ++_column;
          }
          final identifier = _input.substring(startOffset, _offset);

          switch (identifier) {
            case 'false':
              yield ValueToken(false, line: _line, column: _column);
              continue;

            case 'true':
              yield ValueToken(true, line: _line, column: _column);
              continue;

            case 'null':
              yield ValueToken(null, line: _line, column: _column);
              continue;

            default:
              throw FormatException('Unexpected identifier: $identifier');
          }
      }
    }
  }

  String _parseString({required int closingCharacter}) {
    final buffer = StringBuffer();
    while (true) {
      if (_offset >= _length) {
        throw const FormatException('Unmatched quote in file');
      }

      final c = _input.codeUnitAt(_offset++);
      _column++;
      if (c == closingCharacter) return buffer.toString();

      if (c == 0x0a) {
        ++_line;
        _column = 0;
      }

      // '\'
      if (c != 0x5c) {
        buffer.writeCharCode(c);
        continue;
      }

      if (_offset >= _length) {
        throw const FormatException('Unexepected end of input');
      }

      final v = _input.codeUnitAt(_offset++);
      _column++;

      // Support all string escapes from dart language specification 2.10 §17.7
      // https://dart.dev/guides/language/specifications/DartLangSpec-v2.10.pdf
      switch (v) {
        case 0x24: // '$'
          buffer.writeCharCode(0x24);
          continue;

        case 0x62: // 'b' -- Backspace
          buffer.writeCharCode(0x08);
          continue;

        case 0x66: // 'f' -- FF
          buffer.writeCharCode(0x0c);
          continue;

        case 0x6e: // 'n' -- LF
          buffer.writeCharCode(0x0a);
          continue;

        case 0x72: // 'r' -- CR
          buffer.writeCharCode(0x0d);
          continue;

        case 0x74: // 't' -- tab
          buffer.writeCharCode(0x09);
          continue;

        case 0x76: // 'v' -- vertical tab
          buffer.writeCharCode(0x0b);
          continue;

        case 0x5c: // '\'
          buffer.writeCharCode(0x5c);
          continue;

        case 0x75: // 'u'
          _parseHexCharCode(buffer, 2);
          continue;

        case 0x78: // 'x'
          _parseHexCharCode(buffer, 4);
          continue;

        default:
          buffer.writeCharCode(v);
          continue;
      }
    }
  }

  void _parseHexCharCode(StringBuffer buffer, int defaultLength) {
    var c = _input.codeUnitAt(_offset++);
    var value = 0;
    if (c == 0x7b) {
      for (;;) {
        c = _input.codeUnitAt(_offset++);
        if (c == 0x7d) break;
        final hexValue = _hexValue(c);
        if (hexValue == -1) {
          throw FormatException('Invalid hex character $c');
        }
        value = 16 * value + hexValue;
      }
    } else {
      value = _hexValue(c);
      if (value == -1) {
        throw FormatException('Invalid hex character $c');
      }
      for (var i = 1; i < defaultLength; ++i) {
        c = _input.codeUnitAt(_offset++);
        final hexValue = _hexValue(c);
        if (hexValue == -1) {
          throw FormatException('Invalid hex character $c');
        }
        value = 16 * value + hexValue;
      }
    }

    buffer.writeCharCode(value);
  }

  Token _parseNumber(int firstCodeUnit) {
    final line = _line;
    final column = _column;
    var sign = 1;

    var hasIntegerPortion = false;
    var isDouble = false;
    var fractionalPower = 0;

    var c = firstCodeUnit;
    if (c == 0x2d) {
      sign = -1;
      c = _getC();
    }

    var value = 0;

    if (_isDigit(c)) {
      hasIntegerPortion = true;
      value = c - 0x30;
      while (true) {
        c = _getC();
        if (!_isDigit(c)) break;

        value = 10 * value + (c - 0x30);
      }
    }

    // '.'
    if (c == 0x2e) {
      isDouble = true;
      c = _getC();

      while (_isDigit(c)) {
        value = 10 * value + (c - 0x30);
        --fractionalPower;
        c = _getC();
      }
    }

    // 'e' or 'E'
    if (c == 0x45 || c == 0x65) {
      isDouble = true;

      c = _getC();

      var powerSign = 1;
      if (c == 0x2d) {
        powerSign = -1;
        c = _getC();
      }

      if (!_isDigit(c)) throw FormatException('Invalid number L$line:$column');

      var powerValue = c - 0x30;
      while (true) {
        c = _getC();
        if (!_isDigit(c)) break;
        powerValue = 10 * powerValue + (c - 0x30);
      }

      fractionalPower += powerSign * powerValue;
    }

    if (c != -1) --_offset;

    if (hasIntegerPortion && !isDouble) {
      return ValueToken(sign * value, line: line, column: column);
    }

    var result = (sign * value).toDouble();

    // This next block is equivalent to:
    //  result *= pow(10, fractionalPower);
    // But doing a divide by a power of 10 gives more precise results.
    if (fractionalPower < 0) {
      result /= pow(10, -fractionalPower);
    } else if (fractionalPower > 0) {
      result *= pow(10, fractionalPower);
    }

    return ValueToken(result, line: line, column: column);
  }

  int _getC() {
    if (_offset < _length) {
      final c = _input.codeUnitAt(_offset);
      ++_offset;
      ++_column;
      return c;
    } else {
      return -1;
    }
  }

  static bool _isDigit(int c) {
    return 0x30 <= c && c <= 0x39;
  }

  static int _hexValue(int c) {
    if (0x30 <= c && c <= 0x39) return c - 0x30;
    if (0x41 <= c && c <= 0x46) return c - 0x41 + 10;
    if (0x61 <= c && c <= 0x66) return c - 0x61 + 10;
    return -1;
  }

  static bool _isInitialIdentifierCodeUnit(int c) {
    // 'A' -> 'Z'
    if (0x41 <= c && c <= 0x5a) return true;

    // 'a' -> 'z'
    if (0x61 <= c && c <= 0x7a) return true;

    return false;
  }

  static bool _isIdentifierCodeUnit(int c) {
    if (_isInitialIdentifierCodeUnit(c)) return true;

    // '_'
    if (c == 0x5f) return true;

    // '0' -> '9'
    if (0x30 <= c && c <= 0x39) return true;

    return false;
  }
}
