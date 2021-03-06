// ** WARNING **
// This file is autogenerated by Javelin Object Compiler (joc).
// Do not edit it directly.
//
// ignore_for_file: annotate_overrides
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: directives_ordering
// ignore_for_file: prefer_const_constructors_in_immutables
// ignore_for_file: sort_constructors_first
// ignore_for_file: unused_import
import 'package:javelin_object/jo_internal.dart';

import '../void.jo.dart';

@immutable
class Token {
  const Token({
    required this.data,
    required this.offset,
  });

  @visibleForTesting
  final TokenData data;
  TokenType get type =>
      data.type;
  bool get boolValue => data.boolValue;
  bool? get boolValueOrNull => data.boolValueOrNull;
  int get intValue => data.intValue;
  int? get intValueOrNull => data.intValueOrNull;
  double get doubleValue => data.doubleValue;
  double? get doubleValueOrNull => data.doubleValueOrNull;
  String get stringValue => data.stringValue;
  String? get stringValueOrNull => data.stringValueOrNull;
  String get identifier => data.identifier;
  String? get identifierOrNull => data.identifierOrNull;
  String get parameter => data.parameter;
  String? get parameterOrNull => data.parameterOrNull;
  Void get dot => data.dot;
  Void? get dotOrNull => data.dotOrNull;
  Void get minus => data.minus;
  Void? get minusOrNull => data.minusOrNull;
  Void get equals => data.equals;
  Void? get equalsOrNull => data.equalsOrNull;
  Void get notEquals => data.notEquals;
  Void? get notEqualsOrNull => data.notEqualsOrNull;
  Void get lessThan => data.lessThan;
  Void? get lessThanOrNull => data.lessThanOrNull;
  Void get lessThanOrEquals => data.lessThanOrEquals;
  Void? get lessThanOrEqualsOrNull => data.lessThanOrEqualsOrNull;
  Void get greaterThan => data.greaterThan;
  Void? get greaterThanOrNull => data.greaterThanOrNull;
  Void get greaterThanOrEquals => data.greaterThanOrEquals;
  Void? get greaterThanOrEqualsOrNull => data.greaterThanOrEqualsOrNull;
  Void get leftSquareBracket => data.leftSquareBracket;
  Void? get leftSquareBracketOrNull => data.leftSquareBracketOrNull;
  Void get rightSquareBracket => data.rightSquareBracket;
  Void? get rightSquareBracketOrNull => data.rightSquareBracketOrNull;
  Void get leftParenthesis => data.leftParenthesis;
  Void? get leftParenthesisOrNull => data.leftParenthesisOrNull;
  Void get rightParenthesis => data.rightParenthesis;
  Void? get rightParenthesisOrNull => data.rightParenthesisOrNull;
  Void get logicalAnd => data.logicalAnd;
  Void? get logicalAndOrNull => data.logicalAndOrNull;
  Void get logicalOr => data.logicalOr;
  Void? get logicalOrOrNull => data.logicalOrOrNull;
  Void get eof => data.eof;
  Void? get eofOrNull => data.eofOrNull;

  final int offset;

  Map<String, Object?> toMap() {
    final $data = data;
    final $offset = offset;

    return {
      'data': $data.toMap(),
      'offset': $offset,
    };
  }

  @override
  int get hashCode {
    var result = 0;
    result = joCombineHashCode(result, data.hashCode);
    result = joCombineHashCode(result, offset.hashCode);
    return joFinalizeHashCode(result);
  }

  @override
  bool operator==(Object other) =>
    other is Token
    && data == other.data
    && offset == other.offset;

  @override
  String toString({bool pretty = true}) =>
    toJoText(toMap(), pretty: pretty);
}

enum TokenType {
  boolValue,
  intValue,
  doubleValue,
  stringValue,
  identifier,
  parameter,
  dot,
  minus,
  equals,
  notEquals,
  lessThan,
  lessThanOrEquals,
  greaterThan,
  greaterThanOrEquals,
  leftSquareBracket,
  rightSquareBracket,
  leftParenthesis,
  rightParenthesis,
  logicalAnd,
  logicalOr,
  eof,
}

@immutable
class TokenData {
  const TokenData.boolValue(bool boolValue)
    : type = TokenType.boolValue,
      _value = boolValue;

  const TokenData.intValue(int intValue)
    : type = TokenType.intValue,
      _value = intValue;

  const TokenData.doubleValue(double doubleValue)
    : type = TokenType.doubleValue,
      _value = doubleValue;

  const TokenData.stringValue(String stringValue)
    : type = TokenType.stringValue,
      _value = stringValue;

  const TokenData.identifier(String identifier)
    : type = TokenType.identifier,
      _value = identifier;

  const TokenData.parameter(String parameter)
    : type = TokenType.parameter,
      _value = parameter;

  const TokenData.dot()
    : type = TokenType.dot,
      _value = const Void();

  const TokenData.minus()
    : type = TokenType.minus,
      _value = const Void();

  const TokenData.equals()
    : type = TokenType.equals,
      _value = const Void();

  const TokenData.notEquals()
    : type = TokenType.notEquals,
      _value = const Void();

  const TokenData.lessThan()
    : type = TokenType.lessThan,
      _value = const Void();

  const TokenData.lessThanOrEquals()
    : type = TokenType.lessThanOrEquals,
      _value = const Void();

  const TokenData.greaterThan()
    : type = TokenType.greaterThan,
      _value = const Void();

  const TokenData.greaterThanOrEquals()
    : type = TokenType.greaterThanOrEquals,
      _value = const Void();

  const TokenData.leftSquareBracket()
    : type = TokenType.leftSquareBracket,
      _value = const Void();

  const TokenData.rightSquareBracket()
    : type = TokenType.rightSquareBracket,
      _value = const Void();

  const TokenData.leftParenthesis()
    : type = TokenType.leftParenthesis,
      _value = const Void();

  const TokenData.rightParenthesis()
    : type = TokenType.rightParenthesis,
      _value = const Void();

  const TokenData.logicalAnd()
    : type = TokenType.logicalAnd,
      _value = const Void();

  const TokenData.logicalOr()
    : type = TokenType.logicalOr,
      _value = const Void();

  const TokenData.eof()
    : type = TokenType.eof,
      _value = const Void();

  final TokenType type;
  final Object _value;

  bool get boolValue => boolValueOrNull!;
  bool? get boolValueOrNull =>
    type == TokenType.boolValue
      ? _value as bool
      : null;

  int get intValue => intValueOrNull!;
  int? get intValueOrNull =>
    type == TokenType.intValue
      ? _value as int
      : null;

  double get doubleValue => doubleValueOrNull!;
  double? get doubleValueOrNull =>
    type == TokenType.doubleValue
      ? _value as double
      : null;

  String get stringValue => stringValueOrNull!;
  String? get stringValueOrNull =>
    type == TokenType.stringValue
      ? _value as String
      : null;

  String get identifier => identifierOrNull!;
  String? get identifierOrNull =>
    type == TokenType.identifier
      ? _value as String
      : null;

  String get parameter => parameterOrNull!;
  String? get parameterOrNull =>
    type == TokenType.parameter
      ? _value as String
      : null;

  Void get dot => dotOrNull!;
  Void? get dotOrNull =>
    type == TokenType.dot
      ? _value as Void
      : null;

  Void get minus => minusOrNull!;
  Void? get minusOrNull =>
    type == TokenType.minus
      ? _value as Void
      : null;

  Void get equals => equalsOrNull!;
  Void? get equalsOrNull =>
    type == TokenType.equals
      ? _value as Void
      : null;

  Void get notEquals => notEqualsOrNull!;
  Void? get notEqualsOrNull =>
    type == TokenType.notEquals
      ? _value as Void
      : null;

  Void get lessThan => lessThanOrNull!;
  Void? get lessThanOrNull =>
    type == TokenType.lessThan
      ? _value as Void
      : null;

  Void get lessThanOrEquals => lessThanOrEqualsOrNull!;
  Void? get lessThanOrEqualsOrNull =>
    type == TokenType.lessThanOrEquals
      ? _value as Void
      : null;

  Void get greaterThan => greaterThanOrNull!;
  Void? get greaterThanOrNull =>
    type == TokenType.greaterThan
      ? _value as Void
      : null;

  Void get greaterThanOrEquals => greaterThanOrEqualsOrNull!;
  Void? get greaterThanOrEqualsOrNull =>
    type == TokenType.greaterThanOrEquals
      ? _value as Void
      : null;

  Void get leftSquareBracket => leftSquareBracketOrNull!;
  Void? get leftSquareBracketOrNull =>
    type == TokenType.leftSquareBracket
      ? _value as Void
      : null;

  Void get rightSquareBracket => rightSquareBracketOrNull!;
  Void? get rightSquareBracketOrNull =>
    type == TokenType.rightSquareBracket
      ? _value as Void
      : null;

  Void get leftParenthesis => leftParenthesisOrNull!;
  Void? get leftParenthesisOrNull =>
    type == TokenType.leftParenthesis
      ? _value as Void
      : null;

  Void get rightParenthesis => rightParenthesisOrNull!;
  Void? get rightParenthesisOrNull =>
    type == TokenType.rightParenthesis
      ? _value as Void
      : null;

  Void get logicalAnd => logicalAndOrNull!;
  Void? get logicalAndOrNull =>
    type == TokenType.logicalAnd
      ? _value as Void
      : null;

  Void get logicalOr => logicalOrOrNull!;
  Void? get logicalOrOrNull =>
    type == TokenType.logicalOr
      ? _value as Void
      : null;

  Void get eof => eofOrNull!;
  Void? get eofOrNull =>
    type == TokenType.eof
      ? _value as Void
      : null;

  Map<String, Object?> toMap() {
    switch (type) {
      case TokenType.boolValue:
        final $boolValue = _value as bool;
        return { 'boolValue': $boolValue };
      case TokenType.intValue:
        final $intValue = _value as int;
        return { 'intValue': $intValue };
      case TokenType.doubleValue:
        final $doubleValue = _value as double;
        return { 'doubleValue': $doubleValue };
      case TokenType.stringValue:
        final $stringValue = _value as String;
        return { 'stringValue': $stringValue };
      case TokenType.identifier:
        final $identifier = _value as String;
        return { 'identifier': $identifier };
      case TokenType.parameter:
        final $parameter = _value as String;
        return { 'parameter': $parameter };
      case TokenType.dot:
        final $dot = _value as Void;
        return { 'dot': $dot.toMap() };
      case TokenType.minus:
        final $minus = _value as Void;
        return { 'minus': $minus.toMap() };
      case TokenType.equals:
        final $equals = _value as Void;
        return { 'equals': $equals.toMap() };
      case TokenType.notEquals:
        final $notEquals = _value as Void;
        return { 'notEquals': $notEquals.toMap() };
      case TokenType.lessThan:
        final $lessThan = _value as Void;
        return { 'lessThan': $lessThan.toMap() };
      case TokenType.lessThanOrEquals:
        final $lessThanOrEquals = _value as Void;
        return { 'lessThanOrEquals': $lessThanOrEquals.toMap() };
      case TokenType.greaterThan:
        final $greaterThan = _value as Void;
        return { 'greaterThan': $greaterThan.toMap() };
      case TokenType.greaterThanOrEquals:
        final $greaterThanOrEquals = _value as Void;
        return { 'greaterThanOrEquals': $greaterThanOrEquals.toMap() };
      case TokenType.leftSquareBracket:
        final $leftSquareBracket = _value as Void;
        return { 'leftSquareBracket': $leftSquareBracket.toMap() };
      case TokenType.rightSquareBracket:
        final $rightSquareBracket = _value as Void;
        return { 'rightSquareBracket': $rightSquareBracket.toMap() };
      case TokenType.leftParenthesis:
        final $leftParenthesis = _value as Void;
        return { 'leftParenthesis': $leftParenthesis.toMap() };
      case TokenType.rightParenthesis:
        final $rightParenthesis = _value as Void;
        return { 'rightParenthesis': $rightParenthesis.toMap() };
      case TokenType.logicalAnd:
        final $logicalAnd = _value as Void;
        return { 'logicalAnd': $logicalAnd.toMap() };
      case TokenType.logicalOr:
        final $logicalOr = _value as Void;
        return { 'logicalOr': $logicalOr.toMap() };
      case TokenType.eof:
        final $eof = _value as Void;
        return { 'eof': $eof.toMap() };
    }
  }
  @override
  int get hashCode => joFinalizeHashCode(
    joCombineHashCode(type.hashCode, _value.hashCode),
  );

  @override
  bool operator==(Object other) {
    if (other is! TokenData) return false;
    return type == other.type
      && _value == other._value;
  }

  @override
  String toString({bool pretty = true}) =>
    toJoText(toMap(), pretty: pretty);
}

void joRegister() {}
