import 'dart:math';

class JoImmutableList<T> implements List<T> {
  const JoImmutableList(this._values);

  factory JoImmutableList.of(Iterable<T> values) {
    if (values is JoImmutableList<T>) return values;
    return JoImmutableList(List.unmodifiable(values));
  }

  final List<T> _values;

  @override
  T get first => _values.first;
  @override
  set first(T newValue) {
    throw StateError('Cannot set first on an ImmutableList');
  }

  @override
  T get last => _values.last;
  @override
  set last(T newValue) {
    throw StateError('Cannot set last on an ImmutableList');
  }

  @override
  int get length => _values.length;

  @override
  set length(int newValue) {
    throw StateError('Cannot set length on an ImmutableList');
  }

  @override
  List<T> operator +(List<T> other) => _values + other;

  @override
  T operator [](int index) => _values[index];

  @override
  void operator []=(int index, T value) {
    throw StateError('Cannot assign to an ImmutableList');
  }

  @override
  void add(T value) {
    throw StateError('Cannot add() to an ImmutableList');
  }

  @override
  void addAll(Iterable<T> iterable) {
    throw StateError('Cannot addAll() to an ImmutableList');
  }

  @override
  bool any(bool Function(T element) test) => _values.any(test);

  @override
  Map<int, T> asMap() => _values.asMap();

  @override
  List<R> cast<R>() => _values.cast<R>();

  @override
  void clear() {
    throw StateError('Cannot clear() an ImmutableList');
  }

  @override
  bool contains(Object? element) => _values.contains(element);

  @override
  T elementAt(int index) => _values.elementAt(index);

  @override
  bool every(bool Function(T element) test) => _values.every(test);

  @override
  Iterable<E> expand<E>(Iterable<E> Function(T element) f) => _values.expand(f);

  @override
  void fillRange(int start, int end, [T? fillValue]) {
    throw StateError('Cannot fillRange() on an ImmutableList');
  }

  @override
  T firstWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _values.firstWhere(test, orElse: orElse);

  @override
  E fold<E>(E initialValue, E Function(E previousValue, T element) combine) =>
      _values.fold(initialValue, combine);

  @override
  Iterable<T> followedBy(Iterable<T> other) => _values.followedBy(other);

  @override
  void forEach(void Function(T element) f) => _values.forEach(f);

  @override
  Iterable<T> getRange(int start, int end) => _values.getRange(start, end);

  @override
  int indexOf(T element, [int start = 0]) => _values.indexOf(element, start);

  @override
  int indexWhere(bool Function(T element) test, [int start = 0]) =>
      _values.indexWhere(test, start);

  @override
  void insert(int index, T element) {
    throw StateError('Cannot insert() on an ImmutableList');
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    throw StateError('Cannot insertAll() on an ImmutableList');
  }

  @override
  bool get isEmpty => _values.isEmpty;

  @override
  bool get isNotEmpty => _values.isNotEmpty;

  @override
  Iterator<T> get iterator => _values.iterator;

  @override
  String join([String separator = '']) => _values.join(separator);

  @override
  int lastIndexOf(T element, [int? start]) =>
      _values.lastIndexOf(element, start);

  @override
  int lastIndexWhere(bool Function(T element) test, [int? start]) =>
      _values.lastIndexWhere(test, start);

  @override
  T lastWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _values.lastWhere(test, orElse: orElse);

  @override
  Iterable<S> map<S>(S Function(T e) f) => _values.map(f);

  @override
  T reduce(T Function(T value, T element) combine) => _values.reduce(combine);

  @override
  bool remove(Object? value) {
    throw StateError('Cannot remove() on an ImmutableList');
  }

  @override
  T removeAt(int index) {
    throw StateError('Cannot removeAt() on an ImmutableList');
  }

  @override
  T removeLast() {
    throw StateError('Cannot removeLast() on an ImmutableList');
  }

  @override
  void removeRange(int start, int end) {
    throw StateError('Cannot removeRange() on an ImmutableList');
  }

  @override
  void removeWhere(bool Function(T element) test) {
    throw StateError('Cannot removeWhere() on an ImmutableList');
  }

  @override
  void replaceRange(int start, int end, Iterable<T> replacements) {
    throw StateError('Cannot replaceRange() on an ImmutableList');
  }

  @override
  void retainWhere(bool Function(T element) test) {
    throw StateError('Cannot retainWhere() on an ImmutableList');
  }

  @override
  Iterable<T> get reversed => throw UnimplementedError();

  @override
  void setAll(int index, Iterable<T> iterable) {
    throw StateError('Cannot setAll an ImmutableList');
  }

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    throw StateError('Cannot setRange() on an ImmutableList');
  }

  @override
  void shuffle([Random? random]) {
    throw StateError('Cannot shuffle() an ImmutableList');
  }

  @override
  T get single => _values.single;

  @override
  T singleWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _values.singleWhere(test, orElse: orElse);

  @override
  Iterable<T> skip(int count) => _values.skip(count);

  @override
  Iterable<T> skipWhile(bool Function(T value) test) => _values.skipWhile(test);

  @override
  void sort([int Function(T a, T b)? compare]) {
    throw StateError('Cannot sort() an ImmutableList');
  }

  @override
  List<T> sublist(int start, [int? end]) => _values.sublist(start, end);

  @override
  Iterable<T> take(int count) => _values.take(count);

  @override
  Iterable<T> takeWhile(bool Function(T value) test) => _values.takeWhile(test);

  @override
  List<T> toList({bool growable = true}) => _values.toList(growable: growable);

  @override
  Set<T> toSet() => _values.toSet();

  @override
  Iterable<T> where(bool Function(T element) test) => _values.where(test);

  @override
  Iterable<S> whereType<S>() => _values.whereType<S>();
}

class JoImmutableSet<T> implements Set<T> {
  const JoImmutableSet(this._values);

  factory JoImmutableSet.of(Iterable<T> values) {
    if (values is JoImmutableSet<T>) return values;
    return JoImmutableSet(Set.unmodifiable(values));
  }

  final Set<T> _values;

  @override
  bool add(T value) {
    throw StateError('Cannot add() to an ImmutableSet');
  }

  @override
  void addAll(Iterable<T> elements) {
    throw StateError('Cannot addAll() to an ImmutableSet');
  }

  @override
  bool any(bool Function(T element) test) => _values.any(test);

  @override
  Set<R> cast<R>() => _values.cast<R>();

  @override
  void clear() {
    throw StateError('Cannot clear() an ImmutableSet');
  }

  @override
  bool contains(Object? value) => _values.contains(value);

  @override
  bool containsAll(Iterable<Object?> other) => _values.containsAll(other);

  @override
  Set<T> difference(Set<Object?> other) => _values.difference(other);

  @override
  T elementAt(int index) => _values.elementAt(index);

  @override
  bool every(bool Function(T element) test) => _values.every(test);

  @override
  Iterable<E> expand<E>(Iterable<E> Function(T element) f) => _values.expand(f);

  @override
  T get first => _values.first;

  @override
  T firstWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _values.firstWhere(test, orElse: orElse);

  @override
  S fold<S>(S initialValue, S Function(S previousValue, T element) combine) =>
      _values.fold(initialValue, combine);

  @override
  Iterable<T> followedBy(Iterable<T> other) => _values.followedBy(other);

  @override
  void forEach(void Function(T element) f) => _values.forEach(f);

  @override
  Set<T> intersection(Set<Object?> other) => _values.intersection(other);

  @override
  bool get isEmpty => _values.isEmpty;

  @override
  bool get isNotEmpty => _values.isNotEmpty;

  @override
  Iterator<T> get iterator => _values.iterator;

  @override
  String join([String separator = '']) => _values.join(separator);

  @override
  T get last => _values.last;

  @override
  T lastWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _values.lastWhere(test, orElse: orElse);

  @override
  int get length => _values.length;

  @override
  T? lookup(Object? object) => _values.lookup(object);

  @override
  Iterable<S> map<S>(S Function(T e) f) => _values.map(f);

  @override
  T reduce(T Function(T value, T element) combine) => _values.reduce(combine);

  @override
  bool remove(Object? value) {
    throw StateError('Cannot remove() on an ImmutableSet');
  }

  @override
  void removeAll(Iterable<Object?> elements) {
    throw StateError('Cannot removeAll() on an ImmutableSet');
  }

  @override
  void removeWhere(bool Function(T element) test) {
    throw StateError('Cannot removeWhere() on an ImmutableSet');
  }

  @override
  void retainAll(Iterable<Object?> elements) {
    throw StateError('Cannot retainAll() on an ImmutableSet');
  }

  @override
  void retainWhere(bool Function(T element) test) {
    throw StateError('Cannot retainWhere() on an ImmutableSet');
  }

  @override
  T get single => _values.single;

  @override
  T singleWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _values.singleWhere(test, orElse: orElse);

  @override
  Iterable<T> skip(int count) => _values.skip(count);

  @override
  Iterable<T> skipWhile(bool Function(T value) test) => _values.skipWhile(test);

  @override
  Iterable<T> take(int count) => _values.take(count);

  @override
  Iterable<T> takeWhile(bool Function(T value) test) => _values.takeWhile(test);

  @override
  List<T> toList({bool growable = true}) => _values.toList(growable: growable);

  @override
  Set<T> toSet() => this;

  @override
  Set<T> union(Set<T> other) => _values.union(other);

  @override
  Iterable<T> where(bool Function(T element) test) => _values.where(test);

  @override
  Iterable<S> whereType<S>() => _values.whereType<S>();
}

class JoImmutableMap<K, V> implements Map<K, V> {
  const JoImmutableMap(this._values);

  factory JoImmutableMap.of(Map<K, V> values) {
    if (values is JoImmutableMap<K, V>) return values;
    return JoImmutableMap(values);
  }

  final Map<K, V> _values;

  @override
  V? operator [](Object? key) => _values[key];

  @override
  void operator []=(K key, V value) {
    throw StateError('Cannot assign to an ImmutableMap');
  }

  @override
  void addAll(Map<K, V> other) {
    throw StateError('Cannot addAll() on an ImmutableMap');
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> newEntries) {
    throw StateError('Cannot addEntries() on an ImmutableMap');
  }

  @override
  Map<RK, RV> cast<RK, RV>() => _values.cast();

  @override
  void clear() {
    throw StateError('Cannot clear() an ImmutableMap');
  }

  @override
  bool containsKey(Object? key) => _values.containsKey(key);

  @override
  bool containsValue(Object? value) => _values.containsValue(value);

  @override
  Iterable<MapEntry<K, V>> get entries => _values.entries;

  @override
  void forEach(void Function(K key, V value) action) => _values.forEach(action);

  @override
  bool get isEmpty => _values.isEmpty;

  @override
  bool get isNotEmpty => _values.isNotEmpty;

  @override
  Iterable<K> get keys => _values.keys;

  @override
  int get length => _values.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) convert) =>
      _values.map(convert);

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    throw StateError('Cannot putIfAbsent() on an ImmutableMap');
  }

  @override
  V? remove(Object? key) {
    throw StateError('Cannot remove() on an ImmutableMap');
  }

  @override
  void removeWhere(bool Function(K key, V value) test) {
    throw StateError('Cannot removeWhere() on an ImmutableMap');
  }

  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) {
    throw StateError('Cannot update() on an ImmutableMap');
  }

  @override
  void updateAll(V Function(K key, V value) update) {
    throw StateError('Cannot updateAll() on an ImmutableMap');
  }

  @override
  Iterable<V> get values => _values.values;
}
