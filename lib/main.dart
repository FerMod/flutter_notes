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
import 'src/utils/locale_matching.dart';

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

  Locale? _localeListResolution(List<Locale>? locales, Iterable<Locale> supportedLocales) {
    final locale = LocaleMatcher.localeListResolution(
      locales,
      supportedLocales,
      fallback: () => locales?.first == systemLocaleOption ? deviceResolvedLocale : null,
    );
    deviceResolvedLocale = locale;

    developer.log(
      'Desired locales: $locales\n'
      'Supported locales: $supportedLocales\n'
      'Resolved locale: $locale\n'
      'Device resolved locale: $deviceResolvedLocale',
    );
    developer.log('deviceResolvedLocale: $deviceResolvedLocale\n');
    return _localeResolution(locale, supportedLocales);
  }

  Locale? _localeResolution(Locale? locale, Iterable<Locale> supportedLocales) {
    final resolvedLocale = locale ?? deviceResolvedLocale;
    FirebaseAuth.instance.setLanguageCode(resolvedLocale.languageCode);
    return locale;
  }

  @override
  Widget build(BuildContext context) {
    return ModelBinding(
      initialModel: AppOptions.load(
        defaultSettings: AppOptions(
          themeMode: ThemeMode.system,
          textScaleFactor: deviceTextScaleFactor,
          locale: systemLocaleOption,
          platform: defaultTargetPlatform,
        ),
      ),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
            localizationsDelegates: const [
              ...AppLocalizations.localizationsDelegates,
              LocaleNamesLocalizationsDelegate(),
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
            builder: (context, child) {
              assert(child != null); // Child should not be null

              final appSettings = AppOptions.of(context);

              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: appSettings.textScaleFactor,
                ),
                child: child!,
              );
            },
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
