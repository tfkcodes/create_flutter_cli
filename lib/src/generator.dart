import 'dart:io';

import 'package:create_flutter_cli/templates/api/api_client.dart';
import 'package:create_flutter_cli/templates/api/error_map.dart';
import 'package:create_flutter_cli/templates/api/response_handler.dart';
import 'package:create_flutter_cli/templates/provider/provider.dart';
import 'package:create_flutter_cli/templates/repository/repository.dart';

/// Configuration object for the Flutter CLI generator.
class GeneratorConfig {
  final String? state;
  final bool theme;
  final String? network;
  final bool routing;
  final bool structure;
  final List<String> apis;

  GeneratorConfig({
    this.state,
    required this.theme,
    this.network,
    required this.routing,
    required this.structure,
    this.apis = const [],
  });
}

/// Main generator class that produces files and folders
/// based on the provided [GeneratorConfig].
class Generator {
  final GeneratorConfig config;
  final String projectName;

  Generator(this.projectName, this.config);

  /// Entry point for generating project structure
  Future<void> generate() async {
    await _createFlutterProject();
    if (config.structure) _generateStructure();
    if (config.state != null) _generateStateManagement(config.state!);
    if (config.theme) _generateTheme();
    if (config.network != null) _generateNetworking(config.network!);
    if (config.routing) _generateRouting();
  }

  /// Runs `flutter create` to scaffold a base Flutter project.
  Future<void> _createFlutterProject() async {
    final result = await Process.run('flutter', ['create', projectName]);

    if (result.exitCode == 0) {
      print('Flutter project "$projectName" created successfully.');
    } else {
      print('Error creating Flutter project: ${result.stderr}');
      exit(1);
    }
  }

  /// Creates the standard folder structure under `lib/`.
  void _generateStructure() {
    final dirs = [
      'lib/core',
      'lib/features',
      'lib/data/models',
      'lib/data/repositories',
      'lib/config',
    ];
    for (var dir in dirs) {
      Directory('$projectName/$dir').createSync(recursive: true);
      print('Created :$dir');
    }
  }

  /// Creates setup files for the selected state management approach.
  void _generateStateManagement(String type) {
    final basePath = '$projectName/lib/core/state';
    Directory(basePath).createSync(recursive: true);
    switch (type.toLowerCase()) {
      case 'provider':
        _write('$basePath/provider.dart', '// Provider setup');
        break;
      case 'bloc':
        _write('$basePath/bloc.dart', '// BLoC setup');
        break;
      case 'getx':
        _write('$basePath/getx.dart', '// GetX setup');
        break;
      case 'riverpod':
        _write('$basePath/riverpod.dart', '// Riverpod setup');
        break;
      default:
        print('Unsupported state management: $type');
    }
  }

  /// Generates files for light and dark theme support.
  void _generateTheme() {
    final themePath = '$projectName/lib/config/themes';
    Directory(themePath).createSync(recursive: true);
    _write('$themePath/light_theme.dart', '// Light theme');
    _write('$themePath/dark_theme.dart', '// Dark theme');
    _write('$themePath/theme_provider.dart', '// Theme provider');
  }

  /// Generates network layer files depending on whether REST or GraphQL is selected.
  void _generateNetworking(String type) {
    final networkPath = '$projectName/lib/core/network';
    Directory(networkPath).createSync(recursive: true);
    switch (type.toLowerCase()) {
      case 'rest':
        _write('$networkPath/api_client.dart', requestProvider());
        _write('$networkPath/response_handler.dart', responseHandlerStub());
        _write('$networkPath/error_mapper.dart', errorMapperStub());
        _write(
            '$networkPath/provider/example_provider.dart', exampleProvider());
        _write('$networkPath/repositor/example_repository.dart',
            exampleRepository());

        if (config.apis.isNotEmpty) {
          _generateEndpoints(config.apis);
          for (var api in config.apis) {
            _generateRequestAndResponse(api);
          }
        }
        break;

      case 'graphql':
        _write('$networkPath/graphql_client.dart', '// GraphQL client');
        break;

      default:
        print('Unsupported network type: $type');
    }
  }

  /// Generates basic app router file.
  void _generateRouting() {
    final routePath = '$projectName/lib/config/routes';
    Directory(routePath).createSync(recursive: true);
    _write('$routePath/app_router.dart', '// App routing setup');
  }

  /// Generates a Dart class with API endpoint constants.
  void _generateEndpoints(List<String> endpoints) {
    final networkPath = '$projectName/lib/core/network';
    Directory(networkPath).createSync(recursive: true);
    final buffer = StringBuffer()
      ..writeln("class Endpoints {")
      ..writeln(
          '  static const String baseUrl = "https://api.tfkcodes.dev";\n');

    for (var e in endpoints) {
      buffer.writeln('  static const String ${e.trim()} = "/${e.trim()}";');
    }

    buffer.writeln("}");

    _write("$networkPath/endpoints.dart", buffer.toString());
  }

  /// Generates request and response model classes for the given endpoint.
  void _generateRequestAndResponse(String endpoint) {
    final className = _capitalize(endpoint);
    final basePath = '$projectName/lib/core/network';
    final requestPath = '$basePath/requests/${endpoint}_request.dart';
    final responsePath = '$basePath/responses/${endpoint}_response.dart';

    Directory('$basePath/requests').createSync(recursive: true);
    Directory('$basePath/responses').createSync(recursive: true);

    final request = '''
class ${className}Request {
  final Map<String, dynamic> data;

  ${className}Request({required this.data});

  Map<String, dynamic> toJson() => data;
}
''';

    final response = '''
class ${className}Response {
  final dynamic data;

  ${className}Response(this.data);

  factory ${className}Response.fromJson(Map<String, dynamic> json) {
    return ${className}Response(json['data']);
  }
}
''';

    _write(requestPath, request);
    _write(responsePath, response);
  }

  /// Writes content to the specified [path] and prevents duplication.
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

  /// Extracts class name from class content string.
  String? _extractClassName(String content) {
    final regex = RegExp(r'class\s+(\w+)\s*[{|<]');
    final match = regex.firstMatch(content);
    return match?.group(1);
  }

  /// Capitalizes the first letter of a string.
  String _capitalize(String input) =>
      input.isEmpty ? '' : input[0].toUpperCase() + input.substring(1);
}
