import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_notes/widgets/about_app_widget.dart';
import 'package:flutter_notes/widgets/version_widget.dart';

import '../data/app_options.dart';
import '../data/firebase_service.dart';
import '../data/models/user_model.dart';
import '../extensions/locale_name.dart';
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

  Map<String, DisplayOption> _buildOptionsMap(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final supportedLocales = List<Locale>.from(AppLocalizations.supportedLocales)
      ..sort((a, b) {
        // Make the system locale be the first of all
        if (a.languageCode == deviceLocale!.languageCode) {
          return -1; // 'a' is system locale, order before 'b'
        } else if (b.languageCode == deviceLocale!.languageCode) {
          return 1; // 'b' is system locale, order before 'a'
        }
        return a.languageCode.compareTo(b.languageCode);
      });

    // We assume there is at least one supported locale
    return {
      supportedLocales.first.languageCode: DisplayOption(
        title: Text(localizations.settingsSystemDefault),
        subtitle: _createLocalizedText(context, deviceLocale),
      ),
      for (var i = 1; i < supportedLocales.length; i++)
        supportedLocales[i].languageCode: DisplayOption(
          title: _createLocalizedText(context, supportedLocales[i]),
          subtitle: Text(localizations.nameOf(supportedLocales[i].languageCode)!),
        )
    };
  }

  Localizations _createLocalizedText(BuildContext context, Locale? locale) {
    final languageCode = locale?.languageCode ?? 'und';
    return Localizations.override(
      context: context,
      locale: Locale(languageCode),
      child: Builder(
        // We need the parent build context
        builder: (context) {
          final localizations = AppLocalizations.of(context);
          return Text(localizations.nameOf(languageCode)!);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appSettings = AppOptions.of(context);

    return Scaffold(
      body: SettingRadioListItems<String>(
        selectedOption: appSettings.locale!.languageCode,
        optionsMap: _buildOptionsMap(context),
        onChanged: (value) {
          AppOptions.update(
            context,
            appSettings.copyWith(locale: Locale(value!)),
          );
        },
      ),
    );
  }
}

class ThemeModeSettingScreen extends StatelessWidget {
  const ThemeModeSettingScreen({Key? key}) : super(key: key);

  Map<ThemeMode, DisplayOption> _buildOptionsMap(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return {
      ThemeMode.system: DisplayOption(title: Text(localizations.settingsSystemDefault)),
      ThemeMode.dark: DisplayOption(title: Text(localizations.settingsDarkTheme)),
      ThemeMode.light: DisplayOption(title: Text(localizations.settingsLightTheme)),
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
