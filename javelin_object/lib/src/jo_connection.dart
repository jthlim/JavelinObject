import 'jo_orm_mixin.dart';
import 'jo_table_descriptor.dart';

abstract class JoConnector {
  String get tag;

  Future<void> open();
  Future<void> close();

  Future<void> save<T extends JoOrmMixin, Q extends JoQueries>(
    T object,
    JoTableDescriptor<T, Q> descriptor,
  );

  Future<int> queryCount<T extends JoOrmMixin, Q extends JoQueries>(
    String query,
    JoTableDescriptor<T, Q> descriptor,
    Map<String, Object?> parameters,
  );

  Future<T?> querySingle<T extends JoOrmMixin, Q extends JoQueries>(
    String query,
    JoTableDescriptor<T, Q> descriptor,
    Map<String, Object?> parameters,
  );

  Future<List<T>> queryMulti<T extends JoOrmMixin, Q extends JoQueries>(
    String query,
    JoTableDescriptor<T, Q> descriptor,
    Map<String, Object?> parameters,
  );
}

class JoConnection {
  JoConnection({required this.connector});

  factory JoConnection.instance(
    JoConnection? orm,
    JoTableDescriptors descriptors,
  ) {
    if (orm != null) return orm;
    return openInstances.singleWhere(
      (e) => descriptors.tagToDescriptors.containsKey(e.connector.tag),
    );
  }

  final JoConnector connector;

  static final openInstances = <JoConnection>{};

  // Opens a connection to the database.
  Future<void> open() async {
    await connector.open();
    openInstances.add(this);
  }

  // Closes a connection to the database.
  Future<void> close() async {
    openInstances.remove(this);
    await connector.close();
  }

  Future<void> save<T extends JoOrmMixin, Q extends JoQueries>(
    T object,
    JoTableDescriptors<T, Q> descriptors,
  ) =>
      connector.save(object, descriptors[this]);

  Future<int> queryCount<T extends JoOrmMixin, Q extends JoQueries>(
    String query,
    JoTableDescriptor<T, Q> descriptor,
    Map<String, Object?> parameters,
  ) =>
      connector.queryCount(query, descriptor, parameters);

  Future<T?> querySingle<T extends JoOrmMixin, Q extends JoQueries>(
    String query,
    JoTableDescriptor<T, Q> descriptor,
    Map<String, Object?> parameters,
  ) =>
      connector.querySingle(query, descriptor, parameters);

  Future<List<T>> queryMulti<T extends JoOrmMixin, Q extends JoQueries>(
    String query,
    JoTableDescriptor<T, Q> descriptor,
    Map<String, Object?> parameters,
  ) =>
      connector.queryMulti(query, descriptor, parameters);
}
