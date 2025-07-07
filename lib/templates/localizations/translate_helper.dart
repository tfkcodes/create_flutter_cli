/// Returns a helper function for accessing translated text from anywhere in the app.
///
/// This helper wraps `AppLocalizations.of(context)?.translate(key)`
/// to make translation usage simpler and more concise.
///
/// Example usage:
/// ```dart
/// Text(translate(context, 'welcome'));
/// ```
String translateHelper(String projectName) => '''
import 'package:$projectName/lib/core/localization/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// A simple utility function to access localized strings in the app.
///
/// - [context]: The build context used to get the current locale.
/// - [key]: The translation key to look up from the language JSON file.
///
/// Returns the translated string if found; otherwise returns the key itself.
String translate(BuildContext context, String key) {
  return AppLocalizations.of(context)?.translate(key) ?? key;
}
''';
