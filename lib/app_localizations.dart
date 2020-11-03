import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:intl/intl.dart';

import 'l10n/messages_all.dart';

class AppLocalizations {
  AppLocalizations(this.localeName);

  final String localeName;

  static Future<AppLocalizations> load(Locale locale) {
    assert(locale != null);

    // final name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    // final name = locale.toLanguageTag();
    final name = (locale.countryCode?.isEmpty ?? true) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      return AppLocalizations(localeName);
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  String get appTitle => Intl.message(
        'Quiz App',
        name: 'appTitle',
        desc: 'Title of the app',
        locale: localeName,
      );

  String get drawerTitle => Intl.message(
        'Menu',
        name: 'drawerTitle',
        desc: 'Title for the drawer widget',
        locale: localeName,
      );

  String get homepage => Intl.message(
        'Homepage',
        name: 'homepage',
        desc: 'Title for the Demo application',
        locale: localeName,
      );

  String get language => Intl.message(
        'Language:',
        name: 'language',
        desc: 'Text for language dropdown button',
        locale: localeName,
      );

  String get quizzes => quiz(2);

  String quiz(int howMany) => Intl.plural(
        howMany,
        one: 'Quiz',
        other: 'Quizzes',
        name: 'quiz',
        args: [howMany],
        desc: 'Quiz text',
        locale: localeName,
      );

  String get questions => question(2);

  String question(int howMany) => Intl.plural(
        howMany,
        one: 'Question',
        other: 'Questions',
        name: 'question',
        args: [howMany],
        desc: 'Question text',
        locale: localeName,
      );

  String get startQuiz => Intl.message(
        'Start Quiz!',
        name: 'startQuiz',
        desc: 'Start quiz button text',
        locale: localeName,
      );

  String get goodJob => Intl.message(
        'Good Job!',
        name: 'goodJob',
        desc: 'Good job text',
        locale: localeName,
      );

  String get wrong => Intl.message(
        'Wrong',
        name: 'wrong',
        desc: 'Wrong text',
        locale: localeName,
      );

  String get onward => Intl.message(
        'Onward!',
        name: 'onward',
        desc: 'Continue onward button text',
        locale: localeName,
      );

  String get tryAgain => Intl.message(
        'Try again...',
        name: 'tryAgain',
        desc: 'Try again button text',
        locale: localeName,
        meaning: "The meaning of try again"
      );

  String congratsQuiz(String quizName) => Intl.message(
        'Congrats! You completed "$quizName"!',
        name: 'congratsQuiz',
        args: [quizName],
        examples: const {'quizName': 'Quiz'},
        desc: 'Quiz congratulation message',
        locale: localeName,
      );
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
