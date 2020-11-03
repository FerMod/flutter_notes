import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'data/app_options.dart';
import 'model_binding.dart';
import 'screens/home_page.dart';

void main() => runApp(NotesApp());

class NotesApp extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return ModelBinding(
      initialModel: AppOptions(
        themeMode: ThemeMode.system,
        locale: null,
        platform: defaultTargetPlatform,
      ),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: AppOptions.of(context).locale,
            localeResolutionCallback: (locale, supportedLocales) {
              deviceLocale = locale;
              return locale;
            },
            themeMode: AppOptions.of(context).themeMode,
            darkTheme: ThemeData.dark(),
            home: HomePage(),
          );
        },
      ),
    );
  }
}

/*
class QuizApp2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QuizAppState();

  /*
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ModelBinding(
      initialModel: AppOptions(
        themeMode: ThemeMode.system,
        locale: null,
        platform: defaultTargetPlatform,
      ),
      child: Builder(
        builder: (context) => MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: AppOptions.of(context).locale,
            localeResolutionCallback: (locale, supportedLocales) {
              deviceLocale = locale;
              return locale;
            },
            themeMode: AppOptions.of(context).themeMode,
            darkTheme: ThemeData.dark(),
              home: HomePage(),
          ),
      ),
    );
  }
  */
}

class _QuizApp2State extends State<QuizApp2> {
  final _routerDelegate = BookRouterDelegate();
  final _routeInformationParser = BookRouteInformationParser();

  @deprecated
  MaterialApp _buildMaterialApp(BuildContext context, bool useRouter) {
    if (useRouter) {
      return MaterialApp.router(
        routerDelegate: _routerDelegate,
        routeInformationParser: _routeInformationParser,
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: AppOptions.of(context).locale,
        localeResolutionCallback: (locale, supportedLocales) {
          deviceLocale = locale;
          return locale;
        },
        themeMode: AppOptions.of(context).themeMode,
        darkTheme: ThemeData.dark(),
      );
    }

    return MaterialApp(
      // MaterialApp.router(
      // routerDelegate: _routerDelegate,
      // routeInformationParser: _routeInformationParser,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: AppOptions.of(context).locale,
      localeResolutionCallback: (locale, supportedLocales) {
        deviceLocale = locale;
        return locale;
      },
      themeMode: AppOptions.of(context).themeMode,
      darkTheme: ThemeData.dark(),
      home: HomePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModelBinding(
      initialModel: AppOptions(
        themeMode: ThemeMode.system,
        locale: null,
        platform: defaultTargetPlatform,
      ),
      child: Builder(
        builder: (context) => _buildMaterialApp(context, false),
      ),
    );
  }
}
*/
