import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'data/app_options.dart';
import 'globals.dart';
import 'model_binding.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _initFirebase();
  runApp(const NotesApp());
}

Future<void> _initFirebase() async {
  await Firebase.initializeApp();

  if (Global.useFirebaseEmulator) {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;

    // Switch host based on platform.
    final firestoreHost = isAndroid ? '10.0.2.2:8080' : 'localhost:8080';
    FirebaseFirestore.instance.settings = Settings(
      host: firestoreHost,
      sslEnabled: false,
      persistenceEnabled: false,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Only for web
    // await FirebaseFirestore.instance.enablePersistence();
  }
}

class NotesApp extends StatefulWidget {
  const NotesApp({
    Key key,
  }) : super(key: key);

  @override
  _NotesAppState createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  Locale _localeListResolution(List<Locale> locales, Iterable<Locale> supportedLocales) {
    final supportedLocalesMap = Map<String, Locale>.fromIterable(
      supportedLocales,
      key: (e) => e.languageCode,
    );
    final locale = locales.firstWhere(
      (e) => supportedLocalesMap[e.languageCode] != null,
      orElse: () => supportedLocales?.first,
    );
    developer.log('Desired locales: $locales\n'
        'Supported locales: $supportedLocales\n'
        'Resolved locale: $locale');
    return _localeResolution(locale, supportedLocales);
  }

  Locale _localeResolution(Locale locale, Iterable<Locale> supportedLocales) {
    deviceLocale = locale;
    FirebaseAuth.instance.setLanguageCode(locale?.languageCode);
    return locale;
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
        builder: (context) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: AppOptions.of(context).locale,
            localeListResolutionCallback: _localeListResolution,
            localeResolutionCallback: _localeResolution,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: AppOptions.of(context).themeMode,
            home: HomePage(),
          );
        },
      ),
    );
  }
}
