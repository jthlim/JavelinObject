import 'dart:io';

import 'package:args/args.dart';
import 'package:javelin_object_generator/src/compiler.dart' as jo;
import 'package:javelin_object_generator/src/compiler_options.jo.dart';
import 'package:javelin_object_generator/src/module.jo.dart' as jo;
import 'package:javelin_object_generator/src/parser.dart' as jo;
import 'package:javelin_object_generator/src/tokenizer.dart' as jo;
import 'package:path/path.dart' as path;

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption(
      'output',
      help: 'The output file to use. Defaults to the input file with '
          '\'.dart\' appended',
      abbr: 'o',
    )
    ..addFlag(
      'dump-parse-text',
      help: 'Outputs the first stage of the parse to a text file',
    )
    ..addFlag(
      'dump-parse-binary',
      help: 'Outputs the first stage of the parse to a binary file',
    )
    ..addFlag(
      'verbose',
      help: 'Prints more information while compiling',
      abbr: 'v',
    )
    ..addMultiOption(
      'roles',
      help: 'The roles to use when compiling the object',
    );

  final argResults = parser.parse(arguments);

  final rest = argResults.rest;
  if (rest.isEmpty) {
    print('jo compiler usage:\n');
    print(parser.usage);
    return;
  }

  final verbose = argResults['verbose'] as bool;

  for (final inputFile in rest) {
    if (verbose) {
      print('$inputFile');
    }
    final outputFile = argResults['output'] ?? '$inputFile.dart';

    final module = readModule(inputFile);

    if (argResults['dump-parse-text'] as bool) {
      final parseFileName = path.setExtension(inputFile, '.jot');
      File(parseFileName).writeAsStringSync(module.toString());
    }

    if (argResults['dump-parse-binary'] as bool) {
      final parseFileName = path.setExtension(inputFile, '.job');
      File(parseFileName).writeAsBytesSync(module.toBytes());
    }

    final buffer = StringBuffer();
    final joBuilder = jo.Compiler(
      options: CompilerOptions(roles: argResults['roles'] as List<String>),
    );
    joBuilder.processModule(module);
    joBuilder.generateModule(buffer, module);

    File(outputFile).writeAsStringSync(buffer.toString());
  }
}

jo.Module readModule(String inputFile) {
  if (inputFile.endsWith('.job')) {
    final input = File(inputFile).readAsBytesSync();
    return jo.Module.fromBytes(input);
  } else if (inputFile.endsWith('.jot')) {
    final input = File(inputFile).readAsStringSync();
    return jo.Module.fromString(input);
  } else if (inputFile.endsWith('.jo')) {
    final input = File(inputFile).readAsStringSync();
    final tokenizer = jo.Tokenizer(input, inputFile);
    return jo.Parser(
      filename: inputFile,
      tokenizer: tokenizer,
    ).parseModule();
  } else {
    throw Exception(
      'Unsupported input file $inputFile. Expect files ending in '
      '.jo, .job or .jot',
    );
  }
}
