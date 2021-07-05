import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:flutter_notes/routes.dart';
import 'package:flutter_notes/widgets/about_app_widget.dart';
import 'package:flutter_notes/widgets/version_widget.dart';

import '../data/app_options.dart';
import '../data/firebase_service.dart';
import '../data/models.dart';
import '../data/models/user_model.dart';
import '../widgets/search_screen.dart';
import '../widgets/setting_widget.dart';
import '../widgets/user_account.dart';

void _navigateSetting(BuildContext context, Widget widget) {
  Navigator.of(context).push(
    SettingsRouteBuilder(builder: (context) => widget),
  );
}

/// Creates an [IconButton], that on click navigates to the [SettingsScreen]
/// screen.
class SettingsScreenButton extends StatelessWidget {
  const SettingsScreenButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return IconButton(
      icon: const Icon(Icons.settings),
      tooltip: localizations.settingsButtonLabel,
      onPressed: () {
        Navigator.of(context).pushNamed(AppRoute.settings);
      },
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _navigate(BuildContext context, String routeName) {
    // Pop the settings screen and navigate to the new route
    Navigator.of(context)
      ..pop()
      ..pushReplacementNamed(routeName);
  }

  Widget _buildAccountSettings(BuildContext context) {
    final userData = DataProvider.userData;

    Widget iconWidget;
    Widget titleWidget;
    Widget? subtitleWidget;
    if (userData.isSignedIn && !userData.currentUser!.isAnonymous) {
      final user = userData.currentUser;

      iconWidget = UserAvatar(
        imageUrl: user!.photoURL,
        nameText: user.displayName,
      );
      titleWidget = Text(user.displayName ?? '');
      subtitleWidget = Text(user.email ?? '');
    } else {
      final localizations = AppLocalizations.of(context)!;
      iconWidget = const FittedBox(
        fit: BoxFit.contain,
        child: Icon(
          Icons.account_circle,
          size: UserAvatar.alternativeImageIconSize,
        ),
      );
      titleWidget = Text(localizations.signInTo(localizations.appName));
      subtitleWidget = Text(localizations.settingsSignInInfo);
    }

    return SettingListTile(
      icon: iconWidget,
      title: titleWidget,
      subtitle: subtitleWidget,
      onTap: () {
        if (userData.isSignedIn && !userData.currentUser!.isAnonymous) {
          _navigateSetting(context, AccountSettingScreen(userData: userData));
        } else {
          _navigate(context, AppRoute.signIn);
        }
      },
    );
  }

  List<Widget> _buildAccountSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return [
      SettingsHeader(
        title: Text(localizations.settingsAccountHeader),
      ),
      _buildAccountSettings(context),
      const Divider(),
    ];
  }

  List<Widget> _buildApplicationSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return [
      SettingsHeader(
        title: Text(localizations.settingsAplicationHeader),
      ),
      SettingListTile(
        icon: const Icon(Icons.translate),
        title: Text(localizations.settingsLanguage),
        onTap: () {
          _navigateSetting(context, const LocalizationSettingScreen());
        },
      ),
      SettingListTile(
        icon: const Icon(Icons.palette),
        title: Text(localizations.settingsTheme),
        onTap: () {
          _navigateSetting(context, const ThemeModeSettingScreen());
        },
      ),
      SettingListTile(
        icon: const Icon(Icons.format_size),
        title: Text(localizations.settingsTextScale),
        onTap: () {
          _navigateSetting(context, const TextScaleSettingScreen());
        },
      ),
      const Divider(),
    ];
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
            ..._buildAccountSection(context),
            ..._buildApplicationSection(context),
            const AboutAppWidget(),
            const VersionWidget(),
            // const Placeholder(fallbackHeight: 900),
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
    final userData = DataProvider.userData;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settingsAccount)),
      body: Scrollbar(
        child: ListView(
          children: [
            // TODO: Improve user data obtention
            FutureBuilder<UserModel?>(
              future: userData.data(),
              builder: (context, snapshot) {
                final user = userData.currentUser;

                final userName = snapshot.data?.name ?? user?.displayName ?? '';
                final userImage = snapshot.data?.image ?? user?.photoURL ?? user?.photoURL;
                final userEmail = user?.email ?? '';

                return UserAccountsDrawerHeader(
                  margin: EdgeInsets.zero,
                  currentAccountPicture: UserAvatar(
                    imageUrl: userImage,
                    nameText: userName,
                  ),
                  accountName: Text(userName),
                  accountEmail: Text(userEmail),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: Text(localizations.signOut),
              onTap: () async {
                await userData.signOut();
                // TODO: Improve route navigation
                // Navigator.of(context).popUntil((route) => route.isFirst);
                // await Navigator.of(context).popAndPushNamed('/');
                await Navigator.of(context).pushNamedAndRemoveUntil(AppRoute.signIn, ModalRoute.withName('/'));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LocalizationSettingScreen extends StatefulWidget {
  const LocalizationSettingScreen({
    Key? key,
  }) : super(key: key);

  @override
  _LocalizationSettingScreenState createState() => _LocalizationSettingScreenState();
}

class _LocalizationSettingScreenState extends State<LocalizationSettingScreen> with WidgetsBindingObserver {
  final nativeLocaleNames = LocaleNamesLocalizationsDelegate.nativeLocaleNames;

  late Locale selectedOption;
  late Map<Locale, DisplayOption> optionsMap;
  late List<Locale> supportedLocales;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    supportedLocales = List<Locale>.from(AppLocalizations.supportedLocales);
    supportedLocales.sort((a, b) => a.toLanguageTag().compareTo(b.toLanguageTag()));
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  bool _isSupportedLocale() {
    return deviceResolvedLocale != const Locale.fromSubtags();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    if (selectedOption != systemLocaleOption && optionsMap.containsKey(systemLocaleOption)) {
      final subtitle = _capitalize(nativeLocaleNames[deviceResolvedLocale.toString()]);
      final systemOption = optionsMap[systemLocaleOption]!.copyWith(subtitle: subtitle);
      setState(() {
        optionsMap[systemLocaleOption] = systemOption;
      });
    }
  }

  String? _capitalize(String? value) {
    if (value?.isEmpty ?? true) return value;
    return '${value![0].toUpperCase()}${value.substring(1)}';
  }

  Map<Locale, DisplayOption> _buildOptionsMap(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final localeNames = LocaleNames.of(context)!;

    // We assume there is at least one supported locale.
    return {
      if (_isSupportedLocale())
        systemLocaleOption: DisplayOption(
          title: localizations.settingsSystemDefault,
          subtitle: _capitalize(nativeLocaleNames[deviceResolvedLocale.toString()]),
        ),
      for (var i = 0; i < supportedLocales.length; i++)
        supportedLocales[i]: DisplayOption(
          title: _capitalize(nativeLocaleNames[supportedLocales[i].toString()])!,
          subtitle: _capitalize(localeNames.nameOf(supportedLocales[i].toString())),
        )
    };
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appSettings = AppOptions.of(context);

    optionsMap = _buildOptionsMap(context);
    selectedOption = _isSupportedLocale() ? appSettings.locale : deviceResolvedLocale;
    final localeSettingList = SettingRadioListItems<Locale>(
      selectedOption: selectedOption,
      optionsMap: optionsMap,
      onChanged: (value) {
        AppOptions.update(
          context,
          appSettings.copyWith(locale: value),
        );
      },
    );
    return SearchScreen(
      delegate: SettingsSearchDelegate<Locale>(
        title: Text(localizations.settingsLanguage),
        deviceDefault: optionsMap.keys.first,
        settingList: localeSettingList,
      ),
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
      systemTextScaleFactorOption: DisplayOption(
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
    final selectedOption = appSettings.isValidTextScale() ? appSettings.textScaleFactor : optionsMap.keys.first;
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

class SettingsSearchDelegate<T> extends SearchScreenDelegate<T?> {
  SettingsSearchDelegate({
    Widget? title,
    this.deviceDefault,
    required this.settingList,
  }) : super(title: title);

  final T? deviceDefault;
  final SettingRadioListItems<T> settingList;

  @override
  Widget buildResults(BuildContext context) {
    final filteredOptions = Map<T, DisplayOption>.from(settingList.optionsMap);
    if (query.isNotEmpty) {
      filteredOptions.removeWhere((key, value) {
        final regExp = RegExp('^$query', caseSensitive: false);

        final titleMatch = value.title.startsWith(regExp);
        final subtitleMatch = value.subtitle?.startsWith(regExp) ?? false;
        final isDeviceDefault = deviceDefault == key;
        return !titleMatch && !subtitleMatch && !isDeviceDefault;
      });
    }
    return SettingRadioListItems<T>(
      selectedOption: settingList.selectedOption,
      optionsMap: filteredOptions,
      onChanged: settingList.onChanged,
    );
  }
}
