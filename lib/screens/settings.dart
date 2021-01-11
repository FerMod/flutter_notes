import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../data/app_options.dart';
import '../extensions/locale_name.dart';
import '../widgets/setting_widget.dart';

class Settings extends StatelessWidget {
  const Settings({Key key}) : super(key: key);

  void _navigate(BuildContext context, Widget widget) {
    Navigator.of(context).push(
      SettingsRouteBuilder(builder: (context) => widget),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsTitle),
      ),
      body: Scrollbar(
        child: ListView(
          //padding: const EdgeInsets.all(8.0),
          children: [
            SettingsHeader(
              title: Text(localizations.settingsAccountHeader),
            ),
            SettingListTile(
              icon: const Icon(Icons.person),
              title: Text(localizations.settingsAccount),
              onTap: () {}, //TODO: Add account settings.
            ),
            Divider(),
            SettingsHeader(
              title: Text(localizations.settingsAplicationHeader),
            ),
            SettingListTile(
              icon: const Icon(Icons.translate),
              title: Text(localizations.settingsLanguage),
              onTap: () {
                _navigate(context, LocalizationSettingScreen());
              },
            ),
            SettingListTile(
              icon: const Icon(Icons.palette),
              title: Text(localizations.settingsTheme),
              onTap: () {
                _navigate(context, ThemeModeSettingScreen());
              },
            ),
            Placeholder(fallbackHeight: 900),
          ],
        ),
      ),
    );
  }
}

class LocalizationSettingScreen extends StatelessWidget {
  const LocalizationSettingScreen({
    Key key,
  }) : super(key: key);

  Map<String, DisplayOption> _buildOptionsMap(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final supportedLocales = List<Locale>.from(AppLocalizations.supportedLocales);
    final systemLocale = supportedLocales.firstWhere((locale) => deviceLocale.languageCode == locale.languageCode);
    supportedLocales.sort((a, b) => a.languageCode.compareTo(b.languageCode));

    final localesMap = Map<String, DisplayOption>.fromIterable(
      supportedLocales,
      key: (locale) => locale.languageCode,
      value: (locale) => DisplayOption(
        title: _createLocalizedText(context, locale),
        subtitle: Text(localizations.nameOf(locale.languageCode)),
      ),
    );
    localesMap.remove(systemLocale.languageCode);
    return {
      systemLocale.languageCode: DisplayOption(
        title: Text(localizations.settingsSystemDefault),
        subtitle: _createLocalizedText(context, deviceLocale),
      ),
      ...localesMap,
    };
  }

  Localizations _createLocalizedText(BuildContext context, Locale locale) {
    final languageCode = locale?.languageCode ?? 'und';
    return Localizations.override(
      context: context,
      locale: Locale(languageCode),
      child: Builder(
        // We need the parent build context
        builder: (context) {
          final localizations = AppLocalizations.of(context);
          return Text(localizations.nameOf(languageCode));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final appSettings = AppOptions.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settingsLanguage)),
      body: SettingRadioListItems<String>(
        selectedOption: appSettings.locale.languageCode,
        optionsMap: _buildOptionsMap(context),
        onChanged: (value) {
          AppOptions.update(
            context,
            appSettings.copyWith(locale: Locale(value)),
          );
        },
      ),
    );
  }
}

class ThemeModeSettingScreen extends StatelessWidget {
  const ThemeModeSettingScreen({Key key}) : super(key: key);

  Map<ThemeMode, DisplayOption> _buildOptionsMap(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return {
      ThemeMode.system: DisplayOption(title: Text(localizations.settingsSystemDefault)),
      ThemeMode.dark: DisplayOption(title: Text(localizations.settingsDarkTheme)),
      ThemeMode.light: DisplayOption(title: Text(localizations.settingsLightTheme)),
    };
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final appSettings = AppOptions.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.settingsTheme)),
      body: SettingRadioListItems<ThemeMode>(
        selectedOption: appSettings.themeMode,
        optionsMap: _buildOptionsMap(context),
        onChanged: (value) {
          AppOptions.update(
            context,
            appSettings.copyWith(themeMode: value),
          );
        },
      ),
    );
  }
}

@deprecated
class ApplicationSettings extends StatelessWidget {
  const ApplicationSettings({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return SettingListTile(
      icon: const Icon(Icons.person),
      title: Text(localizations.settingsAccount),
      onTap: () {},
    );
  }
}

@deprecated
class LocalizationSettings extends StatelessWidget {
  const LocalizationSettings({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SettingListTile(
      icon: const Icon(Icons.language),
      title: Text(localizations.settingsLanguage),
      onTap: () {
        Navigator.of(context).push(
          SettingsRouteBuilder(
            builder: (context) => LocalizationSettingScreen(),
          ),
        );
      },
    );
  }
}
