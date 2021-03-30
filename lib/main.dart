import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

import 'data/app_options.dart';
import 'data/local/app_shared_preferences.dart';
import 'globals.dart';
import 'model_binding.dart';
import 'routes.dart';
import 'screens/sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  _initFirebase();
  await AppSharedPreferences.initialize();
  runApp(const NotesApp());
}

void _initFirebase() {
  if (Global.useFirebaseEmulator) {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    // Switch host based on platform.
    final firestoreHost = isAndroid ? '10.0.2.2:8080' : 'localhost:8080';

    FirebaseFirestore.instance.settings = Settings(
      host: firestoreHost,
      sslEnabled: false,
      persistenceEnabled: Global.persistChanges,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Only for web platforms
    if (Global.persistChanges && kIsWeb) {
      FirebaseFirestore.instance.enablePersistence();
    }
  }
}

class NotesApp extends StatelessWidget {
  const NotesApp({
    Key? key,
    this.initialRoute,
  }) : super(key: key);

  final String? initialRoute;

  /// TODO: Resolve locale using [Unicode TR35](https://unicode.org/reports/tr35/#LanguageMatching)
  /// language matching
  Locale? _localeListResolution(List<Locale>? locales, Iterable<Locale> supportedLocales) {
    final supportedLocalesMap = Map<String?, Locale>.fromIterable(
      supportedLocales,
      key: (e) => e.languageCode,
    );
    final locale = locales!.firstWhere(
      (e) => supportedLocalesMap[e.languageCode] != null,
      orElse: () => supportedLocales.first,
    );
    developer.log('Desired locales: $locales\n'
        'Supported locales: $supportedLocales\n'
        'Resolved locale: $locale');
    return _localeResolution(locale, supportedLocales);
  }

  Locale? _localeResolution(Locale? locale, Iterable<Locale> supportedLocales) {
    deviceLocale = locale;
    if (deviceLocale != null) {
      FirebaseAuth.instance.setLanguageCode(locale?.languageCode ?? deviceLocale!.languageCode);
    }
    return locale;
  }

  @override
  Widget build(BuildContext context) {
    return ModelBinding(
      initialModel: AppOptions.load(
        defaultSettings: AppOptions(
          themeMode: ThemeMode.system,
          locale: null,
          platform: defaultTargetPlatform,
        ),
      ),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
            localizationsDelegates: [
              LocaleNamesLocalizationsDelegate(),
              ...AppLocalizations.localizationsDelegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: AppOptions.of(context).locale,
            localeListResolutionCallback: _localeListResolution,
            localeResolutionCallback: _localeResolution,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: AppOptions.of(context).themeMode,
            home: SignInScreen(), // TODO: Only for testing, change to real home
            routes: AppRoute.routes,
            // home: Scaffold(
            //   appBar: AppBar(title: Text('Test')),
            //   body: RichTextEditor(onSubmitted: (value) => developer.log(value)),
            // ),
            //initialRoute: AppRoute.home.location,
            //onGenerateRoute: AppRoute.onGenerateRoute,
          );
        },
      ),
    );
  }
}
