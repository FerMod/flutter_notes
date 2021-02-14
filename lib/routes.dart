import 'package:flutter/material.dart';

import 'screens/home_page.dart';
import 'screens/notes_list.dart';
import 'screens/settings.dart';
import 'screens/sign_in.dart';
import 'screens/sign_up.dart';

// ignore: avoid_classes_with_only_static_members
class AppRoute {
  static const String notes = '/notes';
  static const String settings = '/settings';
  static const String signIn = '/signIn';
  static const String signUp = '/signUp';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    notes: (context) => NotesListScreen(),
    settings: (context) => const SettingsScreen(),
    signIn: (context) => const SignInScreen(),
    signUp: (context) => const SignUpScreen(),
    home: (context) => HomePage(),
  };
}
