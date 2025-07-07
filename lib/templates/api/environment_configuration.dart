String environmentConfiguration() => '''

enum Environment { test, production, staging }

class AppConfig {
  final Environment env;
  const AppConfig({this.env = Environment.test});

  String get baseUrl {
    switch (env) {
      case Environment.test:
        return "api.tfkcodes.com/test";
      case Environment.staging:
        return "api.tfkcodes.com/staging";
      case Environment.production:
        return "api.tfkcodes.com";
    }
  }
}

''';
