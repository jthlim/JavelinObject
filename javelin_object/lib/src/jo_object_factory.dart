import 'jo_binary_decoder.dart';

class JoObjectFactory {
  factory JoObjectFactory() {
    return _instance ??= JoObjectFactory._();
  }

  JoObjectFactory._();

  static JoObjectFactory? _instance;

  final _jsonObjectFactories = <Type, _JsonFactories>{};
  final _joMapObjectFactories = <Type, _JoMapFactories>{};
  final _joBinaryObjectFactories = <Type, _JoBinaryFactories>{};

  void registerJsonFactory<T>(
    String id,
    T Function(Map<String, Object?>) factory,
  ) {
    final jsonFactories =
        _jsonObjectFactories.putIfAbsent(T, () => _JsonFactories<T>());

    if (jsonFactories.factories.containsKey(id)) {
      throw StateError('Type $id has already registered a factory for $T');
    }

    jsonFactories.factories[id] = factory;
  }

  void registerJoMapFactory<T>(
    String id,
    T Function(Map<Object?, Object?>) factory,
  ) {
    final joMapFactories =
        _joMapObjectFactories.putIfAbsent(T, () => _JoMapFactories<T>());

    if (joMapFactories.factories.containsKey(id)) {
      throw StateError('Type $id has already registered a factory for $T');
    }

    joMapFactories.factories[id] = factory;
  }

  void registerBinaryFactory<T>(
    int id,
    T Function(Map<int, JoFieldData>) factory,
  ) {
    final binaryFactories =
        _joBinaryObjectFactories.putIfAbsent(T, () => _JoBinaryFactories<T>());

    if (binaryFactories.factories.containsKey(id)) {
      throw StateError('Type $id has already registered a factory for $T');
    }

    binaryFactories.factories[id] = factory;
  }

  T? createFromJsonMap<T>(Map<String, Object?> map) {
    final type = map['\$t'] as String?;
    if (type == null) return null;

    final factories = _jsonObjectFactories[T];
    if (factories == null) return null;

    final factory = factories.factories[type];
    if (factory == null) return null;

    return factory(map);
  }

  T? createFromJoMap<T>(Map<Object?, Object?> map) {
    final type = map['\$t'] as String?;
    if (type == null) return null;

    final factories = _joMapObjectFactories[T];
    if (factories == null) return null;

    final factory = factories.factories[type];
    if (factory == null) return null;

    return factory(map);
  }

  T? createFromBinary<T>(Map<int, JoFieldData> map, int typeFieldId) {
    final type = map.uintValue(typeFieldId);
    if (type == null) return null;

    final factories = _joBinaryObjectFactories[T];
    if (factories == null) return null;

    final factory = factories.factories[type];
    if (factory == null) return null;

    return factory(map);
  }
}

class _JsonFactories<T> {
  final factories = <String, T Function(Map<String, Object?>)>{};
}

class _JoMapFactories<T> {
  final factories = <String, T Function(Map<Object?, Object?>)>{};
}

class _JoBinaryFactories<T> {
  final factories = <int, T Function(Map<int, JoFieldData>)>{};
}
