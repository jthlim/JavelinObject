class MissingFieldException implements Exception {
  const MissingFieldException({required this.fieldName});

  final String fieldName;

  @override
  String toString() => 'Missing field \'$fieldName\'';
}
