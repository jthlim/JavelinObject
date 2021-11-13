import 'dart:math';

import 'token.jo.dart';

class Tokenizer {
  Tokenizer(String input)
      : _input = input,
        _length = input.length;

  final String _input;
  final int _length;

  var _offset = 0;

  Iterable<Token> tokenize() sync* {
    while (_offset < _length) {
      final c = _input.codeUnitAt(_offset++);

      switch (c) {
        case 0x09: // Tab
        case 0x20: // Space
        case 0x0d: // CR
        case 0x0a: // LF
          continue;

        case 0x22: // Double quote
        case 0x27: // Single quote
          yield Token(
            data: TokenData.stringValue(
              _parseString(closingCharacter: c),
            ),
            offset: _offset - 1,
          );
          continue;

        case 0x24: // '$'
          final startOffset = _offset - 1;
          final c = _getC();
          if (!_isInitialIdentifierCodeUnit(c)) {
            throw FormatException(
              'Expected name after \'\$\'',
              _input,
              startOffset,
            );
          }
          while (_offset < _length) {
            if (!_isIdentifierCodeUnit(_input.codeUnitAt(_offset))) break;
            ++_offset;
          }
          final parameter = _input.substring(startOffset + 1, _offset);

          yield Token(
            data: TokenData.parameter(parameter),
            offset: startOffset,
          );
          continue;

        case 0x28: // '('
          yield Token(
            data: const TokenData.leftParenthesis(),
            offset: _offset - 1,
          );
          continue;

        case 0x29: // ')'
          yield Token(
            data: const TokenData.rightParenthesis(),
            offset: _offset - 1,
          );
          continue;

        case 0x2e: // '.'
          if (_offset < _length && _isDigit(_input.codeUnitAt(_offset))) {
            yield _parseNumber(c);
          } else {
            yield Token(
              data: const TokenData.dot(),
              offset: _offset - 1,
            );
          }
          continue;

        case 0x2d: // '-'
          yield _parseNumber(c);
          continue;

        case 0x2f: // '/'
          switch (_getC()) {
            case 0x2a: // '/*' -- skip to first '*/'
              var hasAsterisk = false;
              while (true) {
                if (_offset >= _length) {
                  throw const FormatException('Unexpected end of input');
                }

                final c = _input.codeUnitAt(_offset++);
                if (c == 0x2f && hasAsterisk) break;

                hasAsterisk = c == 0x2a;
              }
              break;

            case 0x2f: // '//' -- skip to end of line.
              while (_offset < _length) {
                final c = _input.codeUnitAt(_offset);
                ++_offset;
                if (c == 0x0a) break;
              }
              break;

            default:
              throw FormatException(
                'Unexpected input after \'/\'',
                _input,
                _offset - 1,
              );
          }
          continue;

        case 0x21: // '!'
          if (_offset < _length && _input.codeUnitAt(_offset) == 0x3d) {
            ++_offset;
            yield Token(
              data: const TokenData.notEquals(),
              offset: _offset - 2,
            );
          } else {
            yield Token(
              data: const TokenData.minus(),
              offset: _offset - 1,
            );
          }
          continue;

        case 0x3c: // '<'
          if (_offset < _length && _input.codeUnitAt(_offset) == 0x3d) {
            ++_offset;
            yield Token(
              data: const TokenData.lessThanOrEquals(),
              offset: _offset - 2,
            );
          } else {
            yield Token(
              data: const TokenData.lessThan(),
              offset: _offset - 1,
            );
          }
          continue;

        case 0x3d: // '='
          if (_offset < _length && _input.codeUnitAt(_offset) == 0x3d) {
            ++_offset;
            yield Token(
              data: const TokenData.equals(),
              offset: _offset - 2,
            );
          } else {
            throw FormatException('Expected ==', _input, _offset);
          }
          continue;

        case 0x3e: // '>'
          if (_offset < _length && _input.codeUnitAt(_offset) == 0x3d) {
            ++_offset;
            yield Token(
              data: const TokenData.greaterThanOrEquals(),
              offset: _offset - 2,
            );
          } else {
            yield Token(
              data: const TokenData.greaterThan(),
              offset: _offset - 1,
            );
          }
          continue;

        case 0x5b: // '['
          yield Token(
            data: const TokenData.leftSquareBracket(),
            offset: _offset - 1,
          );
          continue;

        case 0x5d: // ']'
          yield Token(
            data: const TokenData.rightSquareBracket(),
            offset: _offset - 1,
          );
          continue;

        default:
          if (_isDigit(c)) {
            yield _parseNumber(c);
            continue;
          }

          if (!_isInitialIdentifierCodeUnit(c)) {
            throw FormatException(
              'Unexpected value in input $c',
              _input,
              _offset - 1,
            );
          }
          final startOffset = _offset - 1;
          while (_offset < _length) {
            if (!_isIdentifierCodeUnit(_input.codeUnitAt(_offset))) break;
            ++_offset;
          }
          final identifier = _input.substring(startOffset, _offset);

          const identifierToTokenContentMap = {
            'false': TokenData.boolValue(false),
            'true': TokenData.boolValue(true),
          };

          final tokenContent = identifierToTokenContentMap[identifier];
          if (tokenContent != null) {
            yield Token(data: tokenContent, offset: startOffset);
          } else {
            yield Token(
              data: TokenData.identifier(identifier),
              offset: startOffset,
            );
          }
          continue;
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
      if (c == closingCharacter) return buffer.toString();

      // '\'
      if (c != 0x5c) {
        buffer.writeCharCode(c);
        continue;
      }

      if (_offset >= _length) {
        throw const FormatException('Unexepected end of input');
      }

      final v = _input.codeUnitAt(_offset++);

      // Support all string escapes from dart language specification 2.10 §17.7
      // https://dart.dev/guides/language/specifications/DartLangSpec-v2.10.pdf
      switch (v) {
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

        case 0x75: // 'u'
          _parseHexCharCode(buffer, 2);
          continue;

        case 0x78: // 'x'
          _parseHexCharCode(buffer, 4);
          continue;

        default:
          // This will also take care of '$' and '\' and quotes.
          buffer.writeCharCode(v);
          continue;
      }
    }
  }

  void _parseHexCharCode(StringBuffer buffer, int defaultLength) {
    var c = _getC();
    var value = 0;
    if (c == 0x7b) {
      for (;;) {
        c = _getC();
        if (c == 0x7d) break;
        final hexValue = _hexValue(c);
        if (hexValue == -1) {
          throw FormatException(
            'Invalid hex character $c',
            _input,
            _offset - 1,
          );
        }
        value = 16 * value + hexValue;
      }
    } else {
      value = _hexValue(c);
      if (value == -1) {
        throw FormatException(
          'Invalid hex character $c',
          _input,
          _offset - 1,
        );
      }
      for (var i = 1; i < defaultLength; ++i) {
        c = _getC();
        final hexValue = _hexValue(c);
        if (hexValue == -1) {
          throw FormatException(
            'Invalid hex character $c',
            _input,
            _offset - 1,
          );
        }
        value = 16 * value + hexValue;
      }
    }

    buffer.writeCharCode(value);
  }

  Token _parseNumber(int firstCodeUnit) {
    final startOffset = _offset - 1;
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

      if (!_isDigit(c)) {
        throw FormatException('Invalid number', _input, startOffset);
      }

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
      return Token(data: TokenData.intValue(sign * value), offset: startOffset);
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

    return Token(data: TokenData.doubleValue(result), offset: startOffset);
  }

  int _getC() {
    if (_offset >= _length) return -1;

    return _input.codeUnitAt(_offset++);
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
