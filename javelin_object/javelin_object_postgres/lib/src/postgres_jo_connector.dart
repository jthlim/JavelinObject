import 'package:javelin_object/javelin_object.dart';
import 'package:postgres/postgres.dart';

class PostgresJoConnector extends JoConnector {
  PostgresJoConnector({
    required String host,
    int port = 5432,
    required String database,
    required String username,
    required String password,
  }) : connection = PostgreSQLConnection(
          host,
          port,
          database,
          username: username,
          password: password,
        );

  final PostgreSQLConnection connection;

  @override
  String get tag => 'postgres';

  @override
  Future<void> close() => connection.close();

  @override
  Future<void> open() => connection.open();

  @override
  Future<void> save<T extends JoOrmMixin, Q extends JoQueries>(
    T object,
    JoTableDescriptor<T, Q> descriptor,
  ) async {
    // INSERT INTO table_name (column_names...) VALUES (values...) RETURNING id

    final data = object.toOrmMap();
    final columnNames = <String>[];
    final values = <String, Object?>{};
    final valuePlaceholders = <String>[];
    var needsReturning = false;
    data.forEach((key, value) {
      final columnName = descriptor.fieldToColumnNames[key] ?? key;
      if (value == null && descriptor.primaryKeys.contains(columnName)) {
        needsReturning = true;
        return;
      }
      columnNames.add(columnName);
      valuePlaceholders.add('@$columnName');
      values[columnName] = value;
    });

    final allColumnNames = columnNames.join(',');
    final allValuePlaceholders = valuePlaceholders.join(',');

    final insertCallback = descriptor.insertCallback;
    final returningClause = needsReturning && insertCallback == null
        ? ''
        : ' RETURNING ${descriptor.primaryKeys.join(',')}';

    final tableName = descriptor.tableName;

    final query = 'INSERT INTO $tableName($allColumnNames) VALUES'
        '($allValuePlaceholders)$returningClause';
    final result = await connection.query(query, substitutionValues: values);

    if (needsReturning && insertCallback != null) {
      if (result.length != 1) {
        throw StateError('Unexpected response length: ${result.length}');
      }

      final values = result.first;
      insertCallback(object, values);
    }
  }

  @override
  Future<int> queryCount<T extends JoOrmMixin, Q extends JoQueries>(
    String query,
    JoTableDescriptor<T, Q> descriptor,
    Map<String, Object?> parameters,
  ) async {
    // SELECT FROM table_name column_names WHERE statement'

    final results =
        await connection.query(query, substitutionValues: parameters);

    return results.length;
  }

  @override
  Future<T?> querySingle<T extends JoOrmMixin, Q extends JoQueries>(
    String query,
    JoTableDescriptor<T, Q> descriptor,
    Map<String, Object?> parameters,
  ) async {
    // SELECT FROM table_name column_names WHERE statement'

    final results =
        await connection.query(query, substitutionValues: parameters);

    switch (results.length) {
      case 0:
        return null;
      case 1:
        return descriptor.createCallback(results.first);
      default:
        throw StateError('Unexpected response length: ${results.length}');
    }
  }

  @override
  Future<List<T>> queryMulti<T extends JoOrmMixin, Q extends JoQueries>(
    String query,
    JoTableDescriptor<T, Q> descriptor,
    Map<String, Object?> parameters,
  ) async {
    // SELECT FROM table_name column_names WHERE statement'

    final results =
        await connection.query(query, substitutionValues: parameters);

    return [for (final result in results) descriptor.createCallback(result)];
  }
}
