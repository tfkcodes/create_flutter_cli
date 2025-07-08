import 'dart:io';

import 'package:create_flutter_cli/templates/api/api_client.dart';
import 'package:create_flutter_cli/templates/api/environment_configuration.dart';
import 'package:create_flutter_cli/templates/api/error_map.dart';
import 'package:create_flutter_cli/templates/api/graphql_client.dart';
import 'package:create_flutter_cli/templates/api/response_handler.dart';
import 'package:create_flutter_cli/templates/localizations/app_localization.dart';
import 'package:create_flutter_cli/templates/models/example_model.dart';
import 'package:create_flutter_cli/templates/provider/main_provider.dart';
import 'package:create_flutter_cli/templates/provider/provider.dart';
import 'package:create_flutter_cli/templates/repository/repository.dart';
import 'package:create_flutter_cli/templates/theme/app_colors.dart';
import 'package:create_flutter_cli/templates/theme/theme.dart';
import 'package:create_flutter_cli/templates/widgets/app_buttons.dart';
import 'package:create_flutter_cli/templates/yaml/yaml_template.dart';

/// Configuration object used to control the CLI generator behavior.
class GeneratorConfig {
  /// State management type: 'provider', 'bloc', 'getx', 'riverpod', or null.
  final String? state;

  /// Whether to generate light/dark theme setup.
  final bool theme;

  /// Networking type: 'rest', 'graphql', or null.
  final String? network;

  /// Whether to include a routing configuration.
  final bool routing;

  /// Whether to scaffold a default folder structure.
  final bool structure;

  /// REST API endpoint paths to scaffold in endpoints.dart.
  final List<String> apis;

  /// Language codes for localization (e.g. ['en', 'sw']).
  final List<String> languages;

  /// Default locale code for `MaterialApp.locale` (e.g. 'en').
  String? defaultLanguage;

  GeneratorConfig({
    this.state,
    required this.theme,
    this.network,
    required this.routing,
    required this.structure,
    this.apis = const [],
    this.languages = const [],
    this.defaultLanguage,
  });
}

/// Main project generator class that scaffolds a Flutter app
/// based on the provided configuration options.
class Generator {
  final GeneratorConfig config;
  final String projectName;

  Generator(this.projectName, this.config);

  /// Top-level entry point that sequentially builds all configured
  /// project components (project, structure, state, theme, etc).
  Future<void> generate() async {
    await _createFlutterProject();
    await updatePubspecYaml(
      projectName,
      useProvider: config.state == 'provider',
      useHttp: config.network == 'rest',
      useIntl: config.languages.isNotEmpty,
    );
    if (config.structure) _generateStructure();
    if (config.network != null) _generateNetworking(config.network!);
    if (config.languages.isNotEmpty) _generateLocalization(config.languages);
    if (config.theme) _generateTheme();
    if (config.routing) _generateRouting();

    await generateMainFile(config, projectName, config.state!);
    // if (config.state != null) _generateStateManagement(config.state!);
  }

  /// Runs `flutter create` command to generate a blank Flutter project.
  Future<void> _createFlutterProject() async {
    final result = await Process.run('flutter', ['create', projectName]);

    if (result.exitCode == 0) {
      print('Flutter project "$projectName" created successfully.');
    } else {
      print('Error creating Flutter project: ${result.stderr}');
      exit(1);
    }
  }

  /// Creates the recommended folder structure inside the `lib/` directory.
  void _generateStructure() {
    final dirs = [
      'lib/core',
      'lib/features',
      'lib/features/widgets',
      'lib/features/pages',
      'lib/data/models',
      'lib/data/repositories',
      'lib/config',
    ];

    _write('$projectName/lib/features/widgets/app_button.dart',
        appButtons(projectName));
    for (var dir in dirs) {
      Directory('$projectName/$dir').createSync(recursive: true);
      print('Created :$dir');
    }
  }

  // /// Generates the boilerplate setup file for the selected state management strategy.
  // /// Only supports 'provider', 'bloc', 'getx', 'riverpod'.
  // void _generateStateManagement(String type) {
  //   final basePath = '$projectName/lib/core/state';
  //   Directory(basePath).createSync(recursive: true);
  //   switch (type.toLowerCase()) {
  //     case 'provider':
  //       _write('$basePath/provider.dart', '// Provider setup');
  //       break;
  //     case 'bloc':
  //       _write('$basePath/bloc.dart', '// BLoC setup');
  //       break;
  //     case 'getx':
  //       _write('$basePath/getx.dart', '// GetX setup');
  //       break;
  //     case 'riverpod':
  //       _write('$basePath/riverpod.dart', '// Riverpod setup');
  //       break;
  //     default:
  //       print('Unsupported state management: $type');
  //   }
  // }

  /// Generates theme files (light & dark) along with a theme provider.
  void _generateTheme() {
    final themePath = '$projectName/lib/config/themes';
    Directory(themePath).createSync(recursive: true);
    _write('$themePath/theme.dart', themeConfig(projectName));
    _write('$themePath/app_colors.dart', appColors());
    _write('$themePath/theme_provider.dart', '// Theme provider');
  }

  /// Generates networking structure and files.
  /// If REST is chosen, scaffolds client, handler, mapper, provider, repository, and endpoints.
  void _generateNetworking(String type) {
    final networkPath = '$projectName/lib/core/network';
    Directory(networkPath).createSync(recursive: true);

    switch (type.toLowerCase()) {
      case 'rest':
        _write('$networkPath/api_client.dart', requestProvider(projectName));
        _write('$networkPath/response_handler.dart', responseHandlerStub());
        _write(
            '$projectName/lib/data/models/example_model.dart', exampleModel());
        _write('$projectName/lib/data/repositories/example_repository.dart',
            exampleRepository(projectName));
        _write('$networkPath/response_handler.dart', responseHandlerStub());
        _write('$networkPath/error_mapper.dart', errorMapperStub());
        _write('$networkPath/provider/example_provider.dart',
            exampleProvider(projectName));
        _write('$projectName/lib/data/repositories/example_repository.dart',
            exampleRepository(projectName));

        if (config.apis.isNotEmpty) {
          _generateEndpoints(config.apis);
        } else {
          _generateEndpoints([]);
        }
        break;

      case 'graphql':
        _write('$networkPath/graphql_client.dart',
            graphqlClientRequest(projectName));
        _write(
            '$projectName/lib/data/models/example_model.dart', exampleModel());
        break;

      default:
        print('Unsupported network type: $type');
    }
  }

  /// Creates a basic route setup file at `config/routes/app_router.dart`.
  void _generateRouting() {
    final routePath = '$projectName/lib/config/routes';
    Directory(routePath).createSync(recursive: true);
    _write('$routePath/app_router.dart', '// App routing setup');
  }

  /// Generates `endpoints.dart` with constants for each endpoint,
  /// including the baseUrl resolved from AppConfig.
  void _generateEndpoints(List<String> endpoints) {
    final networkPath = '$projectName/lib/core/network';
    Directory(networkPath).createSync(recursive: true);

    final buffer = StringBuffer()
      ..writeln("import 'package:$projectName/config/environment.dart';\n")
      ..writeln("class Endpoints {")
      ..writeln('  static String baseUrl = AppConfig().baseUrl;\n')
      ..writeln(
          '  static const String getExampleEndpoint = "/getExampleData";\n');

    for (var e in endpoints) {
      buffer.writeln('  static const String ${e.trim()} = "/${e.trim()}";');
    }

    buffer.writeln("}");

    _write("$networkPath/endpoints.dart", buffer.toString());
    _write(
        "$projectName/lib/config/environment.dart", environmentConfiguration());
  }

  /// Writes the [content] to the specified [path].
  /// Prevents overwriting files where the same class or full content already exists.
  void _write(String path, String content, {bool append = false}) {
    final file = File(path);
    final className = _extractClassName(content);

    if (!file.existsSync()) {
      file.createSync(recursive: true);
      file.writeAsStringSync(content);
      print('Created :$path');
      return;
    }

    final existingContent = file.readAsStringSync();

    if (className != null && existingContent.contains('class $className')) {
      print('Skipped (class "$className" already exists) :$path');
      return;
    }

    if (existingContent.contains(content.trim())) {
      print('Skipped (content already exists) :$path');
      return;
    }

    if (append) {
      file.writeAsStringSync('\n$content', mode: FileMode.append);
      print('Appended :$path');
    } else {
      file.writeAsStringSync(content);
      print('Overwritten :$path');
    }
  }

  /// Extracts the first Dart class name found in a content string.
  /// Useful for detecting duplication before writing.
  String? _extractClassName(String content) {
    final regex = RegExp(r'class\s+(\w+)\s*[{|<]');
    final match = regex.firstMatch(content);
    return match?.group(1);
  }

  /// Generates localization boilerplate:
  /// - `app_localizations.dart`
  /// - Empty `.json` files for each language
  /// - Asset registration in pubspec.yaml
  void _generateLocalization(List<String> languages) {
    final localizationPath = '$projectName/lib/core/localization';
    Directory(localizationPath).createSync(recursive: true);

    final localizationContent = appLocalization(languages);
    _write('$localizationPath/app_localizations.dart', localizationContent);

    // Create assets/lang/<code>.json
    final assetPath = '$projectName/assets/lang';
    Directory(assetPath).createSync(recursive: true);

    for (final lang in languages) {
      final file = File('$assetPath/$lang.json');
      if (!file.existsSync()) {
        file.writeAsStringSync('{}');
        print('Created :assets/lang/$lang.json');
      }
    }

    // Register asset path in pubspec.yaml
    final pubspecFile = File('$projectName/pubspec.yaml');
    if (pubspecFile.existsSync()) {
      final content = pubspecFile.readAsStringSync();
      if (!content.contains('assets/lang/')) {
        final updated = content.replaceFirst(
          RegExp(r'(flutter:\s*\n\s*assets:\s*\n)?'),
          'flutter:\n  assets:\n    - assets/lang/\n',
        );
        pubspecFile.writeAsStringSync(updated);
        print('Updated :pubspec.yaml with asset localization path');
      }
    }
  }
}
