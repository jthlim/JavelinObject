class UnexpectedTypeException implements Exception {
  const UnexpectedTypeException({
    required this.fieldName,
    required this.value,
    required this.expectedType,
  });

  final String fieldName;
  final Object value;
  final Type expectedType;

  @override
  String toString() => 'Expected $expectedType for \'$fieldName\', but found '
      '${value.runtimeType} with value $value';
}
