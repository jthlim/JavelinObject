import 'dart:io';

import 'package:path/path.dart' as path;

import 'dart/data_type_format_extension.dart';
import 'data_type.dart';
import 'module.dart';
import 'token.dart';
import 'tokenizer.dart';
import 'value.jo.dart';

class Parser {
  Parser({
    required String filename,
    String? canonicalizedPath,
    required Tokenizer tokenizer,
    Map<String, Module>? moduleMap,
  })  : _module = Module(filename: filename),
        _canonicalizedPath = canonicalizedPath ?? path.canonicalize(filename),
        _tokenizer = tokenizer,
        _tokens = tokenizer.tokenize().iterator,
        _moduleMap = moduleMap ?? {} {
    _moduleMap[_canonicalizedPath] = _module;

    _nextToken();
  }

  final Module _module;
  final String _canonicalizedPath;
  final Tokenizer _tokenizer;
  final Iterator<Token> _tokens;

  final _defaultClassAnnotations = <String, Annotation>{};
  final _defaultClassFieldAnnotations = <String, Annotation>{};
  final _defaultClassMethodAnnotations = <String, Annotation>{};

  final _defaultEnumAnnotations = <String, Annotation>{};
  final _defaultEnumFieldAnnotations = <String, Annotation>{};
  final _defaultEnumValueAnnotations = <String, Annotation>{};

  final _defaultUnionAnnotations = <String, Annotation>{};
  final _defaultUnionFieldAnnotations = <String, Annotation>{};

  late Token _currentToken;

  /// Maps parsed modules to instances.
  ///
  /// This allows circular references, e.g.
  ///  a.jo:
  ///    import 'b.jo';
  ///
  ///  b.jo:
  ///    import 'a.jo';
  final Map<String, Module> _moduleMap;

  void _nextToken() {
    if (_tokens.moveNext()) {
      _currentToken = _tokens.current;
    } else {
      _currentToken = const Token(data: TokenData.eof(), line: 0, column: 0);
    }
  }

  bool _hasTokenAndAdvance(TokenType type) {
    if (_currentToken.type != type) return false;
    _nextToken();
    return true;
  }

  void _assertToken(TokenType type) {
    if (!_hasTokenAndAdvance(type)) {
      throw FormatException('Expected $type, found $_currentToken');
    }
  }

  bool _isScopeEnd(TokenType endToken) {
    if (_currentToken.type != endToken) {
      if (_currentToken.type == TokenType.eof) {
        _assertToken(endToken);
      }
      return false;
    }
    _nextToken();
    return true;
  }

  Module parseModule() {
    while (_currentToken.type != TokenType.eof) {
      final annotations = _parseAnnotations();

      switch (_currentToken.type) {
        case TokenType.classKeyword:
          _module.classes.add(_parseClass(annotations));
          break;

        case TokenType.defaultKeyword:
          _nextToken();
          _parseDefault();
          break;

        case TokenType.unionKeyword:
          _module.unions.add(_parseUnion(annotations));
          break;

        case TokenType.identifier:
          switch (_currentToken.identifier) {
            case 'extendable':
              _nextToken();
              if (_currentToken.type != TokenType.classKeyword) {
                throw FormatException(
                  'Unexpected token $_currentToken. '
                  'Expected \'class\' declaration.',
                );
              }
              _module.classes.add(
                _parseClass(annotations, extendable: true),
              );
              break;

            case 'import':
              _module.imports.add(_parseImportStatement());
              break;

            case 'inline':
              _module.unions.add(_parseUnion(annotations));
              break;

            case 'package':
              _nextToken();
              _parsePackage(annotations);
              break;

            case 'virtual':
              _nextToken();
              if (_currentToken.type != TokenType.classKeyword) {
                throw FormatException(
                  'Unexpected token $_currentToken. '
                  'Expected \'class\' declaration.',
                );
              }
              _module.classes.add(
                _parseClass(annotations, extendable: true, virtual: true),
              );
              break;

            default:
              throw FormatException(
                'Unexpected token $_currentToken. '
                'Expected \'class\' or \'enum\' declaration.',
              );
          }
          break;

        case TokenType.enumKeyword:
          _module.enums.add(_parseEnum(annotations));
          break;

        default:
          throw FormatException(
            'Unexpected token $_currentToken. '
            'Expected \'class\' or \'enum\' declaration.',
          );
      }
    }

    return _module;
  }

  Module _parseImportStatement() {
    _assertToken(TokenType.identifier);
    final pathToken = _currentToken;
    _assertToken(TokenType.stringValue);
    _assertToken(TokenType.semicolon);

    final dirname = path.dirname(_canonicalizedPath);
    final importPath = pathToken.stringValue;
    final normalizedImportPath = path.normalize(path.join(dirname, importPath));
    final canonicalizedImportPath = path.canonicalize(normalizedImportPath);

    final alreadyParsedModule = _moduleMap[canonicalizedImportPath];
    if (alreadyParsedModule != null) {
      return Module(filename: importPath);
    }

    final String input;
    try {
      input = File(normalizedImportPath).readAsStringSync();
    } on Exception {
      throw FormatException('Unable to open $importPath');
    }
    return Parser(
      filename: importPath,
      canonicalizedPath: canonicalizedImportPath,
      tokenizer: Tokenizer(input, normalizedImportPath),
      moduleMap: _moduleMap,
    ).parseModule();
  }

  /// Parses default statements.
  ///
  /// default class annotation @Annotation(parameter: value);
  /// default class field annotation @Annotation(parameter: value);
  /// default class method annotation @Annotation(parameter: value);
  ///
  /// default enum annotation @Annotation(parameter: value);
  /// default enum field annotation @Annotation(parameter: value);
  /// default enum value annotation @Annotation(parameter: value);
  ///
  /// default union annotation @Annotation(parameter: value);
  /// default union field annotation @Annotation(parameter: value);
  ///
  /// 'default' should already be removed from the token stream.
  void _parseDefault() {
    switch (_currentToken.type) {
      case TokenType.classKeyword:
        _nextToken();
        switch (_currentToken.identifierOrNull) {
          case 'annotation':
          case 'annotations':
            _nextToken();
            _parseDefaultAnnotationList(_defaultClassAnnotations);
            break;

          case 'field':
            _nextToken();
            switch (_currentToken.identifierOrNull) {
              case 'annotation':
              case 'annotations':
                _nextToken();
                _parseDefaultAnnotationList(_defaultClassFieldAnnotations);
                break;

              default:
                throw FormatException(
                  'Unable to parse default statement near $_currentToken',
                );
            }
            break;

          case 'method':
            _nextToken();
            switch (_currentToken.identifierOrNull) {
              case 'annotation':
              case 'annotations':
                _nextToken();
                _parseDefaultAnnotationList(_defaultClassMethodAnnotations);
                break;

              default:
                throw FormatException(
                  'Unable to parse default statement near $_currentToken',
                );
            }
            break;

          default:
            throw FormatException(
              'Unable to parse default statement near $_currentToken',
            );
        }
        break;

      case TokenType.enumKeyword:
        _nextToken();
        switch (_currentToken.identifierOrNull) {
          case 'annotation':
          case 'annotations':
            _nextToken();
            _parseDefaultAnnotationList(_defaultEnumAnnotations);
            break;

          case 'field':
            _nextToken();
            switch (_currentToken.identifierOrNull) {
              case 'annotation':
              case 'annotations':
                _nextToken();
                _parseDefaultAnnotationList(_defaultEnumFieldAnnotations);
                break;

              default:
                throw FormatException(
                  'Unable to parse default statement near $_currentToken',
                );
            }
            break;

          case 'value':
            _nextToken();
            switch (_currentToken.identifierOrNull) {
              case 'annotation':
              case 'annotations':
                _nextToken();
                _parseDefaultAnnotationList(_defaultEnumValueAnnotations);
                break;

              default:
                throw FormatException(
                  'Unable to parse default statement near $_currentToken',
                );
            }
            break;

          default:
            throw FormatException(
              'Unable to parse default statement near $_currentToken',
            );
        }
        break;

      case TokenType.unionKeyword:
        _nextToken();
        switch (_currentToken.identifierOrNull) {
          case 'annotation':
          case 'annotations':
            _nextToken();
            _parseDefaultAnnotationList(_defaultUnionAnnotations);
            break;

          case 'field':
            _nextToken();
            switch (_currentToken.identifierOrNull) {
              case 'annotation':
              case 'annotations':
                _nextToken();
                _parseDefaultAnnotationList(_defaultUnionFieldAnnotations);
                break;

              default:
                throw FormatException(
                  'Unable to parse default statement near $_currentToken',
                );
            }
            break;

          default:
            throw FormatException(
              'Unable to parse default statement near $_currentToken',
            );
        }
        break;

      default:
        throw FormatException(
          'Unable to parse default statement near $_currentToken',
        );
    }
    _assertToken(TokenType.semicolon);
  }

  void _parseDefaultAnnotationList(Map<String, Annotation> defaultAnnotations) {
    final annotationList = _parseAnnotations();
    for (final annotation in annotationList) {
      defaultAnnotations[annotation.name] = annotation;
    }
  }

  void _parsePackage(List<Annotation> annotations) {
    // packageName := identifier ['.' identifier]* ';'
    final packageParts = <String>[];

    for (;;) {
      final packagePartToken = _currentToken;
      _assertToken(TokenType.identifier);

      packageParts.add(packagePartToken.identifier);

      switch (_currentToken.type) {
        case TokenType.dot:
          _nextToken();
          break;

        case TokenType.semicolon:
          _nextToken();
          _module.package =
              Package(packageParts: packageParts, annotations: annotations);
          return;

        default:
          throw FormatException(
            'Expected dot or semicolon to end a package name. '
            'Found $_currentToken.',
          );
      }
    }
  }

  List<Annotation> _parseAnnotations() {
    final annotations = <Annotation>[];

    while (_hasTokenAndAdvance(TokenType.at)) {
      annotations.add(_parseAnnotation());
    }

    return annotations;
  }

  static List<Annotation> _mergeAnnotations(
    List<Annotation> annotations,
    Map<String, Annotation> defaults,
  ) {
    final presentAnnotationNames = <String>{};

    for (final annotation in annotations) {
      presentAnnotationNames.add(annotation.name);

      final defaultValues = defaults[annotation.name];
      if (defaultValues != null) {
        final mergedAnnotations = {
          ...defaultValues.parameters,
          ...annotation.parameters,
        };
        annotation.parameters = mergedAnnotations;
      }
    }

    defaults.forEach((k, v) {
      if (!presentAnnotationNames.contains(k)) {
        annotations.add(v);
      }
    });

    return annotations;
  }

  Annotation _parseAnnotation() {
    final nameToken = _currentToken;
    final name = nameToken.identifierOrNull;
    if (name == null) {
      throw const FormatException(
        'Expected annotation identifier after \'@\'',
      );
    }

    _nextToken();

    final parameters = <String, Value>{};
    _parseAnnotationParameters(parameters);

    return Annotation(name: name, parameters: parameters);
  }

  void _parseAnnotationParameters(Map<String, Value> parameters) {
    if (_currentToken.type != TokenType.leftParenthesis) return;

    _nextToken();

    while (true) {
      switch (_currentToken.type) {
        case TokenType.rightParenthesis:
          _nextToken();
          return;

        case TokenType.identifier:
          final name = _currentToken.identifier;

          _nextToken();
          _assertToken(TokenType.colon);
          final value = _parseValue();
          _hasTokenAndAdvance(TokenType.comma);

          parameters[name] = value;
          continue;

        default:
          throw FormatException(
            'Error parsing annotation parameters near $_currentToken',
          );
      }
    }
  }

  /// Parses a Value using dataType if a leading '.' is found.
  Value _parseValue({DataType? contextDataType}) {
    switch (_currentToken.type) {
      case TokenType.boolValue:
        final value = _currentToken.boolValue;
        _nextToken();
        return Value.boolValue(value);

      case TokenType.intValue:
        final value = _currentToken.intValue;
        _nextToken();
        return Value.intValue(value);

      case TokenType.doubleValue:
        final value = _currentToken.doubleValue;
        _nextToken();
        return Value.doubleValue(value);

      case TokenType.stringValue:
        final value = _currentToken.stringValue;
        _nextToken();
        return Value.stringValue(value);

      case TokenType.leftAngleBracket:
        // Set
        return _parseSet(
          elementDataType: contextDataType?.nonOptional.setTypeOrNull,
        );

      case TokenType.leftCurlyBrace:
        // Map
        final nonOptionalDataType = contextDataType?.nonOptional;
        return _parseMap(
          keyContextDataType: nonOptionalDataType?.mapTypeOrNull?.keyType,
          valueContextDataType: nonOptionalDataType?.mapTypeOrNull?.valueType,
        );

      case TokenType.leftSquareBracket:
        // List
        _nextToken();
        final result = <Value>[];

        final elementDataType = contextDataType?.nonOptional.listTypeOrNull;

        while (_currentToken.type != TokenType.rightSquareBracket) {
          result.add(_parseValue(contextDataType: elementDataType));
          _hasTokenAndAdvance(TokenType.comma);
        }
        _nextToken();
        return Value.listValue(result);

      case TokenType.dot:
        final objectDataType = contextDataType?.nonOptional.objectTypeOrNull;

        if (objectDataType == null) {
          throw FormatException('Error parsing value $_currentToken');
        }
        _nextToken();
        final valueNameToken = _currentToken;
        _assertToken(TokenType.identifier);
        final valueName = valueNameToken.identifier;

        if (_hasTokenAndAdvance(TokenType.leftParenthesis)) {
          Value? value;
          if (!_hasTokenAndAdvance(TokenType.rightParenthesis)) {
            value = _parseValue();
            _assertToken(TokenType.rightParenthesis);
          }
          return Value.unionValue(
            UnionObjectValue(
              objectType: objectDataType,
              activeElementName: valueName,
              value: value,
            ),
          );
        } else {
          return Value.enumValue(
            EnumObjectValue(
              objectType: objectDataType,
              valueName: valueName,
            ),
          );
        }

      case TokenType.identifier:
        if (_currentToken.identifier == 'new') {
          _nextToken();
          final value = _parseValue(contextDataType: contextDataType);
          return Value.newValue(value);
        }

        final dataTypeToken = _currentToken;
        final dataType = _parseDataType();

        final objectDataType = dataType.objectTypeOrNull;
        if (objectDataType == null) {
          throw FormatException('Expected object name $dataTypeToken');
        }

        switch (_currentToken.type) {
          case TokenType.dot:
            // Reference
            _nextToken();
            final valueNameToken = _currentToken;
            _assertToken(TokenType.identifier);
            final valueName = valueNameToken.identifier;

            if (_hasTokenAndAdvance(TokenType.leftParenthesis)) {
              Value? value;
              if (!_hasTokenAndAdvance(TokenType.rightParenthesis)) {
                value = _parseValue();
                _assertToken(TokenType.rightParenthesis);
              }
              return Value.unionValue(
                UnionObjectValue(
                  objectType: objectDataType,
                  activeElementName: valueName,
                  value: value,
                ),
              );
            } else {
              return Value.enumValue(
                EnumObjectValue(
                  objectType: objectDataType,
                  valueName: valueName,
                ),
              );
            }

          case TokenType.leftParenthesis:
            // Constructor.
            _nextToken();
            final parameters = <String, Value>{};
            while (!_isScopeEnd(TokenType.rightParenthesis)) {
              final valueNameToken = _currentToken;
              _assertToken(TokenType.identifier);
              final valueName = valueNameToken.identifier;
              _assertToken(TokenType.colon);
              final value = _parseValue();
              _hasTokenAndAdvance(TokenType.comma);

              parameters[valueName] = value;
            }
            return Value.classValue(
              ClassObjectValue(
                objectType: objectDataType,
                parameters: parameters,
              ),
            );

          default:
            throw FormatException('Error parsing value $_currentToken');
        }

      default:
        throw FormatException('Error parsing value $_currentToken');
    }
  }

  Value _parseMap({
    DataType? keyContextDataType,
    DataType? valueContextDataType,
  }) {
    _assertToken(TokenType.leftCurlyBrace);

    final result = <Value, Value>{};

    while (!_isScopeEnd(TokenType.rightCurlyBrace)) {
      Value? key;

      // Special case lower case identifiers as string keys inside a set.
      if (_currentToken.type == TokenType.identifier) {
        final identifier = _currentToken.identifier;
        if (identifier.isNotEmpty) {
          final firstLetter = identifier.substring(0, 1);
          if (firstLetter.toLowerCase() == firstLetter) {
            key = Value.stringValue(identifier);
            _nextToken();
          }
        }
      }
      key ??= _parseValue(contextDataType: keyContextDataType);

      _assertToken(TokenType.colon);
      final value = _parseValue(contextDataType: valueContextDataType);
      result[key] = value;
      _hasTokenAndAdvance(TokenType.comma);
    }
    return Value.mapValue(result);
  }

  Value _parseSet({DataType? elementDataType}) {
    _assertToken(TokenType.leftAngleBracket);

    final result = <Value>{};

    while (_currentToken.type != TokenType.rightAngleBracket) {
      final value = _parseValue(contextDataType: elementDataType);
      result.add(value);
      _hasTokenAndAdvance(TokenType.comma);
    }
    _nextToken();
    return Value.setValue(result);
  }

  Class _parseClass(
    List<Annotation> annotations, {
    bool extendable = false,
    bool virtual = false,
  }) {
    final documentationComments =
        _tokenizer.fetchAndResetDocumentationComments();

    _assertToken(TokenType.classKeyword);
    final classNameToken = _currentToken;
    _assertToken(TokenType.identifier);
    final className = classNameToken.identifier;

    ClassType? baseClass;
    if (_hasTokenAndAdvance(TokenType.extendsKeyword)) {
      final baseClassToken = _currentToken;
      final type = _parseNonOptionalDataType();

      final objectDataType = type.objectTypeOrNull;
      if (objectDataType == null) {
        throw FormatException(
          'Invalid base class ${type.dartType} '
          '${baseClassToken.locator(_module.filename)}',
        );
      }
      baseClass = ClassType(
        token: objectDataType.token,
        objectName: objectDataType.objectName,
      );
    }

    _assertToken(TokenType.leftCurlyBrace);

    _mergeAnnotations(annotations, _defaultClassAnnotations);

    final result = Class(
      name: className,
      nameToken: classNameToken,
      baseClass: baseClass,
      isVirtual: virtual,
      isExtendable: extendable,
      annotations: annotations,
      documentationComments: documentationComments,
    );

    while (!_isScopeEnd(TokenType.rightCurlyBrace)) {
      final annotations = _parseAnnotations();

      if (_currentToken.type == TokenType.intValue) {
        result.fields.add(_parseFieldWithId(annotations));
      } else {
        _parseMethodOrField(result, annotations);
      }
    }

    return result;
  }

  Union _parseUnion(List<Annotation> annotations) {
    final documentationComments =
        _tokenizer.fetchAndResetDocumentationComments();

    var inline = false;
    if (_currentToken.identifierOrNull == 'inline') {
      inline = true;
      _nextToken();
    }

    _assertToken(TokenType.unionKeyword);
    final unionNameToken = _currentToken;
    _assertToken(TokenType.identifier);
    final unionName = unionNameToken.identifier;

    _assertToken(TokenType.leftCurlyBrace);

    _mergeAnnotations(annotations, _defaultUnionAnnotations);

    final result = Union(
      name: unionName,
      nameToken: unionNameToken,
      annotations: annotations,
      isInline: inline,
      documentationComments: documentationComments,
    );

    while (!_isScopeEnd(TokenType.rightCurlyBrace)) {
      final annotations = _parseAnnotations();
      _mergeAnnotations(annotations, _defaultUnionFieldAnnotations);

      final Field field;
      if (_currentToken.type == TokenType.intValue) {
        field = _parseFieldWithId(annotations);
      } else {
        field =
            _parseFieldWithoutId(annotations, _defaultUnionFieldAnnotations);
      }
      result.fields.add(field);

      if (inline && field.type.isOptional) {
        throw FormatException(
          'Inline union $unionName cannot have optional data type for field '
          '${field.name}',
        );
      }
    }

    return result;
  }

  Field _parseFieldWithId(List<Annotation> annotations) {
    final documentationComments =
        _tokenizer.fetchAndResetDocumentationComments();
    final idToken = _currentToken;
    _assertToken(TokenType.intValue);

    _assertToken(TokenType.colon);

    final type = _parseDataType();
    final nameToken = _currentToken;
    _assertToken(TokenType.identifier);
    final name = nameToken.identifier;

    Value? defaultValue;
    if (_hasTokenAndAdvance(TokenType.equals)) {
      defaultValue = _parseValue(contextDataType: type);
    }
    _assertToken(TokenType.semicolon);

    _mergeAnnotations(annotations, _defaultClassFieldAnnotations);

    return Field(
      fieldId: idToken.intValue,
      name: name,
      annotations: annotations,
      type: type,
      defaultValue: defaultValue,
      documentationComments: documentationComments,
    );
  }

  void _parseMethodOrField(Class c, List<Annotation> annotations) {
    final documentationComments =
        _tokenizer.fetchAndResetDocumentationComments();
    final type = _parseDataType();
    final nameToken = _currentToken;
    _assertToken(TokenType.identifier);
    final name = nameToken.identifier;

    switch (_currentToken.type) {
      case TokenType.semicolon:
        _nextToken();
        _mergeAnnotations(annotations, _defaultClassFieldAnnotations);
        c.fields.add(
          Field(
            annotations: annotations,
            name: name,
            type: type,
            defaultValue: null,
            documentationComments: documentationComments,
          ),
        );
        break;

      case TokenType.equals:
        _nextToken();
        final defaultValue = _parseValue(contextDataType: type);
        _assertToken(TokenType.semicolon);

        _mergeAnnotations(annotations, _defaultClassFieldAnnotations);

        c.fields.add(
          Field(
            annotations: annotations,
            name: name,
            type: type,
            defaultValue: defaultValue,
            documentationComments: documentationComments,
          ),
        );
        break;

      case TokenType.leftParenthesis:
        _nextToken();
        // It's a method
        final parameters = <MethodParameter>[];

        _mergeAnnotations(annotations, _defaultClassMethodAnnotations);

        while (!_isScopeEnd(TokenType.rightParenthesis)) {
          final parameterAnnotations = _parseAnnotations();
          final parameterType = _parseDataType();
          final parameterNameToken = _currentToken;
          _assertToken(TokenType.identifier);
          final parameterName = parameterNameToken.identifier;

          parameters.add(
            MethodParameter(
              name: parameterName,
              annotations: parameterAnnotations,
              type: parameterType,
            ),
          );
          _hasTokenAndAdvance(TokenType.comma);
        }
        _assertToken(TokenType.semicolon);

        c.methods.add(
          Method(
            name: name,
            annotations: annotations,
            returnType: type,
            parameters: parameters,
          ),
        );
        break;

      default:
        throw FormatException('Error parsing value $_currentToken');
    }
  }

  Field _parseFieldWithoutId(List<Annotation> annotations,
      Map<String, Annotation> defaultAnnotations) {
    final documentationComments =
        _tokenizer.fetchAndResetDocumentationComments();
    final type = _parseDataType();
    final nameToken = _currentToken;
    _assertToken(TokenType.identifier);
    final name = nameToken.identifier;

    if (_hasTokenAndAdvance(TokenType.equals)) {
      final defaultValue = _parseValue(contextDataType: type);
      _assertToken(TokenType.semicolon);

      return Field(
        annotations: annotations,
        name: name,
        type: type,
        defaultValue: defaultValue,
        documentationComments: documentationComments,
      );
    }

    _assertToken(TokenType.semicolon);
    return Field(
      annotations: annotations,
      name: name,
      type: type,
      defaultValue: null,
      documentationComments: documentationComments,
    );
  }

  DataType _parseDataType() {
    final dataType = _parseNonOptionalDataType();

    if (!_hasTokenAndAdvance(TokenType.questionMark)) {
      return dataType;
    }

    return dataType.optional;
  }

  DataType _parseNonOptionalDataType() {
    final token = _currentToken;
    _assertToken(TokenType.identifier);
    final stringValue = token.identifier;

    switch (stringValue) {
      case 'Bool':
        return const DataType.boolType();

      case 'Int8':
        return const DataType.int8Type();

      case 'Uint8':
        return const DataType.uint8Type();

      case 'Int32':
        return const DataType.int32Type();

      case 'Uint32':
        return const DataType.uint32Type();

      case 'Int64':
        return const DataType.int64Type();

      case 'Uint64':
        return const DataType.uint64Type();

      case 'Float':
        return const DataType.floatType();

      case 'Double':
        return const DataType.doubleType();

      case 'String':
        return const DataType.stringType();

      case 'Bytes':
        return const DataType.bytesType();

      case 'List':
        _assertToken(TokenType.leftAngleBracket);
        final elementType = _parseDataType();
        _assertToken(TokenType.rightAngleBracket);

        if (elementType.isOptional) {
          throw FormatException(
            'Lists cannot have nullable elements, Token: $token',
          );
        }
        return DataType.listType(elementType);

      case 'Set':
        _assertToken(TokenType.leftAngleBracket);
        final elementType = _parseDataType();
        _assertToken(TokenType.rightAngleBracket);

        if (elementType.isOptional) {
          throw FormatException(
            'Sets cannot have nullable elements, Token: $token',
          );
        }
        return DataType.setType(elementType);

      case 'Map':
        _assertToken(TokenType.leftAngleBracket);
        final keyType = _parseDataType();
        _assertToken(TokenType.comma);
        final valueType = _parseDataType();
        _assertToken(TokenType.rightAngleBracket);

        if (keyType.isOptional) {
          throw FormatException(
              'Maps cannot have nullable keys, Token: $token');
        }
        if (valueType.isOptional) {
          throw FormatException(
              'Maps cannot have nullable values, Token: $token');
        }
        return DataType.mapType(
          MapType(keyType: keyType, valueType: valueType),
        );

      default:
        final firstLetter = stringValue.substring(0, 1);
        if (firstLetter.toUpperCase() != firstLetter) {
          throw FormatException(
            'Invalid type name $stringValue. Type names should begin with an '
            'upper case letter. Token: $token',
          );
        }
        return DataType.objectType(
          ObjectType(token: token, objectName: stringValue),
        );
    }
  }

  Enum _parseEnum(List<Annotation> annotations) {
    final documentationComments =
        _tokenizer.fetchAndResetDocumentationComments();

    _assertToken(TokenType.enumKeyword);
    final enumNameToken = _currentToken;
    _assertToken(TokenType.identifier);
    final enumName = enumNameToken.identifier;
    _assertToken(TokenType.leftCurlyBrace);

    _mergeAnnotations(annotations, _defaultEnumAnnotations);

    final result = Enum(
      annotations: annotations,
      name: enumName,
      nameToken: enumNameToken,
      documentationComments: documentationComments,
    );

    var currentId = 0;

    while (!_isScopeEnd(TokenType.rightCurlyBrace)) {
      final annotations = _parseAnnotations();
      var mustBeEnumValue = false;

      if (_currentToken.type == TokenType.intValue) {
        mustBeEnumValue = true;
        currentId = _currentToken.intValue;
        _nextToken();
        _assertToken(TokenType.colon);
      }

      // Either a field declaration or an enum name.
      // Fields must begin with a type.

      if (_currentToken.type != TokenType.identifier) {
        throw FormatException('Expected identifier, found $_currentToken');
      }
      final elementName = _currentToken.identifier;
      final firstLetter = elementName.substring(0, 1);
      if (firstLetter.toUpperCase() != firstLetter) {
        _nextToken();

        _mergeAnnotations(annotations, _defaultEnumValueAnnotations);

        // Lower case -> identifier = enum value.

        if (!_hasTokenAndAdvance(TokenType.equals)) {
          _assertToken(TokenType.semicolon);

          result.values.add(
            EnumValue(
              name: elementName,
              annotations: annotations,
              id: currentId++,
              documentationComments:
                  _tokenizer.fetchAndResetDocumentationComments(),
              fieldValues: const EnumFieldValues.none(),
            ),
          );

          continue;
        }

        if (_currentToken.type == TokenType.identifier) {
          // Map of values.
          final fieldValueMap = <String, Value>{};
          while (!_isScopeEnd(TokenType.semicolon)) {
            final fieldNameToken = _currentToken;
            _assertToken(TokenType.identifier);
            final fieldName = fieldNameToken.identifier;
            _assertToken(TokenType.colon);
            final object = _parseValue();

            if (fieldValueMap.containsKey(fieldName)) {
              throw FormatException('$fieldName already given a value');
            }
            fieldValueMap[fieldName] = object;

            _hasTokenAndAdvance(TokenType.comma);
          }

          result.values.add(
            EnumValue(
              name: elementName,
              annotations: annotations,
              id: currentId++,
              documentationComments:
                  _tokenizer.fetchAndResetDocumentationComments(),
              fieldValues: EnumFieldValues.map(fieldValueMap),
            ),
          );
        } else {
          // List of values.
          final fieldValues = <Value>[];
          while (!_isScopeEnd(TokenType.semicolon)) {
            fieldValues.add(_parseValue());
            _hasTokenAndAdvance(TokenType.comma);
          }

          result.values.add(
            EnumValue(
              name: elementName,
              annotations: annotations,
              id: currentId++,
              documentationComments:
                  _tokenizer.fetchAndResetDocumentationComments(),
              fieldValues: EnumFieldValues.list(fieldValues),
            ),
          );
        }
      } else {
        // Upper case letter -> Must be field
        if (mustBeEnumValue) {
          throw ('Found $elementName. Expected enum value, which must start with a lowercase.');
        }
        result.fields.add(
          _parseFieldWithoutId(annotations, _defaultEnumFieldAnnotations),
        );
      }
    }

    return result;
  }
}
