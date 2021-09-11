import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:url_strategy/url_strategy.dart';

import 'data/app_options.dart';
import 'data/data_provider.dart';
import 'data/local/app_shared_preferences.dart';
import 'globals.dart';
import 'routes.dart';
import 'src/utils/device_type.dart';
import 'src/utils/locale_matching.dart';
import 'widgets/model_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  _initFirestore();
  await AppSharedPreferences.initialize();

  // Set the URL strategy for the web app
  Global.usePathUrlStrategy ? setPathUrlStrategy() : setHashUrlStrategy();

  runApp(
    ModelBinding(
      initialModel: AppOptions.load(),
      child: const NotesApp(),
    ),
  );
}

void _initFirestore() {
  _initFirebaseFirestore();
  _initFirebaseAuth();
}

void _initFirebaseFirestore() {
  if (Global.useFirebaseFirestoreEmulator) {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: Global.persistChanges,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Internally Android uses '10.0.2.2' as the host.
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080, sslEnabled: false);
    } catch (e) {
      // When hot reloading 'FirebaseError: [code=failed-precondition]' is
      // launched. It happens when trying to set the Firebase settings more than
      // once.
      developer.log(e.toString());
    }

    // Only for web platforms
    if (Global.persistChanges && DeviceType.isWeb) {
      FirebaseFirestore.instance.enablePersistence();
    }
  }
}

void _initFirebaseAuth() {
  if (Global.useFirebaseAuthEmulator) {
    try {
      // Firebase Auth emulator is not supported for web yet.
      // Internally Android uses '10.0.2.2' as the host.
      FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    } catch (e) {
      developer.log(e.toString());
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

    developer.log(
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
      initialRoute: userData.isSignedIn ? AppRoute.notes : AppRoute.signIn,
      onGenerateRoute: RouteConfiguration.onGenerateRoute,
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
