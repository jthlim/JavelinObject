import '../data_type.dart' as m;
import '../module.dart' as m;
import 'ast.jo.dart';
import 'token.jo.dart';
import 'tokenizer.dart';

/// Parses a query expression.
///
/// expression ::= logical_or
///
/// logical_or ::= logical_and ['||' logical_and]*
///
/// logical_and ::= comparison ['&&' comparison]*
///
/// comparison ::= unary [('==' | '!=' | '<' | '<=' | '>' | '>=') unary] *
///
/// unary ::= ['-'] primary
///
/// primary ::= '(' expression ')'
///             | int_constant
///             | real_constant
///             | bool_constant
///             | string_constant
///             | list_constant
///             | function_call [nested_access]*
///             | identifier [nested_access]*
///             | parameter
///
/// function_call ::= identifier '(' parameter_list ')'
///
/// nested_access ::= '.' identifier ['(' parameter_list ')'] nested_access?
///
class Parser {
  Parser(this.expression, this.cls, this.method)
      : _tokens = Tokenizer(expression).tokenize().iterator {
    _nextToken();
  }

  final String expression;
  final Iterator<Token> _tokens;
  final m.Class cls;
  final m.Method method;

  late Token _currentToken;

  AstNode parse() => _parseExpression();

  void _nextToken() {
    if (_tokens.moveNext()) {
      _currentToken = _tokens.current;
    } else {
      _currentToken = const Token(data: TokenData.eof(), offset: 0);
    }
  }

  AstNode _parseExpression() => _parseLogicalOr();

  AstNode _parseLogicalOr() {
    final node = _parseLogicalAnd();
    if (_currentToken.type != TokenType.logicalOr) return node;

    final nodes = [node];
    do {
      _nextToken();
      nodes.add(_parseLogicalAnd());
    } while (_currentToken.type == TokenType.logicalOr);

    return AstNode.logicalOr(nodes);
  }

  AstNode _parseLogicalAnd() {
    final node = _parseComparison();
    if (_currentToken.type != TokenType.logicalAnd) return node;

    final nodes = [node];
    do {
      _nextToken();
      nodes.add(_parseComparison());
    } while (_currentToken.type == TokenType.logicalAnd);

    return AstNode.logicalAnd(nodes);
  }

  AstNode _parseComparison() {
    final node = _parseUnary();
    switch (_currentToken.type) {
      case TokenType.equals:
        _nextToken();
        final rhs = _parseUnary();
        return AstNode.equals(ComparisonAstNode(first: node, second: rhs));

      case TokenType.notEquals:
        _nextToken();
        final rhs = _parseUnary();
        return AstNode.notEquals(ComparisonAstNode(first: node, second: rhs));

      case TokenType.lessThan:
        _nextToken();
        final rhs = _parseUnary();
        switch (_currentToken.type) {
          case TokenType.lessThan:
            return AstNode.logicalAnd([
              AstNode.lessThan(ComparisonAstNode(first: node, second: rhs)),
              AstNode.lessThan(
                ComparisonAstNode(first: rhs, second: _parseUnary()),
              ),
            ]);
          case TokenType.lessThanOrEquals:
            return AstNode.logicalAnd([
              AstNode.lessThan(ComparisonAstNode(first: node, second: rhs)),
              AstNode.lessThanOrEquals(
                ComparisonAstNode(
                  first: rhs,
                  second: _parseUnary(),
                ),
              ),
            ]);
          default:
            break;
        }
        return AstNode.lessThan(ComparisonAstNode(first: node, second: rhs));

      case TokenType.lessThanOrEquals:
        _nextToken();
        final rhs = _parseUnary();
        switch (_currentToken.type) {
          case TokenType.lessThan:
            return AstNode.logicalAnd([
              AstNode.lessThanOrEquals(
                ComparisonAstNode(first: node, second: rhs),
              ),
              AstNode.lessThan(
                ComparisonAstNode(first: rhs, second: _parseUnary()),
              ),
            ]);
          case TokenType.lessThanOrEquals:
            return AstNode.logicalAnd([
              AstNode.lessThanOrEquals(
                ComparisonAstNode(first: node, second: rhs),
              ),
              AstNode.lessThanOrEquals(
                ComparisonAstNode(
                  first: rhs,
                  second: _parseUnary(),
                ),
              ),
            ]);
          default:
            break;
        }
        return AstNode.lessThanOrEquals(
          ComparisonAstNode(first: node, second: rhs),
        );

      case TokenType.greaterThan:
        _nextToken();
        final rhs = _parseUnary();
        switch (_currentToken.type) {
          case TokenType.greaterThan:
            return AstNode.logicalAnd([
              AstNode.lessThan(
                ComparisonAstNode(first: _parseUnary(), second: rhs),
              ),
              AstNode.lessThan(
                ComparisonAstNode(first: rhs, second: node),
              ),
            ]);
          case TokenType.greaterThanOrEquals:
            return AstNode.logicalAnd([
              AstNode.lessThanOrEquals(
                ComparisonAstNode(first: _parseUnary(), second: rhs),
              ),
              AstNode.lessThan(
                ComparisonAstNode(first: rhs, second: node),
              ),
            ]);
          default:
            break;
        }
        return AstNode.lessThan(ComparisonAstNode(first: rhs, second: node));

      case TokenType.greaterThanOrEquals:
        _nextToken();
        final rhs = _parseUnary();
        switch (_currentToken.type) {
          case TokenType.greaterThan:
            return AstNode.logicalAnd([
              AstNode.lessThan(
                ComparisonAstNode(first: _parseUnary(), second: rhs),
              ),
              AstNode.lessThan(
                ComparisonAstNode(first: rhs, second: node),
              ),
            ]);
          case TokenType.greaterThanOrEquals:
            return AstNode.logicalAnd([
              AstNode.lessThanOrEquals(
                ComparisonAstNode(first: _parseUnary(), second: rhs),
              ),
              AstNode.lessThan(
                ComparisonAstNode(first: rhs, second: node),
              ),
            ]);
          default:
            break;
        }
        return AstNode.lessThanOrEquals(
          ComparisonAstNode(first: node, second: rhs),
        );

      default:
        return node;
    }
  }

  AstNode _parseUnary() {
    if (_currentToken.type == TokenType.minus) {
      return AstNode.negate(_parsePrimary());
    }
    return _parsePrimary();
  }

  AstNode _parsePrimary() {
    switch (_currentToken.type) {
      case TokenType.boolValue:
        final value = _currentToken.boolValue;
        _nextToken();
        return AstNode.constant(Value.boolValue(value));
      case TokenType.intValue:
        final value = _currentToken.intValue;
        _nextToken();
        return AstNode.constant(Value.intValue(value));
      case TokenType.doubleValue:
        final value = _currentToken.doubleValue;
        _nextToken();
        return AstNode.constant(Value.doubleValue(value));
      case TokenType.stringValue:
        final value = _currentToken.stringValue;
        _nextToken();
        return AstNode.constant(Value.stringValue(value));
      case TokenType.identifier:
        final columnName = _currentToken.identifier;
        _nextToken();
        final field =
            cls.fields.firstWhere((f) => f.name == columnName, orElse: () {
          throw FormatException(
            'Unknown column \'$columnName\'',
            expression,
            _currentToken.offset,
          );
        });
        return AstNode.columnReference(
          ColumnReferenceAstNode(
            columnName: columnName,
            valueType: _valueTypeFromDataType(field.type),
          ),
        );
      case TokenType.parameter:
        final parameterName = _currentToken.parameter;
        _nextToken();
        final parameter = method.parameters
            .firstWhere((p) => p.name == parameterName, orElse: () {
          throw FormatException(
            'Unknown parameter \'$parameterName\'',
            expression,
            _currentToken.offset,
          );
        });
        return AstNode.parameter(
          ParameterAstNode(
            name: parameterName,
            valueType: _valueTypeFromDataType(parameter.type),
          ),
        );
      default:
        throw FormatException(
          'Unexpected token ${_currentToken.type}',
          expression,
          _currentToken.offset,
        );
    }
  }

  static ValueType _valueTypeFromDataType(m.DataType dataType) {
    // TODO
    return ValueType.intType();
  }
}
