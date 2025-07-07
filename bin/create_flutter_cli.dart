import 'package:create_flutter_cli/src/generator.dart';
import 'package:interact/interact.dart';
import 'dart:io';

/// Entry point for the Flutter project CLI generator.
Future<void> main(List<String> arguments) async {
  // Ask for project name
  final projectName = Input(prompt: 'Enter your project name').interact();

  // Confirm if standard folder structure should be generated
  final structure = Confirm(
    prompt: 'Generate folder structure?',
    defaultValue: true,
  ).interact();

  // Choose between REST or GraphQL networking
  final networkIndex = Select(
    prompt: 'Select networking type',
    options: ['none', 'rest', 'graphql'],
  ).interact();

  // Choose state management approach
  final stateIndex = Select(
    prompt: 'Select state management',
    options: ['none', 'provider', 'bloc', 'getx', 'riverpod'],
  ).interact();

  // Map user selections to actual values
  final state = stateIndex == 0
      ? null
      : ['provider', 'bloc', 'getx', 'riverpod'][stateIndex - 1];
  final network =
      networkIndex == 0 ? null : ['rest', 'graphql'][networkIndex - 1];

  // Collect REST API endpoints (only if REST is selected)
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

  // Confirm if routing setup should be added
  final routing = Confirm(
    prompt: 'Add routing support?',
    defaultValue: true,
  ).interact();

  List<String> languages = [];
// Collect supported languages
  final languageInput = Input(
    prompt: 'Enter comma-separated language codes (e.g. en,sw,fr)',
  ).interact();

  languages = languageInput
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  String? defaultLanguage;
  if (languages.isNotEmpty) {
    final defaultLangIndex = Select(
      prompt: 'Select default language',
      options: languages,
    ).interact();

    defaultLanguage = languages[defaultLangIndex];
  }
  // Confirm if themes should be included
  final theme = Confirm(
    prompt: 'Add light/dark theme support?',
    defaultValue: true,
  ).interact();

  // Create config object
  final config = GeneratorConfig(
      state: state,
      theme: theme,
      network: network,
      routing: routing,
      structure: structure,
      apis: apis,
      languages: languages,
      defaultLanguage: defaultLanguage);

  // Spinner for project creation
  final spinner = Spinner(
    icon: '⏳',
    rightPrompt: (done) => done
        ? '$projectName Flutter project created'
        : 'Creating $projectName ...',
  ).interact();

  final generator = Generator(projectName, config);
  await generator.generate();

  spinner.done();

  // Pub add packages based on selections
  final projectDir = Directory(projectName);
  if (!projectDir.existsSync()) {
    print('Project folder not found!');
    exit(1);
  }

  final dependencies = <String>{
    if (state == 'provider') ...[
      'provider',
      'http',
      'file_picker',
      'equatable',
      'either'
    ],
    if (state == 'bloc') 'flutter_bloc',
    if (state == 'getx') 'get',
    if (state == 'riverpod') 'flutter_riverpod',
    if (network == 'rest') 'http',
    if (network == 'graphql') 'graphql_flutter',
    if (languages.isNotEmpty) ...['flutter_localizations', 'intl'],
  };

  if (dependencies.isNotEmpty) {
    print('\n📦 Adding required packages...');
    for (final pkg in dependencies) {
      final result = await Process.run(
        'flutter',
        ['pub', 'add', pkg],
        workingDirectory: projectName,
      );
      if (result.exitCode == 0) {
        print('✅ Added: $pkg');
        if (languages.isNotEmpty) {
          print(
              '\n🗣 Localization setup complete for: ${languages.join(', ')}');
          print(
              '➡ Don\'t forget to update your MaterialApp with supportedLocales and localizationsDelegates.');
        }
      } else {
        print('❌ Failed to add $pkg:\n${result.stderr}');
      }
    }
  }

  print('\n✨ Done! Your Flutter project is ready in "$projectName".');
  print('🙏 Thanks for using the Flutter CLI Generator!');
}
