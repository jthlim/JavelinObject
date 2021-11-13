import 'text_parser/token.dart';
import 'text_parser/tokenizer.dart';

String toJoText(Object? o, {bool pretty = true}) {
  final buffer = StringBuffer();

  _addObject(buffer, o, '', pretty);

  return buffer.toString();
}

dynamic fromJoText(String s) {
  final tokenizer = Tokenizer(s).tokenize();
  return _parseJoText(tokenizer.iterator..moveNext());
}

Object? _parseJoText(Iterator<Token> tokens) {
  final token = tokens.current;
  switch (token.type) {
    case TokenType.value:
      final value = (token as ValueToken).value;
      _nextToken(tokens);
      return value;

    case TokenType.leftCurlyBrace:
      _nextToken(tokens);
      final map = <Object?, Object?>{};
      while (tokens.current.type != TokenType.rightCurlyBrace) {
        final key = _parseJoText(tokens);
        _assertToken(tokens, TokenType.colon);
        final value = _parseJoText(tokens);
        if (tokens.current.type == TokenType.comma) _nextToken(tokens);
        map[key] = value;
      }
      _nextToken(tokens);
      return map;

    case TokenType.leftAngleBracket:
      _nextToken(tokens);
      final result = <Object?>{};
      while (tokens.current.type != TokenType.rightAngleBracket) {
        result.add(_parseJoText(tokens));
        if (tokens.current.type == TokenType.comma) _nextToken(tokens);
      }
      _nextToken(tokens);
      return result;

    case TokenType.leftSquareBracket:
      _nextToken(tokens);
      final result = <Object?>[];
      while (tokens.current.type != TokenType.rightSquareBracket) {
        result.add(_parseJoText(tokens));
        if (tokens.current.type == TokenType.comma) _nextToken(tokens);
      }
      _nextToken(tokens);
      return result;

    default:
      throw FormatException('Unexpected token $token');
  }
}

void _assertToken(Iterator<Token> tokens, TokenType type) {
  if (tokens.current.type != type) {
    throw FormatException('Expected $type, found ${tokens.current} instead');
  }
  _nextToken(tokens);
}

void _nextToken(Iterator<Token> tokens) {
  tokens.moveNext();
}

void _addObject(StringBuffer buffer, Object? o, String indent, bool pretty) {
  if (o == null) {
    buffer.write('null');
  } else if (o is Map) {
    if (o.isEmpty) {
      buffer.write('{}');
      return;
    }

    final originalIndent = indent;
    if (pretty) indent = indent + '  ';

    buffer.write('{');
    var isFirstTime = true;
    o.forEach((key, value) {
      if (isFirstTime) {
        isFirstTime = false;
      } else {
        buffer.write(',');
      }
      if (pretty) buffer.write('\n$indent');
      _addObject(buffer, key, indent, pretty);
      buffer.write(pretty ? ': ' : ':');
      _addObject(buffer, value, indent, pretty);
    });
    if (pretty) {
      buffer.write(',\n$originalIndent}');
    } else {
      buffer.write('}');
    }
  } else if (o is List) {
    if (o.isEmpty) {
      buffer.write('[]');
      return;
    }

    final originalIndent = indent;
    if (pretty) indent = indent + '  ';

    buffer.write('[');
    var isFirstTime = true;
    for (final value in o) {
      if (isFirstTime) {
        isFirstTime = false;
      } else {
        buffer.write(',');
      }
      if (pretty) buffer.write('\n$indent');
      _addObject(buffer, value, indent, pretty);
    }
    if (pretty) {
      buffer.write(',\n$originalIndent]');
    } else {
      buffer.write(']');
    }
  } else if (o is Set) {
    if (o.isEmpty) {
      buffer.write('<>');
      return;
    }

    final originalIndent = indent;
    if (pretty) indent = indent + '  ';

    buffer.write('<');
    var isFirstTime = true;
    for (final value in o) {
      if (isFirstTime) {
        isFirstTime = false;
      } else {
        buffer.write(',');
      }
      if (pretty) buffer.write('\n$indent');
      _addObject(buffer, value, indent, pretty);
    }
    if (pretty) {
      buffer.write(',\n$originalIndent>');
    } else {
      buffer.write('>');
    }
  } else if (o is String) {
    _writeEscapedString(buffer, o);
  } else if (o is double || o is int || o is bool) {
    buffer.write(o.toString());
  } else {
    throw ArgumentError('Unhandled type in toText(): ${o.runtimeType}');
  }
}

void _writeEscapedString(StringBuffer buffer, String s) {
  buffer.write('\'');

  final length = s.length;
  for (var i = 0; i < length; ++i) {
    final c = s.codeUnitAt(i);
    switch (c) {
      case 0x08:
        buffer.write(r'\b');
        break;
      case 0x09:
        buffer.write(r'\t');
        break;
      case 0x0a:
        buffer.write(r'\n');
        break;
      case 0x0b:
        buffer.write(r'\v');
        break;
      case 0x0c:
        buffer.write(r'\f');
        break;
      case 0x0d:
        buffer.write(r'\r');
        break;
      case 0x27: // Single quote
      case 0x5c: // Backslash
        buffer.writeCharCode(0x5c); // Backslash
        buffer.writeCharCode(c);
        break;
      default:
        buffer.writeCharCode(c);
        break;
    }
  }
  buffer.write('\'');
}
