import 'compiler_context.dart';
import 'module.dart';

abstract class Generator {
  int get priority;

  static int compare(Generator a, Generator b) => a.priority - b.priority;
}

abstract class ModuleGenerator extends Generator {
  void generate(CompilerContext context, StringBuffer buffer, Module module);
}

abstract class ClassGenerator extends Generator {
  void generate(CompilerContext context, StringBuffer buffer, Class c);
}

abstract class UnionGenerator extends Generator {
  void generate(CompilerContext context, StringBuffer buffer, Union u);
}

abstract class EnumGenerator extends Generator {
  void generate(CompilerContext context, StringBuffer buffer, Enum e);
}

abstract class FieldGenerator extends Generator {
  void generate(
    CompilerContext context,
    StringBuffer buffer,
    ObjectBase object,
    Field field,
  );
}

abstract class MethodGenerator extends Generator {
  void generate(
    CompilerContext context,
    StringBuffer buffer,
    ObjectBase object,
    Method method,
  );
}

abstract class EnumValueGenerator extends Generator {
  void generate(
    CompilerContext context,
    StringBuffer buffer,
    Enum e,
    EnumValue enumValue,
  );
}
