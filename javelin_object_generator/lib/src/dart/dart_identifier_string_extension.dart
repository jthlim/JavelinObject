extension DartIdentifierStringExtension on String {
  String get dartIdentifier {
    final buffer = StringBuffer();

    final length = this.length;
    for (var i = 0; i < length; ++i) {
      final c = codeUnitAt(i);

      if (_isIdentifierCodeUnit(c)) {
        buffer.writeCharCode(c);
      } else {
        buffer.writeCharCode(0x24);
      }
    }

    return buffer.toString();
  }

  static bool _isIdentifierCodeUnit(int c) {
    // 'A' -> 'Z'
    if (0x41 <= c && c <= 0x5a) return true;

    // 'a' -> 'z'
    if (0x61 <= c && c <= 0x7a) return true;

    // '_'
    if (c == 0x5f) return true;

    // '0' -> '9'
    if (0x30 <= c && c <= 0x39) return true;

    // '_'
    if (c == 0x5f) return true;

    // '$'
    if (c == 0x24) return true;

    return false;
  }
}
