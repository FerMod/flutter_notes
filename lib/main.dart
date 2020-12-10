import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'data/app_options.dart';
import 'globals.dart';
import 'model_binding.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  _initFirebaseEmulator(Global.useFirebaseEmulator);
  runApp(NotesApp());
}

void _initFirebaseEmulator(bool useEmulators) async {
  if (!useEmulators) return;

  final isAndroid = defaultTargetPlatform == TargetPlatform.android;

  // Switch host based on platform.
  final firestoreHost = isAndroid ? '10.0.2.2:8080' : 'localhost:8080';
  FirebaseFirestore.instance.settings = Settings(host: firestoreHost, sslEnabled: false, persistenceEnabled: false);

  // await FirebaseAuth.instance.setPersistence(Persistence.NONE);
  // final authHost = isAndroid ? '10.0.2.2:9099' : 'localhost:9099';
  // FirebaseAuth.instance.useEmulator(authHost);
}

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
            // home: Scaffold(
            //   appBar: AppBar(title: Text('Test')),
            //   body: RichTextEditor(onSubmitted: (value) => developer.log(value)),
            // ),
            // routes: <String, WidgetBuilder>{
            //   '/notes': (context) => NotesListScreen(),
            // },
          );
        },
      ),
    );
  }
}
