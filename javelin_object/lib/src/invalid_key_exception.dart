class InvalidKeyException implements Exception {
  const InvalidKeyException({
    required this.key,
    required this.value,
  });

  final Object? key;
  final Object? value;

  @override
  String toString() => 'Unexpected key \'$key\' with value $value';
}
