import 'annotation/annotations.jo.dart' as jo;
import 'generator.dart';
import 'module.dart';
import 'processor.dart';

abstract class CompilerContext {
  void addModuleProcessor(ModuleProcessor processor);
  void addModuleGenerator(ModuleGenerator generator);

  void addClassProcessor(ClassProcessor processor);
  void addClassGenerator(ClassGenerator generator, {Class? c});

  void addEnumProcessor(EnumProcessor processor);
  void addEnumGenerator(EnumGenerator generator, {Enum? e});

  void addUnionProcessor(UnionProcessor processor);
  void addUnionGenerator(UnionGenerator generator, {Union? u});

  void addClassFieldProcessor(FieldProcessor processor);
  void addEnumFieldProcessor(FieldProcessor processor);
  void addUnionFieldProcessor(FieldProcessor processor);

  void addFieldGenerator(
    FieldGenerator generator, {
    ObjectBase? object,
    Field? f,
  });

  void addMethodProcessor(MethodProcessor processor);
  void addMethodGenerator(
    MethodGenerator generator, {
    ObjectBase? object,
    Method? m,
  });

  void addEnumValueProcessor(EnumValueProcessor processor);
  void addEnumValueGenerator(
    EnumValueGenerator generator, {
    Enum? e,
    EnumValue? v,
  });

  void processModule(Module module);

  void generateModule(StringBuffer buffer, Module c);
  void generateClass(StringBuffer buffer, Class c);
  void generateEnum(StringBuffer buffer, Enum e);
  void generateUnion(StringBuffer buffer, Union u);
  void generateField(StringBuffer buffer, ObjectBase c, Field f);
  void generateMethod(StringBuffer buffer, ObjectBase c, Method m);
  void generateEnumValue(StringBuffer buffer, Enum e, EnumValue v);

  bool isConditionEnabled(jo.BoolOrCondition condition);
}
