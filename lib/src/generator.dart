import 'dart:io';

/// Configuration object for the Flutter CLI generator.
///
/// This holds user-selected options such as:
/// - State management type (e.g., provider, bloc, getx, riverpod)
/// - Whether to include theme setup
/// - Network type (REST or GraphQL)
/// - Whether to include routing
/// - Whether to generate a default folder structure
/// - List of REST API endpoints
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

  Generator(this.config);

  /// Entry point for generating project structure, state management,
  /// themes, network layer, and routing based on the config.
  void generate() {
    if (config.structure) _generateStructure();
    if (config.state != null) _generateStateManagement(config.state!);
    if (config.theme) _generateTheme();
    if (config.network != null) _generateNetworking(config.network!);
    if (config.routing) _generateRouting();
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
      Directory(dir).createSync(recursive: true);
      print('Created :$dir');
    }
  }

  /// Creates setup files for the selected state management approach.
  void _generateStateManagement(String type) {
    switch (type.toLowerCase()) {
      case 'provider':
        _write('lib/core/state/provider.dart', '// Provider setup');
        break;
      case 'bloc':
        _write('lib/core/state/bloc.dart', '// BLoC setup');
        break;
      case 'getx':
        _write('lib/core/state/getx.dart', '// GetX setup');
        break;
      case 'riverpod':
        _write('lib/core/state/riverpod.dart', '// Riverpod setup');
        break;
      default:
        print('Unsupported state management: $type');
    }
  }

  /// Generates files for light and dark theme support.
  void _generateTheme() {
    _write('lib/config/themes/light_theme.dart', '// Light theme');
    _write('lib/config/themes/dark_theme.dart', '// Dark theme');
    _write('lib/config/themes/theme_provider.dart', '// Theme provider');
  }

  /// Generates network layer files depending on whether REST or GraphQL is selected.
  void _generateNetworking(String type) {
    switch (type.toLowerCase()) {
      case 'rest':
        _write('lib/core/network/api_client.dart', '// REST client');
        _write(
          'lib/core/network/response_handler.dart',
          _responseHandlerStub(),
        );
        _write(
          'lib/core/network/error_mapper.dart',
          _errorMapperStub(),
        );

        if (config.apis.isNotEmpty) {
          _generateEndpoints(config.apis);
          for (var api in config.apis) {
            _generateRequestAndResponse(api);
          }
        }
        break;

      case 'graphql':
        _write('lib/core/network/graphql_client.dart', '// GraphQL client');
        // You can extend this section to generate queries/mutations later
        break;

      default:
        print('Unsupported network type: $type');
    }
  }

  /// Generates basic app router file.
  void _generateRouting() {
    _write('lib/config/routes/app_router.dart', '// App routing setup');
  }

  /// Generates a Dart class with API endpoint constants.
  void _generateEndpoints(List<String> endpoints) {
    final buffer = StringBuffer()
      ..writeln("class Endpoints {")
      ..writeln(
          '  static const String baseUrl = "https://api.tfkcodes.dev";\n');

    for (var e in endpoints) {
      buffer.writeln('  static const String ${e.trim()} = "/${e.trim()}";');
    }

    buffer.writeln("}");

    _write("lib/core/network/endpoints.dart", buffer.toString());
  }

  /// Generates request and response model classes for the given endpoint.
  void _generateRequestAndResponse(String endpoint) {
    final className = _capitalize(endpoint);

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

    _write('lib/core/network/requests/${endpoint}_request.dart', request);
    _write('lib/core/network/responses/${endpoint}_response.dart', response);
  }

  /// Returns a stub for error mapping logic.
  String _errorMapperStub() => '''
class ErrorMapper {
  static String getErrorMessage(dynamic error) {
    if (error.toString().contains("TimeoutException")) return "Request timed out.";
    if (error.toString().contains("SocketException")) return "No internet connection.";
    return "Something went wrong. Please try again.";
  }
}
''';

  /// Returns a stub for handling API response parsing.
  String _responseHandlerStub() => '''
class ResponseHandler {
  static T handle<T>(Map<String, dynamic> responseJson, T Function(Map<String, dynamic>) fromJson) {
    if (responseJson.containsKey('error')) {
      throw Exception(responseJson['error']);
    }
    return fromJson(responseJson);
  }
}
''';

  /// Writes content to the specified [path] and creates the file if it doesn't exist.
  void _write(String path, String content) {
    final file = File(path);
    file.createSync(recursive: true);
    file.writeAsStringSync(content);
    print('Created :$path');
  }

  /// Capitalizes the first letter of a given [input] string.
  String _capitalize(String input) =>
      input.isEmpty ? '' : input[0].toUpperCase() + input.substring(1);
}
