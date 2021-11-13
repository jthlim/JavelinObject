import 'dart:math';

import 'token.dart';

class Tokenizer {
  Tokenizer(String input, String filename)
      : _input = input,
        _length = input.length,
        _filename = filename;

  final String _input;
  final int _length;
  final String _filename;

  var _offset = 0;
  var _line = 1;
  var _column = 0;

  var _documentationComments = <String>[];

  String get locator => '($_filename:$_line:$_column)';

  List<String>? fetchAndResetDocumentationComments() {
    final result = _documentationComments;
    _documentationComments = [];
    return result.isEmpty ? null : result;
  }

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
          yield Token(
            data: TokenData.stringValue(
              _parseString(closingCharacter: c),
            ),
            line: _line,
            column: _column,
          );
          continue;

        case 0x28: // '('
          yield Token(
            data: const TokenData.leftParenthesis(),
            line: _line,
            column: _column,
          );
          continue;

        case 0x29: // ')'
          yield Token(
            data: const TokenData.rightParenthesis(),
            line: _line,
            column: _column,
          );
          continue;

        case 0x2c: // ','
          yield Token(
            data: const TokenData.comma(),
            line: _line,
            column: _column,
          );
          continue;

        case 0x2e: // '.'
          if (_offset < _length && _isDigit(_input.codeUnitAt(_offset))) {
            yield _parseNumber(c);
          } else {
            yield Token(
              data: const TokenData.dot(),
              line: _line,
              column: _column,
            );
          }
          continue;

        case 0x2d: // '-'
          yield _parseNumber(c);
          continue;

        case 0x2f: // '/'
          if (_offset >= _length) {
            throw FormatException('Unexpected end of input $locator');
          }
          _column++;
          switch (_input.codeUnitAt(_offset++)) {
            case 0x2a: // '/*' -- skip to first '*/'
              var hasAsterisk = false;
              while (true) {
                if (_offset >= _length) {
                  throw FormatException('Unexpected end of input $locator');
                }

                final c = _input.codeUnitAt(_offset++);
                _column++;
                if (c == 0x2f && hasAsterisk) break;

                hasAsterisk = c == 0x2a;
              }
              break;

            case 0x2f: // '//' -- skip to end of line.
              if (_offset >= _length) break;

              int? docStartOffset;
              if (_input.codeUnitAt(_offset) == 0x2f) {
                // Triple slash -- doc comment.
                ++_offset;
                docStartOffset = _offset;
              }
              while (_offset < _length) {
                final c = _input.codeUnitAt(_offset);
                ++_offset;
                if (c == 0x0a) break;
              }
              if (docStartOffset != null) {
                _documentationComments
                    .add(_input.substring(docStartOffset, _offset));
              }
              _column = 0;
              ++_line;
              break;

            default:
              throw FormatException('Unexpected input after \'/\' $locator');
          }
          continue;

        case 0x3a: // ':'
          yield Token(
            data: const TokenData.colon(),
            line: _line,
            column: _column,
          );
          continue;

        case 0x3b: // ';'
          yield Token(
            data: const TokenData.semicolon(),
            line: _line,
            column: _column,
          );
          continue;

        case 0x3c: // '<'
          yield Token(
              data: const TokenData.leftAngleBracket(),
              line: _line,
              column: _column);
          continue;

        case 0x3d: // '='
          yield Token(
            data: const TokenData.equals(),
            line: _line,
            column: _column,
          );
          continue;

        case 0x3e: // '>'
          yield Token(
            data: const TokenData.rightAngleBracket(),
            line: _line,
            column: _column,
          );
          continue;

        case 0x3f: // '?'
          yield Token(
            data: const TokenData.questionMark(),
            line: _line,
            column: _column,
          );
          continue;

        case 0x40: // '@'
          yield Token(
            data: const TokenData.at(),
            line: _line,
            column: _column,
          );
          continue;

        case 0x5b: // '['
          yield Token(
            data: const TokenData.leftSquareBracket(),
            line: _line,
            column: _column,
          );
          continue;

        case 0x5d: // ']'
          yield Token(
            data: const TokenData.rightSquareBracket(),
            line: _line,
            column: _column,
          );
          continue;

        case 0x7b: // '{'
          yield Token(
            data: const TokenData.leftCurlyBrace(),
            line: _line,
            column: _column,
          );
          continue;

        case 0x7d: // '}'
          yield Token(
            data: const TokenData.rightCurlyBrace(),
            line: _line,
            column: _column,
          );
          continue;

        default:
          if (_isDigit(c)) {
            yield _parseNumber(c);
            continue;
          }

          if (!_isInitialIdentifierCodeUnit(c)) {
            throw FormatException(
              'Unexpected value in input \'${String.fromCharCode(c)}\' '
              '$locator',
            );
          }
          final startOffset = _offset - 1;
          final startLine = _line;
          final startColumn = _column;
          while (_offset < _length) {
            if (!_isIdentifierCodeUnit(_input.codeUnitAt(_offset))) break;
            ++_offset;
            ++_column;
          }
          final identifier = _input.substring(startOffset, _offset);

          const identifierToTokenContentMap = {
            'class': TokenData.classKeyword(),
            'default': TokenData.defaultKeyword(),
            'enum': TokenData.enumKeyword(),
            'extends': TokenData.extendsKeyword(),
            'false': TokenData.boolValue(false),
            'true': TokenData.boolValue(true),
            'union': TokenData.unionKeyword(),
          };

          final tokenContent = identifierToTokenContentMap[identifier];
          if (tokenContent != null) {
            yield Token(
              data: tokenContent,
              line: startLine,
              column: startColumn,
            );
          } else {
            yield Token(
              data: TokenData.identifier(identifier),
              line: startLine,
              column: startColumn,
            );
          }
      }
    }
  }

  String _parseString({required int closingCharacter}) {
    final buffer = StringBuffer();
    while (true) {
      if (_offset >= _length) {
        throw FormatException('Unmatched quote in file $locator');
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
        throw FormatException('Unexepected end of input $locator');
      }

      final v = _input.codeUnitAt(_offset++);
      _column++;

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
            'Invalid hex character \'${String.fromCharCode(c)}\' $locator',
          );
        }
        value = 16 * value + hexValue;
      }
    } else {
      value = _hexValue(c);
      if (value == -1) {
        throw FormatException(
          'Invalid hex character \'${String.fromCharCode(c)}\' $locator',
        );
      }
      for (var i = 1; i < defaultLength; ++i) {
        c = _getC();
        final hexValue = _hexValue(c);
        if (hexValue == -1) {
          throw FormatException(
            'Invalid hex character \'${String.fromCharCode(c)}\' $locator',
          );
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
    var hasProcessedDigits = false;
    if (_isDigit(c)) {
      hasIntegerPortion = true;
      value = c - 0x30;
      while (true) {
        c = _getC();
        if (!_isDigit(c)) break;

        value = 10 * value + (c - 0x30);
        hasProcessedDigits = true;
      }
    }

    if (value == 0 && !hasProcessedDigits && (c == 0x58 || c == 0x78)) {
      // '0x' format.
      for (;;) {
        c = _getC();
        final hexValue = _hexValue(c);
        if (hexValue == -1) {
          --_offset;
          return Token(
            data: TokenData.intValue(sign * value),
            line: line,
            column: column,
          );
        }
        value = value * 16 + hexValue;
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
        throw FormatException(
          'Invalid number ${String.fromCharCode(c)} $locator',
        );
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
      return Token(
        data: TokenData.intValue(sign * value),
        line: line,
        column: column,
      );
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

    return Token(
      data: TokenData.doubleValue(result),
      line: line,
      column: column,
    );
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
