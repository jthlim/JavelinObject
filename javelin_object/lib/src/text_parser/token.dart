import 'package:meta/meta.dart';

enum TokenType {
  value,
  identifier,
  colon,
  comma,
  leftAngleBracket,
  rightAngleBracket,
  leftSquareBracket,
  rightSquareBracket,
  leftCurlyBrace,
  rightCurlyBrace,
  eof,
}

@immutable
class Token {
  const Token(this.type, {this.line, this.column});

  final TokenType type;

  /// The line number that the token occurs at.
  final int? line;
  final int? column;

  @override
  bool operator ==(Object other) {
    if (other is! Token) return false;
    if (type != other.type) return false;
    if (line != null && other.line != null && line != other.line) return false;
    if (column != null && other.column != null && column != other.column) {
      return false;
    }
    return true;
  }

  @override
  String toString() => '$type$lineSuffix';

  String get lineSuffix {
    if (line != null && column != -1) return ' (L$line:$column)';
    return '';
  }
}

class ValueToken extends Token {
  const ValueToken(this.value, {int? line, int? column})
      : super(TokenType.value, line: line, column: column);

  final Object? value;

  @override
  String toString() => 'Value: $value$lineSuffix';
}
