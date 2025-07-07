/// Returns a Dart localization class and delegate setup to support multiple languages.
///
/// This class loads JSON-based language files from `assets/lang/` directory
/// and provides access to localized strings throughout the app.
///
/// Example usage:
/// ```dart
/// AppLocalizations.of(context)!.translate('hello');
/// ```
String appLocalization(List<String> lang) => '''

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// AppLocalizations handles the loading and lookup of localized strings.
///
/// It reads a JSON file (e.g., `en.json`, `sw.json`) from the assets folder
/// based on the selected [Locale] and maps string keys to translated values.
class AppLocalizations {
  /// The current locale of the app (e.g., `en`, `sw`).
  final Locale locale;

  /// Constructor accepting the target [locale].
  AppLocalizations(this.locale);

  /// Provides access to the current [AppLocalizations] instance.
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Internal map holding all localized strings loaded from JSON.
  late Map<String, String> _localizedStrings;

  /// Loads the language JSON file from the `assets/lang/` directory.
  ///
  /// Example: If the locale is `en`, it loads `assets/lang/en.json`.
  Future<bool> load() async {
    String jsonString =
        await rootBundle.loadString("assets/lang/\${locale.languageCode}.json");
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    // Convert all values to string and assign to _localizedStrings map.
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  /// Returns the localized value for the given key.
  ///
  /// If no translation exists for the key, it returns the key itself.
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  /// The delegate used to load localization data and manage supported languages.
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

/// A delegate responsible for loading [AppLocalizations] and
/// reporting supported locales to Flutter’s localization system.
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  /// Determines whether the app supports the given [locale].
  @override
  bool isSupported(Locale locale) {
    return [\${lang.map((e) => "'\$e'").join(', ')}].contains(locale.languageCode);
  }

  /// Loads the appropriate [AppLocalizations] instance for the given [locale].
  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  /// Indicates whether the delegate should reload if the old one changes.
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

''';
