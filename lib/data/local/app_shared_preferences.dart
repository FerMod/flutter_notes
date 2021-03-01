import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreferences {
  AppSharedPreferences._internal();
  static final AppSharedPreferences _instance = AppSharedPreferences._internal();
  factory AppSharedPreferences() => _instance;

  static SharedPreferences _sharedPreferences;
  static SharedPreferences get instance => _sharedPreferences;

  static Future<SharedPreferences> initialize() async {
    return _sharedPreferences ??= await SharedPreferences.getInstance();
  }
}
