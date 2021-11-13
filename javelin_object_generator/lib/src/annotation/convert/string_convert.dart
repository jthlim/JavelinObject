import 'package:javelin_object/jo_internal.dart';

import '../../compiler_context.dart';
import '../../generator.dart';
import '../../generator_priority/object_generator_priority.dart';
import '../../module.dart';
import '../annotation_module_extension.dart';

class FromStringClassGenerator implements ClassGenerator {
  const FromStringClassGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    if (c.isVirtual) {
      if (c.isAbstract) {
        buffer.write(
          '\n'
          '  factory ${c.name}.fromString(String s) {\n'
          '    final joMap = fromJoText(s);\n'
          '    return JoObjectFactory().createFromJoMap(joMap)!;\n'
          '  }\n',
        );
      } else {
        buffer.write(
          '\n'
          '  factory ${c.name}.fromString(String s) {\n'
          '    final joMap = fromJoText(s);\n'
          '    return JoObjectFactory().createFromJoMap(joMap) ??\n'
          '        ${c.name}.fromMap(joMap);\n'
          '  }\n',
        );
      }
    } else if (!c.isAbstract) {
      buffer.write(
        '\n'
        '  factory ${c.name}.fromString(String s) => ${c.name}.fromMap(fromJoText(s));\n',
      );
    }
  }

  @override
  int get priority => ObjectGeneratorPriority.convertFactory.index;
}

class ToStringClassGenerator implements ClassGenerator {
  const ToStringClassGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Class c) {
    buffer.write(
      '\n'
      '  @override\n'
      '  String toString({bool pretty = true}) =>\n'
      '    toJoText(toMap(), pretty: pretty);\n',
    );
  }

  @override
  int get priority => ObjectGeneratorPriority.stringify.index;
}

class FromStringEnumGenerator implements EnumGenerator {
  const FromStringEnumGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Enum e) {
    buffer.write(
      '\n'
      '  factory ${e.name}.fromString(String s) =>\n'
      '    fromStringOrNull(s)!;\n'
      '\n'
      '  static ${e.name}? fromStringOrNull(String s) {\n'
      '    switch(s) {\n',
    );

    for (final value in e.values) {
      final aliases = {value.name, ...value.aliases};
      for (final alias in aliases) {
        buffer.write('    case ${alias.dartEscapedString}:\n');
      }
      buffer.write('      return ${value.name};\n');
    }

    buffer.write(
      '    }\n'
      '    return null;\n'
      '  }\n',
    );
  }

  @override
  int get priority => ObjectGeneratorPriority.convertFactory.index;
}

class ToStringEnumGenerator implements EnumGenerator {
  const ToStringEnumGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Enum e) {
    buffer.write(
      '\n'
      '  @override\n'
      '  String toString() => \$name;\n',
    );
  }

  @override
  int get priority => ObjectGeneratorPriority.stringify.index;
}

class FromStringUnionGenerator implements UnionGenerator {
  const FromStringUnionGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    if (u.isInline) {
      buffer.write(
        '\n'
        '  factory ${u.name}.fromString(String s) =>\n'
        '    ${u.name}.fromObjectOrNull(fromJoText(s))!;\n',
      );
    } else {
      buffer.write(
        '\n'
        '  factory ${u.name}.fromString(String s) =>\n'
        '    ${u.name}.fromMapOrNull(fromJoText(s))!;\n',
      );
    }
  }

  @override
  int get priority => ObjectGeneratorPriority.convertFactory.index;
}

class ToStringUnionGenerator implements UnionGenerator {
  const ToStringUnionGenerator();

  @override
  void generate(CompilerContext context, StringBuffer buffer, Union u) {
    if (u.isInline) {
      buffer.write(
        '\n'
        '  @override\n'
        '  String toString({bool pretty = true}) =>\n'
        '    toJoText(toObject(), pretty: pretty);\n',
      );
    } else {
      buffer.write(
        '\n'
        '  @override\n'
        '  String toString({bool pretty = true}) =>\n'
        '    toJoText(toMap(), pretty: pretty);\n',
      );
    }
  }

  @override
  int get priority => ObjectGeneratorPriority.stringify.index;
}
