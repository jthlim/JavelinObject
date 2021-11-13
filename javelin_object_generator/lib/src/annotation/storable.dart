import '../compiler_context.dart';
import '../module.dart';
import '../processor.dart';

import 'annotations.jo.dart';

class StorableAnnotation implements ClassProcessor {
  const StorableAnnotation();

  @override
  Type get annotationType => Storable;

  @override
  void process(
    CompilerContext context,
    Module module,
    Class c,
    ParsedAnnotation annotation,
  ) {
    if (annotation is! Storable) throw StateError('Internal error');

    print('Storable: $annotation');

    if (annotation.postgres) {
      print('Postgres specified');
    }
  }
}
