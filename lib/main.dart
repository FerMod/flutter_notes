import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'data/app_options.dart';
import 'menu/rich_text_editor.dart';
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
            // home: Scaffold(
            //   appBar: AppBar(title: Text('Test')),
            //   body: RichTextEditor(onSubmitted: (value) => developer.log(value)),
            // ),
          );
        },
      ),
    );
  }
}
