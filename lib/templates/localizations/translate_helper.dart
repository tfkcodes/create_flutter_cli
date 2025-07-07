String translateHelper(String projectName) => '''
import 'package:$projectName/lib/core/localization/app_localizations.dart';

String translate(BuildContext context, String key) {
  return AppLocalizations.of(context)?.translate(key) ?? key;
}
''';
