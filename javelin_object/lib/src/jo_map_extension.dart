import 'invalid_key_exception.dart';
import 'missing_field_exception.dart';
import 'unexpected_type_exception.dart';

extension JoMapExtension on Map<Object?, Object?> {
  T joLookupValue<T>({
    required String fieldName,
    List<String> aliases = const [],
  }) {
    final value = _lookup(fieldName: fieldName, aliases: aliases);

    if (value is! T) {
      if (value == null) {
        throw MissingFieldException(fieldName: fieldName);
      }

      throw UnexpectedTypeException(
        fieldName: fieldName,
        value: value,
        expectedType: T,
      );
    }

    return value;
  }

  void validateKeys({required Set<String> validKeys}) {
    forEach((key, value) {
      if (!validKeys.contains(key)) {
        throw InvalidKeyException(key: key, value: value);
      }
    });
  }

  Object? _lookup({
    required String fieldName,
    required List<String> aliases,
  }) {
    final lookupValue = this[fieldName];
    if (lookupValue != null) return lookupValue;

    for (final alias in aliases) {
      final lookupValue = this[alias];
      if (lookupValue != null) return lookupValue;
    }

    return null;
  }

  List get joMapForJson {
    final result = <Map>[];
    forEach((k, v) => result.add({'k': k, 'v': v}));
    return result;
  }
}

extension JoListExtension on List<Object?> {
  Map get joMapFromJson {
    final result = <Object, Object>{};
    for (final element in this) {
      final map = element as Map;
      result[map['k']] = map['v'];
    }
    return result;
  }
}

extension JoTypedMapExtension<K, V> on Map<K, V> {
  Map<K2, V2> joMapNotNull<K2, V2>(
    K2? Function(K) keyConverter,
    V2? Function(V) valueConverter,
  ) {
    final result = <K2, V2>{};

    forEach((k, v) {
      final k2 = keyConverter(k);
      if (k2 == null) return;
      final v2 = valueConverter(v);
      if (v2 == null) return;
      result[k2] = v2;
    });

    return result;
  }
}

extension JoTypedIterableExtension<T> on Iterable<T> {
  Iterable<S> joMapNotNull<S>(
    S? Function(T) elementConverter,
  ) sync* {
    for (final e in this) {
      final e2 = elementConverter(e);
      if (e2 != null) {
        yield e2;
      }
    }
  }
}
