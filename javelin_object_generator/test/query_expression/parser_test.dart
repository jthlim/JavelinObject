import 'package:javelin_object_generator/src/data_type.dart' as m;
import 'package:javelin_object_generator/src/module.dart' as m;
import 'package:javelin_object_generator/src/query_expression/ast.jo.dart';
import 'package:javelin_object_generator/src/query_expression/parser.dart';
import 'package:javelin_object_generator/src/token.jo.dart' as m;
import 'package:test/test.dart';

void main() {
  group('Query Expression', () {
    group(Parser, () {
      test('should parse simple equals statement', () {
        final cls = m.Class(
          annotations: [],
          name: 'Person',
          isVirtual: false,
          isExtendable: false,
          nameToken: const m.Token(
            data: m.TokenData.identifier('Person'),
            line: 1,
            column: 1,
          ),
          documentationComments: [],
          fields: [
            m.Field(
              annotations: [],
              name: 'id',
              type: const m.DataType.int64Type(),
              documentationComments: [],
              fieldId: 0,
              defaultValue: null,
            )
          ],
        );

        final method = m.Method(
          annotations: [],
          name: 'fetchById',
          returnType: const m.DataType.int64Type(),
          parameters: [
            m.MethodParameter(
              annotations: [],
              name: 'id',
              type: const m.DataType.int64Type(),
            )
          ],
        );

        final result = Parser('id == \$id', cls, method).parse();
        expect(result.type, AstNodeType.equals);
        expect(result.equals.first.type, AstNodeType.columnReference);
        expect(result.equals.first.columnReference.columnName, 'id');
        expect(result.equals.second.type, AstNodeType.parameter);
        expect(result.equals.second.parameter.name, 'id');
      });
    });
  });
}
