import 'dart:io';
import 'package:create_flutter_cli/src/generator.dart';

/// Generates the main.dart entry file based on the given [GeneratorConfig].
/// If localization is enabled, it generates a localized main file, otherwise a basic provider setup.
///
/// [config] – Configuration settings (e.g., localization, state management).
/// [projectName] – The name of the Flutter project.
/// [state] – Currently unused, but can be used for different state management strategies.
generateMainFile(GeneratorConfig config, String projectName, String state) {
  final mainPath = '$projectName/lib/main.dart';

  // Check if localization is enabled
  final hasLocalization =
      config.languages.isNotEmpty && config.defaultLanguage != null;

  // Choose content template based on localization flag
  final content = hasLocalization
      ? _localizedMainFile(
          projectName, config.defaultLanguage!, config.languages)
      : _basicProviderMainFile(projectName);

  // Write the content to file
  _write(mainPath, content);
}

/// Returns a basic `main.dart` with Provider setup (no localization).
String _basicProviderMainFile(String projectName) => '''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:$projectName/core/network/provider/example_provider.dart';
import 'package:$projectName/config/environment.dart';

void main() {
 WidgetsFlutterBinding.ensureInitialized();
  AppConfig();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Example: ChangeNotifierProvider(create: (_) => ExampleProvider()),
      ],
      child: MaterialApp(
        title: '$projectName',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: Scaffold(
          appBar: AppBar(title: Text('Provider Example')),
          body: Center(child: Text('Hello from Provider setup!')),
        ),
      ),
    );
  }
}
''';

/// Returns a `main.dart` with localization support and Provider integration.
///
/// [defaultLang] – The default language code (e.g., 'en').
/// [languages] – List of supported language codes.
String _localizedMainFile(
    String projectName, String defaultLang, List<String> languages) {
  final supportedLocales =
      languages.map((e) => "Locale('$e')").join(',\n          ');

  return '''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:$projectName/core/network/provider/example_provider.dart';
import 'package:$projectName/config/environment.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    AppConfig();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExampleProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '$projectName',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: Scaffold(
          appBar: AppBar(title: Text("Provider with Language")),
          body: Center(
            child: Text("Provider with Language"),
          ),
        ),
      ),
    );
  }
}
''';
}

/// Writes content to a file at the given [path].
///
/// If the file already contains the same content or the same class name, it will skip writing.
/// If [append] is true, it appends the content instead of overwriting.
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

/// Extracts the name of the first Dart class in the given [content].
///
/// Returns `null` if no class is found.
String? _extractClassName(String content) {
  final regex = RegExp(r'class\s+(\w+)\s*[{|<]');
  final match = regex.firstMatch(content);
  return match?.group(1);
}
