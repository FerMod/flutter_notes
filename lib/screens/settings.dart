import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

import '../data/app_options.dart';
import '../data/data_provider.dart';
import '../data/firebase/firebase_service.dart';
import '../routes.dart';
import '../widgets/about_app_widget.dart';
import '../widgets/drawer_header.dart';
import '../widgets/search_screen.dart';
import '../widgets/setting_widget.dart';
import '../widgets/user_account_tile.dart';
import '../widgets/user_avatar.dart';
import '../widgets/version_widget.dart';

void _navigateSetting(BuildContext context, Widget widget) {
  Navigator.of(context).push(
    SettingsRouteBuilder(builder: (context) => widget),
  );
}

/// Creates an [IconButton], that on click navigates to the [SettingsScreen]
/// screen.
class SettingsScreenButton extends StatelessWidget {
  const SettingsScreenButton({super.key});

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
  const SettingsScreen({super.key});

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
          size: UserAvatar.defaultRadius * 2.0,
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

  Widget _buildAccountSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SettingsGroup(
      title: SettingsHeader(
        title: Text(localizations.settingsAccountHeader),
      ),
      children: [
        _buildAccountSettings(context),
        const Divider(),
      ],
    );
  }

  Widget _buildApplicationSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SettingsGroup(
      title: SettingsHeader(
        title: Text(localizations.settingsAplicationHeader),
      ),
      children: [
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
      ],
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
        trackVisibility: true,
        radius: Radius.zero,
        child: ListView(
          //padding: const EdgeInsets.all(8.0),
          children: [
            _buildAccountSection(context),
            _buildApplicationSection(context),
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
    super.key,
    required this.userData,
    this.onTap,
    this.onTapImage,
  });

  final UserData userData;

  final VoidCallback? onTap;
  final VoidCallback? onTapImage;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = userData.currentUser;

    final userName = user?.displayName ?? '';
    final userImage = user?.photoURL ?? '';
    final userEmail = user?.email ?? '';
    return Scaffold(
      appBar: AppBar(title: Text(localizations.settingsAccount)),
      body: Scrollbar(
        trackVisibility: true,
        radius: Radius.zero,
        child: ListView(
          children: [
            TitleDrawerHeader(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: UserAccountTile(
                image: UserAvatar(
                  imageUrl: userImage,
                  nameText: userName,
                ),
                title: Text(userName),
                subtitle: Text(userEmail),
                imageSize: const Size.square(72.0),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: Text(localizations.signOut),
              onTap: () async {
                await userData.signOut();
                if (!context.mounted) return;
                final navigator = Navigator.of(context);
                navigator.popUntil((route) => route.isFirst);
                await navigator.pushReplacementNamed(AppRoute.signIn);
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
    super.key,
  });

  @override
  State<LocalizationSettingScreen> createState() => _LocalizationSettingScreenState();
}

class _LocalizationSettingScreenState extends State<LocalizationSettingScreen> with WidgetsBindingObserver {
  static final nativeLocaleNames = LocaleNamesLocalizationsDelegate.nativeLocaleNames;

  /// A odered non-growable list of supported locales, created from the list of
  /// [AppLocalizations.supportedLocales].
  ///
  /// This list is intended to provide a list of locale always in the same
  /// order, independent of in which order the locales where added to the list.
  /// The locales are ordered in alphabetical descendant order using their
  /// Unicode BCP47 Locale Identifier defined in
  /// <https://www.unicode.org/reports/tr35/>.
  static final List<Locale> supportedLocales = _initSupportedLocales();
  static List<Locale> _initSupportedLocales() {
    return List<Locale>.of(
      AppLocalizations.supportedLocales,
      growable: false,
    )..sort((a, b) => a.toLanguageTag().compareTo(b.toLanguageTag()));
  }

  late Locale selectedOption;
  late Map<Locale, DisplayOption> optionsMap;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    setState(() {
      // Rebuild ourselves because device locale has changed.
    });
  }

  bool _hasSupportedLocale() {
    return deviceResolvedLocale != const Locale.fromSubtags();
  }

  String? _capitalize(String? value) {
    if (value?.isEmpty ?? true) return value;
    return '${value![0].toUpperCase()}${value.substring(1)}';
  }

  Map<Locale, DisplayOption> _buildOptionsMap(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final localeNames = LocaleNames.of(context)!;

    return {
      // The device might not have any supported locale.
      if (_hasSupportedLocale())
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

    // Build a map of the options of locales.
    optionsMap = _buildOptionsMap(context);

    // Use the locale saved in the settings if the device has resolved
    // succesfully a supported locale. Because, in case of the locale value
    // stored in settings, being the fake locale with the language tag "system",
    // it would select an invalid locale. In that case, don't select any option
    // by setting the selected option to a undefined locale (using the language
    // tag "und").
    selectedOption = _hasSupportedLocale() ? appSettings.locale : deviceResolvedLocale;

    return SearchScreen(
      delegate: SettingsSearchDelegate(
        title: Text(localizations.settingsLanguage),
        deviceDefault: optionsMap.keys.first,
        settingList: SettingRadioListItems<Locale>(
          selectedOption: selectedOption,
          optionsMap: optionsMap,
          onChanged: (value) {
            AppOptions.update(
              context,
              appSettings.copyWith(locale: value),
            );
          },
        ),
      ),
    );
  }
}

class ThemeModeSettingScreen extends StatelessWidget {
  const ThemeModeSettingScreen({super.key});

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
  const TextScaleSettingScreen({super.key});

  Map<double, DisplayOption> _buildOptionsMap(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return {
      systemTextScaleFactorOption: DisplayOption(
        title: localizations.settingsSystemDefault,
        titleBuilder: (context, value) => Text(
          value,
          textScaler: TextScaler.linear(deviceTextScaleFactor),
        ),
      ),
      0.8: DisplayOption(
        title: localizations.settingsTextScaleSmall,
        titleBuilder: (context, value) => Text(
          value,
          textScaler: const TextScaler.linear(0.8),
        ),
      ),
      1.0: DisplayOption(
        title: localizations.settingsTextScaleNormal,
        titleBuilder: (context, value) => Text(
          value,
          textScaler: const TextScaler.linear(1.0),
        ),
      ),
      1.5: DisplayOption(
        title: localizations.settingsTextScaleLarge,
        titleBuilder: (context, value) => Text(
          value,
          textScaler: const TextScaler.linear(1.5),
        ),
      ),
      1.8: DisplayOption(
        title: localizations.settingsTextScaleHuge,
        titleBuilder: (context, value) => Text(
          value,
          textScaler: const TextScaler.linear(1.8),
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appSettings = AppOptions.of(context);
    final optionsMap = _buildOptionsMap(context);
    final selectedOption = appSettings.isValidTextScale ? appSettings.textScaleFactor : optionsMap.keys.first;
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

class SettingsSearchDelegate<T> extends SearchScreenDelegate<T> {
  SettingsSearchDelegate({
    super.title,
    this.deviceDefault,
    required this.settingList,
  });

  final T? deviceDefault;
  final SettingRadioListItems<T> settingList;

  Map<T, DisplayOption> _filterMap(String query) {
    if (query.isEmpty) return settingList.optionsMap;

    final regExp = RegExp('^$query', caseSensitive: false);
    return Map<T, DisplayOption>.of(settingList.optionsMap)
      ..removeWhere((key, value) {
        final titleMatch = value.title.startsWith(regExp);
        final subtitleMatch = value.subtitle?.startsWith(regExp) ?? false;
        final isDeviceDefault = deviceDefault == key;
        return !titleMatch && !subtitleMatch && !isDeviceDefault;
      });
  }

  @override
  Widget buildResults(BuildContext context) {
    return SettingRadioListItems<T>(
      selectedOption: settingList.selectedOption,
      optionsMap: _filterMap(query),
      onChanged: settingList.onChanged,
    );
  }
}
