import 'token.jo.dart';
export 'token.jo.dart';

extension TokenExtension on Token {
  String locator(String filename) => '($filename:$line:$column)';
}
