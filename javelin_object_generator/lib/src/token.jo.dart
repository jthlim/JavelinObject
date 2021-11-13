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

import 'void.jo.dart';

@immutable
class Token {
  const Token({
    required this.data,
    required this.line,
    required this.column,
  });

  factory Token.fromString(String s) => Token.fromMap(fromJoText(s));

  factory Token.fromBytes(Uint8List bytes) => Token.fromJoFieldMap0(parseJoBinary(bytes));

  Token.fromJoFieldMap0(Map<int, JoFieldData> map)
    : data = _dataFromJoFieldMap(map),
      line = _lineFromJoFieldMap(map),
      column = _columnFromJoFieldMap(map);

  Token.fromMap(Map<Object?, Object?> map)
    : data = _dataFromMap(map),
      line = _lineFromMap(map),
      column = _columnFromMap(map);

  @visibleForTesting
  final TokenData data;
  TokenType get type =>
      data.type;
  Void get classKeyword => data.classKeyword;
  Void? get classKeywordOrNull => data.classKeywordOrNull;
  Void get unionKeyword => data.unionKeyword;
  Void? get unionKeywordOrNull => data.unionKeywordOrNull;
  Void get enumKeyword => data.enumKeyword;
  Void? get enumKeywordOrNull => data.enumKeywordOrNull;
  Void get extendsKeyword => data.extendsKeyword;
  Void? get extendsKeywordOrNull => data.extendsKeywordOrNull;
  Void get defaultKeyword => data.defaultKeyword;
  Void? get defaultKeywordOrNull => data.defaultKeywordOrNull;
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
  Void get colon => data.colon;
  Void? get colonOrNull => data.colonOrNull;
  Void get semicolon => data.semicolon;
  Void? get semicolonOrNull => data.semicolonOrNull;
  Void get comma => data.comma;
  Void? get commaOrNull => data.commaOrNull;
  Void get equals => data.equals;
  Void? get equalsOrNull => data.equalsOrNull;
  Void get at => data.at;
  Void? get atOrNull => data.atOrNull;
  Void get dot => data.dot;
  Void? get dotOrNull => data.dotOrNull;
  Void get questionMark => data.questionMark;
  Void? get questionMarkOrNull => data.questionMarkOrNull;
  Void get leftAngleBracket => data.leftAngleBracket;
  Void? get leftAngleBracketOrNull => data.leftAngleBracketOrNull;
  Void get rightAngleBracket => data.rightAngleBracket;
  Void? get rightAngleBracketOrNull => data.rightAngleBracketOrNull;
  Void get leftSquareBracket => data.leftSquareBracket;
  Void? get leftSquareBracketOrNull => data.leftSquareBracketOrNull;
  Void get rightSquareBracket => data.rightSquareBracket;
  Void? get rightSquareBracketOrNull => data.rightSquareBracketOrNull;
  Void get leftCurlyBrace => data.leftCurlyBrace;
  Void? get leftCurlyBraceOrNull => data.leftCurlyBraceOrNull;
  Void get rightCurlyBrace => data.rightCurlyBrace;
  Void? get rightCurlyBraceOrNull => data.rightCurlyBraceOrNull;
  Void get leftParenthesis => data.leftParenthesis;
  Void? get leftParenthesisOrNull => data.leftParenthesisOrNull;
  Void get rightParenthesis => data.rightParenthesis;
  Void? get rightParenthesisOrNull => data.rightParenthesisOrNull;
  Void get eof => data.eof;
  Void? get eofOrNull => data.eofOrNull;

  final int line;
  final int column;

  Uint8List toBytes() => encodeBytes().toBytes();

  JoBinaryEncoder encodeBytes([JoBinaryEncoder? $derivedEncoder]) {
    final encoder = JoBinaryEncoder();
    final $dataEncoder = JoBinaryEncoder();
    data.encodeBytes($dataEncoder);
    encoder.writeObject(0, $dataEncoder);
    encoder.writeUint(1, line);
    encoder.writeUint(2, column);
    return encoder;
  }

  Map<String, Object?> toMap() {
    final $data = data;
    final $line = line;
    final $column = column;

    return {
      'data': $data.toMap(),
      'line': $line,
      'column': $column,
    };
  }

  @override
  int get hashCode {
    var result = 0;
    result = joCombineHashCode(result, data.hashCode);
    result = joCombineHashCode(result, line.hashCode);
    result = joCombineHashCode(result, column.hashCode);
    return joFinalizeHashCode(result);
  }

  @override
  bool operator==(Object other) =>
    other is Token
    && data == other.data
    && line == other.line
    && column == other.column;

  @override
  String toString({bool pretty = true}) =>
    toJoText(toMap(), pretty: pretty);

  static TokenData _dataFromJoFieldMap(Map<int, JoFieldData> map) {
    final $data = map.bytesValue(0);
    return TokenData.fromBytes($data!);
  }
  static int _lineFromJoFieldMap(Map<int, JoFieldData> map) =>
    map.uintValue(1)!;
  static int _columnFromJoFieldMap(Map<int, JoFieldData> map) =>
    map.uintValue(2)!;

  static TokenData _dataFromMap(Map<Object?, Object?> map) {
    final lookup = map.joLookupValue<Map>(fieldName: 'data');
    return TokenData.fromMapOrNull(lookup)!;
  }
  static int _lineFromMap(Map<Object?, Object?> map) =>
    map.joLookupValue<int>(fieldName: 'line');
  static int _columnFromMap(Map<Object?, Object?> map) =>
    map.joLookupValue<int>(fieldName: 'column');
}

enum TokenType {
  classKeyword,
  unionKeyword,
  enumKeyword,
  extendsKeyword,
  defaultKeyword,
  boolValue,
  intValue,
  doubleValue,
  stringValue,
  identifier,
  colon,
  semicolon,
  comma,
  equals,
  at,
  dot,
  questionMark,
  leftAngleBracket,
  rightAngleBracket,
  leftSquareBracket,
  rightSquareBracket,
  leftCurlyBrace,
  rightCurlyBrace,
  leftParenthesis,
  rightParenthesis,
  eof,
}

@immutable
class TokenData {
  const TokenData.classKeyword()
    : type = TokenType.classKeyword,
      _value = const Void();

  const TokenData.unionKeyword()
    : type = TokenType.unionKeyword,
      _value = const Void();

  const TokenData.enumKeyword()
    : type = TokenType.enumKeyword,
      _value = const Void();

  const TokenData.extendsKeyword()
    : type = TokenType.extendsKeyword,
      _value = const Void();

  const TokenData.defaultKeyword()
    : type = TokenType.defaultKeyword,
      _value = const Void();

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

  const TokenData.colon()
    : type = TokenType.colon,
      _value = const Void();

  const TokenData.semicolon()
    : type = TokenType.semicolon,
      _value = const Void();

  const TokenData.comma()
    : type = TokenType.comma,
      _value = const Void();

  const TokenData.equals()
    : type = TokenType.equals,
      _value = const Void();

  const TokenData.at()
    : type = TokenType.at,
      _value = const Void();

  const TokenData.dot()
    : type = TokenType.dot,
      _value = const Void();

  const TokenData.questionMark()
    : type = TokenType.questionMark,
      _value = const Void();

  const TokenData.leftAngleBracket()
    : type = TokenType.leftAngleBracket,
      _value = const Void();

  const TokenData.rightAngleBracket()
    : type = TokenType.rightAngleBracket,
      _value = const Void();

  const TokenData.leftSquareBracket()
    : type = TokenType.leftSquareBracket,
      _value = const Void();

  const TokenData.rightSquareBracket()
    : type = TokenType.rightSquareBracket,
      _value = const Void();

  const TokenData.leftCurlyBrace()
    : type = TokenType.leftCurlyBrace,
      _value = const Void();

  const TokenData.rightCurlyBrace()
    : type = TokenType.rightCurlyBrace,
      _value = const Void();

  const TokenData.leftParenthesis()
    : type = TokenType.leftParenthesis,
      _value = const Void();

  const TokenData.rightParenthesis()
    : type = TokenType.rightParenthesis,
      _value = const Void();

  const TokenData.eof()
    : type = TokenType.eof,
      _value = const Void();

  static TokenData? fromMapOrNull(Map<Object?, Object?> map) {
    final entries = map.entries;
    if (entries.length != 1) return null;
    final entry = entries.first;
    switch (entry.key) {
      case 'classKeyword':
        return _classKeywordFromValue(entry.value);
      case 'unionKeyword':
        return _unionKeywordFromValue(entry.value);
      case 'enumKeyword':
        return _enumKeywordFromValue(entry.value);
      case 'extendsKeyword':
        return _extendsKeywordFromValue(entry.value);
      case 'defaultKeyword':
        return _defaultKeywordFromValue(entry.value);
      case 'boolValue':
        return _boolValueFromValue(entry.value);
      case 'intValue':
        return _intValueFromValue(entry.value);
      case 'doubleValue':
        return _doubleValueFromValue(entry.value);
      case 'stringValue':
        return _stringValueFromValue(entry.value);
      case 'identifier':
        return _identifierFromValue(entry.value);
      case 'colon':
        return _colonFromValue(entry.value);
      case 'semicolon':
        return _semicolonFromValue(entry.value);
      case 'comma':
        return _commaFromValue(entry.value);
      case 'equals':
        return _equalsFromValue(entry.value);
      case 'at':
        return _atFromValue(entry.value);
      case 'dot':
        return _dotFromValue(entry.value);
      case 'questionMark':
        return _questionMarkFromValue(entry.value);
      case 'leftAngleBracket':
        return _leftAngleBracketFromValue(entry.value);
      case 'rightAngleBracket':
        return _rightAngleBracketFromValue(entry.value);
      case 'leftSquareBracket':
        return _leftSquareBracketFromValue(entry.value);
      case 'rightSquareBracket':
        return _rightSquareBracketFromValue(entry.value);
      case 'leftCurlyBrace':
        return _leftCurlyBraceFromValue(entry.value);
      case 'rightCurlyBrace':
        return _rightCurlyBraceFromValue(entry.value);
      case 'leftParenthesis':
        return _leftParenthesisFromValue(entry.value);
      case 'rightParenthesis':
        return _rightParenthesisFromValue(entry.value);
      case 'eof':
        return _eofFromValue(entry.value);
      default:
        return null;
    }
  }

  factory TokenData.fromBytes(Uint8List bytes) =>
    TokenData.fromJoFieldMapOrNull(parseJoBinary(bytes))!;

  static TokenData? fromJoFieldMapOrNull(Map<int, JoFieldData> map) {
    final entries = map.entries;
    if (entries.length != 1) return null;
    final entry = entries.first;
    switch (entry.key) {
      case 0:
        return _classKeywordFromJoField();
      case 1:
        return _unionKeywordFromJoField();
      case 2:
        return _enumKeywordFromJoField();
      case 3:
        return _extendsKeywordFromJoField();
      case 4:
        return _defaultKeywordFromJoField();
      case 5:
        return _boolValueFromJoField(entry.value);
      case 6:
        return _intValueFromJoField(entry.value);
      case 7:
        return _doubleValueFromJoField(entry.value);
      case 8:
        return _stringValueFromJoField(entry.value);
      case 9:
        return _identifierFromJoField(entry.value);
      case 10:
        return _colonFromJoField();
      case 11:
        return _semicolonFromJoField();
      case 12:
        return _commaFromJoField();
      case 13:
        return _equalsFromJoField();
      case 14:
        return _atFromJoField();
      case 15:
        return _dotFromJoField();
      case 16:
        return _questionMarkFromJoField();
      case 17:
        return _leftAngleBracketFromJoField();
      case 18:
        return _rightAngleBracketFromJoField();
      case 19:
        return _leftSquareBracketFromJoField();
      case 20:
        return _rightSquareBracketFromJoField();
      case 21:
        return _leftCurlyBraceFromJoField();
      case 22:
        return _rightCurlyBraceFromJoField();
      case 23:
        return _leftParenthesisFromJoField();
      case 24:
        return _rightParenthesisFromJoField();
      case 25:
        return _eofFromJoField();
      default:
        return null;
    }
  }

  factory TokenData.fromString(String s) =>
    TokenData.fromMapOrNull(fromJoText(s))!;

  final TokenType type;
  final Object _value;

  Void get classKeyword => classKeywordOrNull!;
  Void? get classKeywordOrNull =>
    type == TokenType.classKeyword
      ? _value as Void
      : null;

  Void get unionKeyword => unionKeywordOrNull!;
  Void? get unionKeywordOrNull =>
    type == TokenType.unionKeyword
      ? _value as Void
      : null;

  Void get enumKeyword => enumKeywordOrNull!;
  Void? get enumKeywordOrNull =>
    type == TokenType.enumKeyword
      ? _value as Void
      : null;

  Void get extendsKeyword => extendsKeywordOrNull!;
  Void? get extendsKeywordOrNull =>
    type == TokenType.extendsKeyword
      ? _value as Void
      : null;

  Void get defaultKeyword => defaultKeywordOrNull!;
  Void? get defaultKeywordOrNull =>
    type == TokenType.defaultKeyword
      ? _value as Void
      : null;

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

  Void get colon => colonOrNull!;
  Void? get colonOrNull =>
    type == TokenType.colon
      ? _value as Void
      : null;

  Void get semicolon => semicolonOrNull!;
  Void? get semicolonOrNull =>
    type == TokenType.semicolon
      ? _value as Void
      : null;

  Void get comma => commaOrNull!;
  Void? get commaOrNull =>
    type == TokenType.comma
      ? _value as Void
      : null;

  Void get equals => equalsOrNull!;
  Void? get equalsOrNull =>
    type == TokenType.equals
      ? _value as Void
      : null;

  Void get at => atOrNull!;
  Void? get atOrNull =>
    type == TokenType.at
      ? _value as Void
      : null;

  Void get dot => dotOrNull!;
  Void? get dotOrNull =>
    type == TokenType.dot
      ? _value as Void
      : null;

  Void get questionMark => questionMarkOrNull!;
  Void? get questionMarkOrNull =>
    type == TokenType.questionMark
      ? _value as Void
      : null;

  Void get leftAngleBracket => leftAngleBracketOrNull!;
  Void? get leftAngleBracketOrNull =>
    type == TokenType.leftAngleBracket
      ? _value as Void
      : null;

  Void get rightAngleBracket => rightAngleBracketOrNull!;
  Void? get rightAngleBracketOrNull =>
    type == TokenType.rightAngleBracket
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

  Void get leftCurlyBrace => leftCurlyBraceOrNull!;
  Void? get leftCurlyBraceOrNull =>
    type == TokenType.leftCurlyBrace
      ? _value as Void
      : null;

  Void get rightCurlyBrace => rightCurlyBraceOrNull!;
  Void? get rightCurlyBraceOrNull =>
    type == TokenType.rightCurlyBrace
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

  Void get eof => eofOrNull!;
  Void? get eofOrNull =>
    type == TokenType.eof
      ? _value as Void
      : null;

  Uint8List toBytes() {
    final encoder = JoBinaryEncoder();
    encodeBytes(encoder);
    return encoder.toBytes();
  }

  void encodeBytes(JoBinaryEncoder encoder) {
    switch (type) {
     case TokenType.classKeyword:
       encoder.writeObject(0, classKeyword.encodeBytes());
       break;
     case TokenType.unionKeyword:
       encoder.writeObject(1, unionKeyword.encodeBytes());
       break;
     case TokenType.enumKeyword:
       encoder.writeObject(2, enumKeyword.encodeBytes());
       break;
     case TokenType.extendsKeyword:
       encoder.writeObject(3, extendsKeyword.encodeBytes());
       break;
     case TokenType.defaultKeyword:
       encoder.writeObject(4, defaultKeyword.encodeBytes());
       break;
     case TokenType.boolValue:
       encoder.writeBool(5, boolValue);
       break;
     case TokenType.intValue:
       encoder.writeInt(6, intValue);
       break;
     case TokenType.doubleValue:
       encoder.writeDouble(7, doubleValue);
       break;
     case TokenType.stringValue:
       encoder.writeString(8, stringValue);
       break;
     case TokenType.identifier:
       encoder.writeString(9, identifier);
       break;
     case TokenType.colon:
       encoder.writeObject(10, colon.encodeBytes());
       break;
     case TokenType.semicolon:
       encoder.writeObject(11, semicolon.encodeBytes());
       break;
     case TokenType.comma:
       encoder.writeObject(12, comma.encodeBytes());
       break;
     case TokenType.equals:
       encoder.writeObject(13, equals.encodeBytes());
       break;
     case TokenType.at:
       encoder.writeObject(14, at.encodeBytes());
       break;
     case TokenType.dot:
       encoder.writeObject(15, dot.encodeBytes());
       break;
     case TokenType.questionMark:
       encoder.writeObject(16, questionMark.encodeBytes());
       break;
     case TokenType.leftAngleBracket:
       encoder.writeObject(17, leftAngleBracket.encodeBytes());
       break;
     case TokenType.rightAngleBracket:
       encoder.writeObject(18, rightAngleBracket.encodeBytes());
       break;
     case TokenType.leftSquareBracket:
       encoder.writeObject(19, leftSquareBracket.encodeBytes());
       break;
     case TokenType.rightSquareBracket:
       encoder.writeObject(20, rightSquareBracket.encodeBytes());
       break;
     case TokenType.leftCurlyBrace:
       encoder.writeObject(21, leftCurlyBrace.encodeBytes());
       break;
     case TokenType.rightCurlyBrace:
       encoder.writeObject(22, rightCurlyBrace.encodeBytes());
       break;
     case TokenType.leftParenthesis:
       encoder.writeObject(23, leftParenthesis.encodeBytes());
       break;
     case TokenType.rightParenthesis:
       encoder.writeObject(24, rightParenthesis.encodeBytes());
       break;
     case TokenType.eof:
       encoder.writeObject(25, eof.encodeBytes());
       break;
    }
  }

  Map<String, Object?> toMap() {
    switch (type) {
      case TokenType.classKeyword:
        final $classKeyword = _value as Void;
        return { 'classKeyword': $classKeyword.toMap() };
      case TokenType.unionKeyword:
        final $unionKeyword = _value as Void;
        return { 'unionKeyword': $unionKeyword.toMap() };
      case TokenType.enumKeyword:
        final $enumKeyword = _value as Void;
        return { 'enumKeyword': $enumKeyword.toMap() };
      case TokenType.extendsKeyword:
        final $extendsKeyword = _value as Void;
        return { 'extendsKeyword': $extendsKeyword.toMap() };
      case TokenType.defaultKeyword:
        final $defaultKeyword = _value as Void;
        return { 'defaultKeyword': $defaultKeyword.toMap() };
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
      case TokenType.colon:
        final $colon = _value as Void;
        return { 'colon': $colon.toMap() };
      case TokenType.semicolon:
        final $semicolon = _value as Void;
        return { 'semicolon': $semicolon.toMap() };
      case TokenType.comma:
        final $comma = _value as Void;
        return { 'comma': $comma.toMap() };
      case TokenType.equals:
        final $equals = _value as Void;
        return { 'equals': $equals.toMap() };
      case TokenType.at:
        final $at = _value as Void;
        return { 'at': $at.toMap() };
      case TokenType.dot:
        final $dot = _value as Void;
        return { 'dot': $dot.toMap() };
      case TokenType.questionMark:
        final $questionMark = _value as Void;
        return { 'questionMark': $questionMark.toMap() };
      case TokenType.leftAngleBracket:
        final $leftAngleBracket = _value as Void;
        return { 'leftAngleBracket': $leftAngleBracket.toMap() };
      case TokenType.rightAngleBracket:
        final $rightAngleBracket = _value as Void;
        return { 'rightAngleBracket': $rightAngleBracket.toMap() };
      case TokenType.leftSquareBracket:
        final $leftSquareBracket = _value as Void;
        return { 'leftSquareBracket': $leftSquareBracket.toMap() };
      case TokenType.rightSquareBracket:
        final $rightSquareBracket = _value as Void;
        return { 'rightSquareBracket': $rightSquareBracket.toMap() };
      case TokenType.leftCurlyBrace:
        final $leftCurlyBrace = _value as Void;
        return { 'leftCurlyBrace': $leftCurlyBrace.toMap() };
      case TokenType.rightCurlyBrace:
        final $rightCurlyBrace = _value as Void;
        return { 'rightCurlyBrace': $rightCurlyBrace.toMap() };
      case TokenType.leftParenthesis:
        final $leftParenthesis = _value as Void;
        return { 'leftParenthesis': $leftParenthesis.toMap() };
      case TokenType.rightParenthesis:
        final $rightParenthesis = _value as Void;
        return { 'rightParenthesis': $rightParenthesis.toMap() };
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

  static TokenData _classKeywordFromValue(Object? value) =>
    const TokenData.classKeyword();
  static TokenData _unionKeywordFromValue(Object? value) =>
    const TokenData.unionKeyword();
  static TokenData _enumKeywordFromValue(Object? value) =>
    const TokenData.enumKeyword();
  static TokenData _extendsKeywordFromValue(Object? value) =>
    const TokenData.extendsKeyword();
  static TokenData _defaultKeywordFromValue(Object? value) =>
    const TokenData.defaultKeyword();
  static TokenData _boolValueFromValue(Object? value) =>
    TokenData.boolValue(value as bool);
  static TokenData _intValueFromValue(Object? value) =>
    TokenData.intValue(value as int);
  static TokenData _doubleValueFromValue(Object? value) =>
    TokenData.doubleValue(value as double);
  static TokenData _stringValueFromValue(Object? value) =>
    TokenData.stringValue(value as String);
  static TokenData _identifierFromValue(Object? value) =>
    TokenData.identifier(value as String);
  static TokenData _colonFromValue(Object? value) =>
    const TokenData.colon();
  static TokenData _semicolonFromValue(Object? value) =>
    const TokenData.semicolon();
  static TokenData _commaFromValue(Object? value) =>
    const TokenData.comma();
  static TokenData _equalsFromValue(Object? value) =>
    const TokenData.equals();
  static TokenData _atFromValue(Object? value) =>
    const TokenData.at();
  static TokenData _dotFromValue(Object? value) =>
    const TokenData.dot();
  static TokenData _questionMarkFromValue(Object? value) =>
    const TokenData.questionMark();
  static TokenData _leftAngleBracketFromValue(Object? value) =>
    const TokenData.leftAngleBracket();
  static TokenData _rightAngleBracketFromValue(Object? value) =>
    const TokenData.rightAngleBracket();
  static TokenData _leftSquareBracketFromValue(Object? value) =>
    const TokenData.leftSquareBracket();
  static TokenData _rightSquareBracketFromValue(Object? value) =>
    const TokenData.rightSquareBracket();
  static TokenData _leftCurlyBraceFromValue(Object? value) =>
    const TokenData.leftCurlyBrace();
  static TokenData _rightCurlyBraceFromValue(Object? value) =>
    const TokenData.rightCurlyBrace();
  static TokenData _leftParenthesisFromValue(Object? value) =>
    const TokenData.leftParenthesis();
  static TokenData _rightParenthesisFromValue(Object? value) =>
    const TokenData.rightParenthesis();
  static TokenData _eofFromValue(Object? value) =>
    const TokenData.eof();

  static TokenData _classKeywordFromJoField() =>
    const TokenData.classKeyword();
  static TokenData _unionKeywordFromJoField() =>
    const TokenData.unionKeyword();
  static TokenData _enumKeywordFromJoField() =>
    const TokenData.enumKeyword();
  static TokenData _extendsKeywordFromJoField() =>
    const TokenData.extendsKeyword();
  static TokenData _defaultKeywordFromJoField() =>
    const TokenData.defaultKeyword();
  static TokenData _boolValueFromJoField(JoFieldData data) =>
    TokenData.boolValue(data.boolValue);
  static TokenData _intValueFromJoField(JoFieldData data) =>
    TokenData.intValue(data.intValue);
  static TokenData _doubleValueFromJoField(JoFieldData data) =>
    TokenData.doubleValue(data.doubleValue);
  static TokenData _stringValueFromJoField(JoFieldData data) =>
    TokenData.stringValue(data.stringValue);
  static TokenData _identifierFromJoField(JoFieldData data) =>
    TokenData.identifier(data.stringValue);
  static TokenData _colonFromJoField() =>
    const TokenData.colon();
  static TokenData _semicolonFromJoField() =>
    const TokenData.semicolon();
  static TokenData _commaFromJoField() =>
    const TokenData.comma();
  static TokenData _equalsFromJoField() =>
    const TokenData.equals();
  static TokenData _atFromJoField() =>
    const TokenData.at();
  static TokenData _dotFromJoField() =>
    const TokenData.dot();
  static TokenData _questionMarkFromJoField() =>
    const TokenData.questionMark();
  static TokenData _leftAngleBracketFromJoField() =>
    const TokenData.leftAngleBracket();
  static TokenData _rightAngleBracketFromJoField() =>
    const TokenData.rightAngleBracket();
  static TokenData _leftSquareBracketFromJoField() =>
    const TokenData.leftSquareBracket();
  static TokenData _rightSquareBracketFromJoField() =>
    const TokenData.rightSquareBracket();
  static TokenData _leftCurlyBraceFromJoField() =>
    const TokenData.leftCurlyBrace();
  static TokenData _rightCurlyBraceFromJoField() =>
    const TokenData.rightCurlyBrace();
  static TokenData _leftParenthesisFromJoField() =>
    const TokenData.leftParenthesis();
  static TokenData _rightParenthesisFromJoField() =>
    const TokenData.rightParenthesis();
  static TokenData _eofFromJoField() =>
    const TokenData.eof();
}

void joRegister() {}