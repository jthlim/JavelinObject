import 'package:collection/collection.dart';

enum Chartype {
  uppercase,
  lowercase,
  digit,
  underscore,
}

class VariableName {
  factory VariableName.fromCamelCase(String s) {
    final length = s.length;

    final parts = <String>[];

    Chartype? lastChartype;
    var offset = 0;

    var start = 0;

    while (offset < length) {
      final c = s.codeUnitAt(offset);

      if (0x41 <= c && c <= 0x5a) {
        if (start != offset) {
          parts.add(s.substring(start, offset).toLowerCase());
          start = offset;
        }
        lastChartype = Chartype.uppercase;
      } else if (0x61 <= c && c <= 0x7a) {
        if (lastChartype == Chartype.digit ||
            lastChartype == Chartype.underscore) {
          parts.add(s.substring(start, offset).toLowerCase());
          start = offset;
        }
        lastChartype = Chartype.lowercase;
      } else if (0x30 <= c && c <= 0x39) {
        if (lastChartype != Chartype.digit && start != offset) {
          parts.add(s.substring(start, offset).toLowerCase());
          start = offset;
        }
        lastChartype = Chartype.digit;
      } else if (c == 0x5f) {
        if (lastChartype != Chartype.underscore && start != offset) {
          parts.add(s.substring(start, offset).toLowerCase());
          start = offset;
        }
        lastChartype = Chartype.underscore;
      } else {
        throw ArgumentError('Invalid character in variable name $c');
      }
      ++offset;
    }
    parts.add(s.substring(start, length).toLowerCase());

    return VariableName._(parts);
  }

  factory VariableName.fromSnakeCase(String s) {
    final parts = s.split('_');
    return VariableName._(
      parts.where((e) => e.isNotEmpty).map((e) => e.toLowerCase()).toList(),
    );
  }

  VariableName._(this.parts);

  final List<String> parts;

  String get lowerCamelCase =>
      parts.mapIndexed(_lowerCamelCaseConverter).join('');

  String get upperCamelCase => parts.map(_capitalize).join('');

  String get lowerSnakeCase => parts.join('_');
  String get upperSnakeCase => parts.map((e) => e.toUpperCase()).join('_');

  static String _lowerCamelCaseConverter(int index, String part) =>
      index == 0 ? part : _capitalize(part);

  static String _capitalize(String s) =>
      s.substring(0, 1).toUpperCase() + s.substring(1);
}
