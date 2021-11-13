import 'jo_connection.dart';
import 'jo_orm_mixin.dart';

class JoTableDescriptors<T extends JoOrmMixin, Q extends JoQueries> {
  const JoTableDescriptors({required this.tagToDescriptors});

  final Map<String, JoTableDescriptor<T, Q>> tagToDescriptors;

  JoTableDescriptor<T, Q> operator [](JoConnection connection) =>
      tagToDescriptors[connection.connector.tag]!;
}

class JoTableDescriptor<T extends JoOrmMixin, Q extends JoQueries> {
  const JoTableDescriptor({
    required this.type,
    required this.tableName,
    required this.fieldToColumnNames,
    required this.createCallback,
    required this.insertCallback,
    required this.primaryKeys,
    required this.columns,
    required this.foreignKeys,
    required this.queries,
  });

  final String type;
  final String tableName;
  final Map<String, String> fieldToColumnNames;
  final T Function(List<Object?> values) createCallback;
  final void Function(T object, List<Object?> values)? insertCallback;
  final List<String> primaryKeys;
  final List<JoColumnDescriptor> columns;
  final List<JoForeignKey> foreignKeys;
  final Q queries;
}

class JoColumnDescriptor {
  const JoColumnDescriptor({
    required this.id,
    required this.name,
    required this.type,
    this.isPrimary = false,
    this.isSequence = false,
    this.isUnique = false,
  });

  final int id;
  final String name;
  final String type;
  final bool isPrimary;
  final bool isSequence;
  final bool isUnique;
}

class JoForeignKey {
  const JoForeignKey({
    required this.tableName,
    required this.columnNameMap,
  });

  final String tableName;
  final Map<String, String> columnNameMap;
}

class JoQueries {
  const JoQueries();
}
