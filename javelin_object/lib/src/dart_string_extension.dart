extension DartStringExtension on String {
  String get dartEscapedString {
    final buffer = StringBuffer();
    buffer.write('\'');

    final length = this.length;
    for (var i = 0; i < length; ++i) {
      final c = codeUnitAt(i);
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
        case 0x22: // Double quote
        case 0x24: // '$'
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
    return buffer.toString();
  }
}
