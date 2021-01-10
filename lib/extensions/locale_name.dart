import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension AppLocalizationsExtension on AppLocalizations {
  String nameOf(String locale) {
    switch (locale) {
      case 'en':
        return en;
      case 'es':
        return es;
      case 'und':
        return und;
      default:
        return null;
    }
  }
}
