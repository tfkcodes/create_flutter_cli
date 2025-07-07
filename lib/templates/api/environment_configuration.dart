/// Enum representing the available application environments.
///
/// - [test] Used during local development or automated testing.
/// - [staging] Used for pre-production or QA testing.
/// - [production] Used in the live, public-facing version of the app.
///
String environmentConfiguration() => '''
enum Environment {
  test,
  production,
  staging,
}

class AppConfig {
  final Environment env;

  const AppConfig({this.env = Environment.test});

  String get baseUrl {
    switch (env) {
      case Environment.test:
        return "api.tfkcodes.com/test"; // Used for local testing
      case Environment.staging:
        return "api.tfkcodes.com/staging"; // Used for staging/QA
      case Environment.production:
        return "api.tfkcodes.com"; // Live production environment
    }
  }
}

''';
