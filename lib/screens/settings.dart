import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:flutter_notes/src/utils/locale_utils.dart';
import 'package:flutter_notes/widgets/about_app_widget.dart';
import 'package:flutter_notes/widgets/version_widget.dart';

import '../data/app_options.dart';
import '../data/firebase_service.dart';
import '../data/models/user_model.dart';
import '../routes.dart';
import '../widgets/setting_widget.dart';
import '../widgets/user_account.dart';
import 'sign_in.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _navigate(BuildContext context, Widget widget) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  void _navigateSetting(BuildContext context, Widget widget) {
    Navigator.of(context).push(
      SettingsRouteBuilder(builder: (context) => widget),
    );
  }

  Widget _buildAccountSettings(BuildContext context) {
    final userData = UserData<UserModel>(collection: 'users');
    final user = userData.currentUser;

    final isSignedIn = user != null;

    Widget iconWidget;
    Widget titleWidget;
    Widget? subtitleWidget;
    if (isSignedIn) {
      iconWidget = UserAvatar(
        imageUrl: user!.photoURL!,
        nameText: user.displayName,
      );
      titleWidget = Text(user.displayName!);
      subtitleWidget = Text(user.email!);
    } else {
      final localizations = AppLocalizations.of(context)!;
      iconWidget = const Icon(
        Icons.account_circle,
        size: UserAvatar.alternativeImageIconSize,
      );
      titleWidget = Text(localizations.settingsAccount);
    }

    return SettingListTile(
      icon: iconWidget,
      title: titleWidget,
      subtitle: subtitleWidget,
      onTap: () {
        if (isSignedIn) {
          _navigateSetting(context, AccountSettingScreen(userData: userData));
        } else {
          _navigate(context, SignInScreen());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

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
            _buildAccountSettings(context),
            const Divider(),
            SettingsHeader(
              title: Text(localizations.settingsAplicationHeader),
            ),
            SettingListTile(
              icon: const Icon(Icons.translate),
              title: Text(localizations.settingsLanguage),
              onTap: () {
                _navigateSetting(context, LocalizationSettingScreen());
              },
            ),
            SettingListTile(
              icon: const Icon(Icons.palette),
              title: Text(localizations.settingsTheme),
              onTap: () {
                _navigateSetting(context, ThemeModeSettingScreen());
              },
            ),
            SettingListTile(
              icon: const Icon(Icons.format_size),
              title: Text(localizations.settingsTextScale),
              onTap: () {
                _navigateSetting(context, TextScaleSettingScreen());
              },
            ),
            const Divider(),
            const AboutAppWidget(),
            const VersionWidget(),
            const Placeholder(fallbackHeight: 900),
          ],
        ),
      ),
    );
  }
}

class AccountSettingScreen extends StatelessWidget {
  const AccountSettingScreen({
    Key? key,
    this.userData,
    this.onTap,
    this.onTapImage,
  }) : super(key: key);

  final UserData<UserModel>? userData;

  final VoidCallback? onTap;
  final VoidCallback? onTapImage;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = userData!.currentUser!;

    Widget picture = UserAvatar(
      imageUrl: user.photoURL!,
      nameText: user.displayName,
    );
    Widget name = Text(user.displayName!);
    Widget email = Text(user.email!);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settingsAccount)),
      body: Scrollbar(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
              currentAccountPicture: picture,
              accountName: name,
              accountEmail: email,
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: Text(localizations.signOut),
              onTap: () {
                userData!.signOut();
                // TODO: Improve route navigation
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoute.notes,
                  ModalRoute.withName('/'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LocalizationSettingScreen extends StatelessWidget {
  const LocalizationSettingScreen({
    Key? key,
  }) : super(key: key);

  String _capitalize(String value) {
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  Map<String, DisplayOption> _buildOptionsMap(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final localeNames = LocaleNames.of(context)!;
    final nativeLocaleNames = LocaleNamesLocalizationsDelegate.nativeLocaleNames;

    final supportedLocales = List<Locale>.from(AppLocalizations.supportedLocales)
      ..sort((a, b) {
        // Make the system locale be the first of all
        if (a.languageCode == deviceLocale.languageCode) {
          return -1; // 'a' is system locale, order before 'b'
        } else if (b.languageCode == deviceLocale.languageCode) {
          return 1; // 'b' is system locale, order before 'a'
        }
        return a.toLanguageTag().compareTo(b.toLanguageTag());
      });

    // We assume there is at least one supported locale
    return {
      supportedLocales.first.languageCode: DisplayOption(
        title: localizations.settingsSystemDefault,
        subtitle: _capitalize(nativeLocaleNames[deviceLocale.toString()]!),
      ),
      for (var i = 1; i < supportedLocales.length; i++)
        supportedLocales[i].languageCode: DisplayOption(
          title: _capitalize(nativeLocaleNames[supportedLocales[i].toString()]!),
          subtitle: _capitalize(localeNames.nameOf(supportedLocales[i].toString())!),
        )
    };
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appSettings = AppOptions.of(context);

    final localeSettingList = SettingRadioListItems<String>(
      selectedOption: appSettings.locale.languageCode,
      optionsMap: _buildOptionsMap(context),
      onChanged: (value) {
        AppOptions.update(
          context,
          appSettings.copyWith(locale: LocaleUtils.localeFromLanguageTag(value)),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsLanguage),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SettingSearch<String>(settingList: localeSettingList),
              );
            },
          ),
        ],
      ),
      body: localeSettingList,
    );
  }
}

class ThemeModeSettingScreen extends StatelessWidget {
  const ThemeModeSettingScreen({Key? key}) : super(key: key);

  Map<ThemeMode, DisplayOption> _buildOptionsMap(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return {
      ThemeMode.system: DisplayOption(title: localizations.settingsSystemDefault),
      ThemeMode.dark: DisplayOption(title: localizations.settingsDarkTheme),
      ThemeMode.light: DisplayOption(title: localizations.settingsLightTheme),
    };
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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

class TextScaleSettingScreen extends StatelessWidget {
  const TextScaleSettingScreen({Key? key}) : super(key: key);

  Map<double, DisplayOption> _buildOptionsMap(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return {
      -1.0: DisplayOption(
        title: localizations.settingsSystemDefault,
        titleBuilder: (context, value) {
          return Text(value, textScaleFactor: deviceTextScaleFactor);
        },
      ),
      0.8: DisplayOption(
        title: localizations.settingsTextScaleSmall,
        titleBuilder: (context, value) {
          return Text(value, textScaleFactor: 0.8);
        },
      ),
      1.0: DisplayOption(
        title: localizations.settingsTextScaleNormal,
        titleBuilder: (context, value) {
          return Text(value, textScaleFactor: 1.0);
        },
      ),
      1.5: DisplayOption(
        title: localizations.settingsTextScaleLarge,
        titleBuilder: (context, value) {
          return Text(value, textScaleFactor: 1.5);
        },
      ),
      1.8: DisplayOption(
        title: localizations.settingsTextScaleHuge,
        titleBuilder: (context, value) {
          return Text(value, textScaleFactor: 1.8);
        },
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appSettings = AppOptions.of(context);
    final optionsMap = _buildOptionsMap(context);
    final selectedOption = appSettings.isCustomTextScale() ? appSettings.textScaleFactor : optionsMap.keys.first;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.settingsTextScale)),
      body: SettingRadioListItems<double>(
        selectedOption: selectedOption,
        optionsMap: optionsMap,
        onChanged: (value) {
          AppOptions.update(
            context,
            appSettings.copyWith(textScaleFactor: value),
            updateShouldNotify: true,
          );
        },
      ),
    );
  }
}

class SettingSearch<T> extends SearchDelegate<T?> {
  SettingSearch({
    required this.settingList,
  });

  final SettingRadioListItems<T> settingList;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return BackButton(
      onPressed: () {
        close(context, null);
      },
    );
  }

  Widget _performSearch(BuildContext context) {
    final filteredOptions = Map<T, DisplayOption>.from(settingList.optionsMap);
    if (query.isNotEmpty) {
      filteredOptions.removeWhere((key, value) {
        final regExp = RegExp('^$query', caseSensitive: false);

        final titleMatch = value.title.startsWith(regExp);
        final subtitleMatch = value.subtitle?.startsWith(regExp) ?? false;
        final isDeviceDefault = filteredOptions.keys.first == key;
        return !(titleMatch || subtitleMatch || isDeviceDefault);
      });
    }
    return SettingRadioListItems<T>(
      selectedOption: settingList.selectedOption,
      optionsMap: filteredOptions,
      onChanged: (value) {
        settingList.onChanged?.call(value);
        close(context, value);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _performSearch(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _performSearch(context);
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: searchFieldDecorationTheme ??
          InputDecorationTheme(
            hintStyle: searchFieldStyle ?? theme.inputDecorationTheme.hintStyle,
            border: InputBorder.none,
          ),
    );
  }
}
