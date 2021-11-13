import 'package:build/build.dart';

import '../src/compiler.dart' as jo;
import '../src/parser.dart' as jo;
import '../src/tokenizer.dart' as jo;

import 'jo_builder_options.jo.dart';

class JoBuilder extends Builder {
  JoBuilder(this.options);

  final BuilderOptions options;

  @override
  Future<void> build(BuildStep buildStep) async {
    final options = JoBuilderOptions.fromMap(this.options.config);
    print('JoBuilder.build config: $options');

    final inputId = buildStep.inputId;
    final input = await buildStep.readAsString(inputId);

    if (options.writeJoTokens) {
      final outputId = inputId.addExtension('.tokens');
      await _writeTokensFile(input, inputId.path, outputId, buildStep);
    }

    final tokenizer = jo.Tokenizer(input, inputId.path);
    final module = jo.Parser(
      filename: inputId.path,
      tokenizer: tokenizer,
    ).parseModule();

    if (options.writeParse) {
      final outputId = inputId.addExtension('.parse');
      await buildStep.writeAsString(outputId, module.toString());
    }

    final buffer = StringBuffer();
    final joBuilder = jo.Compiler(options: options.options);
    joBuilder.processModule(module);
    joBuilder.generateModule(buffer, module);

    final outputId = inputId.addExtension('.dart');
    await buildStep.writeAsString(outputId, buffer.toString());
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
        '.jo': ['.jo.tokens', '.jo.parse', '.jo.dart']
      };

  Future<void> _writeTokensFile(
    String input,
    String inputFilePath,
    AssetId outputId,
    BuildStep buildStep,
  ) async {
    final tokens = jo.Tokenizer(input, inputFilePath).tokenize();

    final buffer = StringBuffer();
    for (final token in tokens) {
      buffer.write('$token\n');
    }
    await buildStep.writeAsString(outputId, buffer.toString());
  }
}
