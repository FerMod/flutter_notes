// ignore: unused_import
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:flutter_notes/screens/notes_list.dart';

import 'data/app_options.dart';
import 'data/local/app_shared_preferences.dart';
import 'data/models.dart';
import 'globals.dart';
import 'model_binding.dart';
import 'routes.dart';
import 'screens/sign_in.dart';
import 'src/utils/locale_matching.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _initFirestore();
  await AppSharedPreferences.initialize();

  runApp(
    ModelBinding(
      initialModel: AppOptions.load(
        defaultSettings: AppOptions(
          themeMode: ThemeMode.system,
          textScaleFactor: systemTextScaleFactorOption,
          locale: systemLocaleOption,
          platform: defaultTargetPlatform,
        ),
      ),
      child: const NotesApp(),
    ),
  );
}

void _initFirestore() async {
  await Firebase.initializeApp();
  _initFirebaseFirestore();
  _initFirebaseAuth();
}

void _initFirebaseFirestore() {
  if (Global.useFirebaseFirestoreEmulator) {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android && !kIsWeb;

    // Switch host based on platform.
    final firebaseFirestoreHost = isAndroid ? '10.0.2.2:8080' : 'localhost:8080';

    try {
      FirebaseFirestore.instance.settings = Settings(
        host: firebaseFirestoreHost,
        sslEnabled: false,
        persistenceEnabled: Global.persistChanges,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      // When hot reloading 'FirebaseError: [code=failed-precondition]' is
      // launched. It happens when trying to set the Firebase settings more than
      // once.
      print(e.toString());
    }

    // Only for web platforms
    if (Global.persistChanges && kIsWeb) {
      FirebaseFirestore.instance.enablePersistence();
    }
  }
}

void _initFirebaseAuth() {
  if (Global.useFirebaseAuthEmulator) {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android && !kIsWeb;

    // Switch host based on platform.
    final firebaseAuthHost = isAndroid ? 'http://10.0.2.2:9099' : 'http://localhost:9099';

    try {
      FirebaseAuth.instance.useEmulator(firebaseAuthHost);
    } catch (e) {
      print(e.toString());
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
    var locale = deviceResolvedLocale;
    if (locales?.first != systemLocaleOption) {
      locale = LocaleMatcher.localeListResolution(
        locales,
        supportedLocales,
      );
      deviceResolvedLocale = locale;
    }

    print(
      'Locale resolution:\n'
      '  Desired locales: $locales\n'
      '  Supported locales: $supportedLocales\n'
      '  Resolved locale: $locale\n'
      '  Device resolved locale: $deviceResolvedLocale',
    );
    return _localeResolution(locale, supportedLocales);
  }

  Locale? _localeResolution(Locale? locale, Iterable<Locale> supportedLocales) {
    final resolvedLocale = locale ?? deviceResolvedLocale;
    FirebaseAuth.instance.setLanguageCode(resolvedLocale.languageCode);
    return locale;
  }

  @override
  Widget build(BuildContext context) {
    final userData = DataProvider.userData;
    final userSignedIn = userData.currentUser != null;

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
      home: userSignedIn ? NotesListScreen() : SignInScreen(),
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
    );
  }
}
