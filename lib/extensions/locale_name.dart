import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension AppLocalizationsExtension on AppLocalizations? {
  String? nameOf(String? locale) {
    switch (locale) {
      case 'en':
        return this?.en;
      case 'es':
        return this?.es;
      case 'und':
        return this?.und;
      default:
        return null;
    }
  }
}
