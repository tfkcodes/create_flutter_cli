import 'dart:io';
import 'package:create_flutter_cli/src/generator.dart';
import 'package:interact/interact.dart';

/// CLI entry point for generating a Flutter project scaffold.
/// Asks the user questions, builds a config, and triggers the generation pipeline.
Future<void> main(List<String> arguments) async {
  // Prompt for project name
  final projectName = Input(
    prompt: 'Enter your project name',
  ).interact();

  // Ask whether to include a default folder structure
  final structure = Confirm(
    prompt: 'Generate folder structure?',
    defaultValue: true,
  ).interact();

  // Ask user to select networking type
  final networkIndex = Select(
    prompt: 'Select networking type',
    options: ['none', 'rest', 'graphql'],
  ).interact();

  // Ask user to select state management type
  final stateIndex = Select(
    prompt: 'Select state management',
    options: ['none', 'provider'],
  ).interact();

  // Convert indices to nullable strings
  final state = stateIndex == 0 ? null : ['provider'][stateIndex - 1];

  final network =
      networkIndex == 0 ? null : ['rest', 'graphql'][networkIndex - 1];

  // Collect REST API endpoints if user selected REST
  List<String> apis = [];
  if (networkIndex == 1) {
    final endpointStr = Input(
      prompt: 'Enter comma-separated REST endpoints (e.g. login,register)',
    ).interact();

    apis = endpointStr
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // Ask whether to include routing configuration
  final routing = Confirm(
    prompt: 'Add routing support?',
    defaultValue: true,
  ).interact();

  // Ask for supported language codes for localization
  final languageInput = Input(
    prompt: 'Enter comma-separated language codes (e.g. en,sw,fr)',
  ).interact();

  List<String> languages = languageInput
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  // Ask user to select default language if localization is enabled
  String? defaultLanguage;
  if (languages.isNotEmpty) {
    final defaultLangIndex = Select(
      prompt: 'Select default language',
      options: languages,
    ).interact();

    defaultLanguage = languages[defaultLangIndex];
  }

  // Ask whether to include light/dark theme support
  final theme = Confirm(
    prompt: 'Add light/dark theme support?',
    defaultValue: true,
  ).interact();

  // Create configuration model from the user's selections
  final config = GeneratorConfig(
    state: state,
    theme: theme,
    network: network,
    routing: routing,
    structure: structure,
    apis: apis,
    languages: languages,
    defaultLanguage: defaultLanguage,
  );

  // Show spinner while generating the project
  final spinner = Spinner(
    icon: '⏳',
    rightPrompt: (done) => done
        ? '$projectName Flutter project created'
        : 'Creating $projectName ...',
  ).interact();

  // Run the generator with the user's config
  final generator = Generator(projectName, config);
  await generator.generate();

  spinner.done();

  // Define required dependencies based on the config
  final dependencies = <String>{
    if (state == 'provider') ...[
      'provider',
      'http',
      'file_picker',
      'equatable',
      'either_dart',
      'flutter_localization'
    ],
    if (state == 'bloc') 'flutter_bloc',
    if (state == 'getx') 'get',
    if (state == 'riverpod') 'flutter_riverpod',
    if (network == 'rest') 'http',
    if (network == 'graphql') 'graphql_flutter',
    if (languages.isNotEmpty) ...[
      'intl',
    ],
  };

  // Validate that project folder exists
  final projectDir = Directory(projectName);
  if (!projectDir.existsSync()) {
    print('❌ Project folder not found!');
    exit(1);
  }

  // Install dependencies via `flutter pub add`
  if (dependencies.isNotEmpty) {
    print('\n📦 Adding required packages...');
    final pkgsList = dependencies.join(' ');
    final result = await Process.run(
      'flutter',
      ['pub', 'add', ...dependencies],
      workingDirectory: projectName,
    );

    if (result.exitCode == 0) {
      print('✅ Added packages: $pkgsList');

      // Run flutter pub get to ensure everything is fetched
      final pubGetResult = await Process.run(
        'flutter',
        ['pub', 'get'],
        workingDirectory: projectName,
      );

      if (pubGetResult.exitCode == 0) {
        print('🚀 flutter pub get completed successfully.');
      } else {
        print('❌ Failed to run flutter pub get:\n${pubGetResult.stderr}');
      }
    } else {
      print('❌ Failed to add packages:\n${result.stderr}');
    }
  }

  // Final success message
  print('\n✨ Done! Your Flutter project is ready in "$projectName".');
  print('🙏 Thanks for using the Flutter CLI Generator!');
}
