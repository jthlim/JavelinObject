import '../../compiler_context.dart';
import '../../generator.dart';
import '../../generator_priority/object_generator_priority.dart';
import '../../module.dart';

class FromYamlClassGenerator implements ClassGenerator {
  const FromYamlClassGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    if (c.isVirtual) {
      buffer.write(
        '\n'
        '  factory ${c.name}.fromYaml(String yaml) {\n'
        '    final joMap = loadYaml(yaml);\n'
        '    return JoObjectFactory().createFromJoMap(joMap) ??\n'
        '        ${c.name}.fromMap(joMap);\n'
        '  }\n',
      );
    } else {
      buffer.write(
        '\n'
        '  factory ${c.name}.fromYaml(String yaml) => ${c.name}.fromMap(loadYaml(yaml));\n',
      );
    }
  }

  @override
  int get priority => ObjectGeneratorPriority.convertFactory.index;
}

class FromYamlUnionGenerator implements UnionGenerator {
  const FromYamlUnionGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    if (u.isInline) {
      buffer.write(
        '\n'
        '  factory ${u.name}.fromYaml(String yaml) => ${u.name}.fromObject(loadYaml(yaml));\n',
      );
    } else {
      buffer.write(
        '\n'
        '  factory ${u.name}.fromYaml(String yaml) => ${u.name}.fromMap(loadYaml(yaml));\n',
      );
    }
  }

  @override
  int get priority => ObjectGeneratorPriority.convertFactory.index;
}
