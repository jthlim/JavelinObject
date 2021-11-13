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

import '../jo/variant.jo.dart';
import '../src/compiler_options.jo.dart';

@immutable
class JoBuilderOptions {
  const JoBuilderOptions({
    this.writeJoTokens = false,
    this.writeParse = false,
    required this.options,
  });

  JoBuilderOptions.fromMap(Map<Object?, Object?> map)
    : writeJoTokens = _writeJoTokensFromMap(map),
      writeParse = _writeParseFromMap(map),
      options = _optionsFromMap(map)  {
    map.validateKeys(validKeys: const {
      'writeJoTokens',
      'writeParse',
      'options',
    });
  }

  final bool writeJoTokens;
  final bool writeParse;
  final CompilerOptions options;

  Map<String, Object?> toMap() {
    final $writeJoTokens = writeJoTokens;
    final $writeParse = writeParse;
    final $options = options;

    return {
      'writeJoTokens': $writeJoTokens,
      'writeParse': $writeParse,
      'options': $options.toMap(),
    };
  }

  @override
  String toString({bool pretty = true}) =>
    toJoText(toMap(), pretty: pretty);

  static bool _writeJoTokensFromMap(Map<Object?, Object?> map) =>
    map.joLookupValue<bool?>(fieldName: 'writeJoTokens') ?? false;
  static bool _writeParseFromMap(Map<Object?, Object?> map) =>
    map.joLookupValue<bool?>(fieldName: 'writeParse') ?? false;
  static CompilerOptions _optionsFromMap(Map<Object?, Object?> map) {
    final lookup = map.joLookupValue<Map>(fieldName: 'options');
    return CompilerOptions.fromMap(lookup);
  }
}

void joRegister() {}