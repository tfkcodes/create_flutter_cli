import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

Future<void> updatePubspecYaml(String projectName,
    {bool useProvider = false,
    bool useHttp = false,
    bool useIntl = false}) async {
  final pubspecPath = '$projectName/pubspec.yaml';
  final file = File(pubspecPath);

  if (!file.existsSync()) {
    print('❌ pubspec.yaml not found at $pubspecPath');
    exit(1);
  }

  final content = await file.readAsString();
  final doc = loadYaml(content);
  final editor = YamlEditor(content);

  // ✅ Ensure environment SDK constraint
  if (doc['environment'] == null || doc['environment']['sdk'] == null) {
    editor.update(['environment'], {
      'sdk': '">=3.0.0 <4.0.0"',
    });
  }

  // ✅ Ensure flutter dependencies section
  if (doc['dependencies'] == null) {
    editor.update(['dependencies'], {
      'flutter': {'sdk': 'flutter'},
      'cupertino_icons': '^1.0.2',
    });
  } else {
    final deps = Map<String, dynamic>.from(doc['dependencies']);

    if (!deps.containsKey('flutter')) {
      editor.update(['dependencies', 'flutter'], {'sdk': 'flutter'});
    }

    if (!deps.containsKey('cupertino_icons')) {
      editor.update(['dependencies', 'cupertino_icons'], '^1.0.2');
    }

    if (useProvider && !deps.containsKey('provider')) {
      editor.update(['dependencies', 'provider'], '^6.1.1');
    }

    if (useHttp && !deps.containsKey('http')) {
      editor.update(['dependencies', 'http'], '^1.2.1');
    }

    if (useIntl && !deps.containsKey('intl')) {
      editor.update(['dependencies', 'intl'], '^0.18.1');
    }
  }

  // ✅ Ensure flutter > assets > - assets/lang/
  final flutterSection = doc['flutter'] as YamlMap?;
  List existingAssets = [];

  if (flutterSection != null && flutterSection.containsKey('assets')) {
    existingAssets = List.from(flutterSection['assets']);
  }

  if (!existingAssets.contains('assets/lang/')) {
    existingAssets.add('assets/lang/');
    editor.update(['flutter', 'assets'], existingAssets);
  }

  await file.writeAsString(editor.toString());
  print('✅ pubspec.yaml successfully updated.');
}
