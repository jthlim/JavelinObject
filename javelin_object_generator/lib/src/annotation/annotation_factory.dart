import '../dart/dart_value_extension.dart';
import '../value.jo.dart';
import 'annotations.jo.dart';

ParsedAnnotation createAnnotation(String name, Map<String, Value> parameters) =>
    _createAnnotation(name, parameters, _annotationFactoryMap);

ParsedAnnotation createClassAnnotation(
  String name,
  Map<String, Value> parameters,
) =>
    _createAnnotation(name, parameters, _classAnnotationFactoryMap);

ParsedAnnotation createEnumAnnotation(
  String name,
  Map<String, Value> parameters,
) =>
    _createAnnotation(name, parameters, _enumAnnotationFactoryMap);

ParsedAnnotation createUnionAnnotation(
  String name,
  Map<String, Value> parameters,
) =>
    _createAnnotation(name, parameters, _unionAnnotationFactoryMap);

ParsedAnnotation _createAnnotation(
  String name,
  Map<String, Value> parameters,
  Map<String, ParsedAnnotation Function(Map<Object, Object?>)> map,
) {
  final factory = map[name];
  final parameterMap = parameters.map((k, v) => MapEntry(k, v.toDartObject()));

  try {
    if (factory != null) {
      return factory(parameterMap);
    }

    return UnknownAnnotation(name: name, parameters: parameters);
  } on Exception catch (e) {
    throw Exception(
      'Exception $e while processing annotation @$name, '
      'parameters: $parameterMap,',
    );
  }
}

final _annotationFactoryMap =
    <String, ParsedAnnotation Function(Map<Object, Object?>)>{
  'ActiveElement': (parameters) => ActiveElement.fromMap(parameters),
  'Alias': (parameters) => Alias.fromMap(parameters),
  'Available': (parameters) => Available.fromMap(parameters),
  'Buildable': (parameters) => Buildable.fromMap(parameters),
  'Column': (parameters) => Column.fromMap(parameters),
  'CopyWith': (parameters) => CopyWith.fromMap(parameters),
  'Deprecated': (parameters) => Deprecated.fromMap(parameters),
  'Embed': (parameters) => Embed.fromMap(parameters),
  'Immutable': (parameters) => Immutable.fromMap(parameters),
  'JsonAlias': (parameters) => JsonAlias.fromMap(parameters),
  'MergeWith': (parameters) => MergeWith.fromMap(parameters),
  'Storable': (parameters) => Storable.fromMap(parameters),
  'Table': (parameters) => Table.fromMap(parameters),
  'When': (parameters) => When.fromMap(parameters),
};

final _classAnnotationFactoryMap =
    <String, ParsedAnnotation Function(Map<Object, Object?>)>{
  'Abstract': (parameters) => Abstract.fromMap(parameters),
  'Available': (parameters) => Available.fromMap(parameters),
  'Buildable': (parameters) => Buildable.fromMap(parameters),
  'Column': (parameters) => Column.fromMap(parameters),
  'Comparable': (parameters) => ComparableClass.fromMap(parameters),
  'Convert': (parameters) => ConvertClass.fromMap(parameters),
  'CopyWith': (parameters) => CopyWith.fromMap(parameters),
  'Deprecated': (parameters) => Deprecated.fromMap(parameters),
  'Immutable': (parameters) => Immutable.fromMap(parameters),
  'MergeWith': (parameters) => MergeWith.fromMap(parameters),
  'Placeholder': (parameters) => Placeholder.fromMap(parameters),
  'Storable': (parameters) => Storable.fromMap(parameters),
  'Table': (parameters) => Table.fromMap(parameters),
};

final _enumAnnotationFactoryMap =
    <String, ParsedAnnotation Function(Map<Object, Object?>)>{
  'Available': (parameters) => Available.fromMap(parameters),
  'Convert': (parameters) => ConvertEnum.fromMap(parameters),
  'Deprecated': (parameters) => Deprecated.fromMap(parameters),
  'EnumValues': (parameters) => EnumValues.fromMap(parameters),
};

final _unionAnnotationFactoryMap =
    <String, ParsedAnnotation Function(Map<Object, Object?>)>{
  'ActiveElement': (parameters) => ActiveElement.fromMap(parameters),
  'Available': (parameters) => Available.fromMap(parameters),
  'Comparable': (parameters) => ComparableUnion.fromMap(parameters),
  'Convert': (parameters) => ConvertUnion.fromMap(parameters),
  'Deprecated': (parameters) => Deprecated.fromMap(parameters),
  'Immutable': (parameters) => Immutable.fromMap(parameters),
  'Placeholder': (parameters) => Placeholder.fromMap(parameters),
  'Table': (parameters) => Table.fromMap(parameters),
  'When': (parameters) => When.fromMap(parameters),
};
