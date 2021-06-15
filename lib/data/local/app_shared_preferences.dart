import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreferences {
  const AppSharedPreferences._internal();
  static final AppSharedPreferences _instance = AppSharedPreferences._internal();
  factory AppSharedPreferences() => _instance;

  static SharedPreferences? _sharedPreferences;
  static SharedPreferences? get instance => _sharedPreferences;

  static Future<SharedPreferences> initialize() async {
    return _sharedPreferences ??= await SharedPreferences.getInstance();
  }

  static T? load<T>(String key, {T Function()? orDefault}) {
    print('AppSharedPreferences.load(key: $key)');
    if (_sharedPreferences!.containsKey(key)) {
      return _sharedPreferences!.get(key) as T?;
    }
    return orDefault?.call();
  }

  static Future<bool> save<T>(String key, T content) {
    print('AppSharedPreferences.save(key: $key, value: $content)');

    if (content is bool) {
      return _sharedPreferences!.setBool(key, content);
    }
    if (content is int) {
      return _sharedPreferences!.setInt(key, content);
    }
    if (content is double) {
      return _sharedPreferences!.setDouble(key, content);
    }
    if (content is List<String>) {
      return _sharedPreferences!.setStringList(key, content);
    }

    return _sharedPreferences!.setString(key, content.toString());
  }
}
