import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreferences {
  const AppSharedPreferences._internal();
  static const AppSharedPreferences _instance = AppSharedPreferences._internal();
  factory AppSharedPreferences() => _instance;

  static SharedPreferences? _sharedPreferences;
  static SharedPreferences? get instance => _sharedPreferences;

  static Future<SharedPreferences> initialize() async {
    return _sharedPreferences ??= await SharedPreferences.getInstance();
  }

  /// Reads the value from persistent storage for the given [key], or `null` if
  /// [key] is not in the map.
  ///
  /// If the key is not present and [orDefault] is provided, returns the result
  /// value returned by [orDefault].
  static T? load<T extends Object?>(String key, {T? Function()? orDefault}) {
    print('AppSharedPreferences.load(key: $key)');
    if (_sharedPreferences!.containsKey(key)) {
      return _sharedPreferences!.get(key) as T?;
    }
    return orDefault?.call();
  }

  /// Stores to persistent storage the [key] with the given [value].
  ///
  /// Completes with a boolean once the operation finished. The boolean value
  /// indicates whethever the operation completed successfully or failed.
  static Future<bool> save<T extends Object?>(String key, T content) async {
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

  /// Removes from persistent storage the value associated with the [key].
  ///
  /// Completes with a boolean once the operation finished. The boolean value
  /// indicates whethever the operation completed successfully or failed.
  static Future<bool> remove(String key) async {
    print('AppSharedPreferences.remove(key: $key)');
    return _sharedPreferences!.remove(key);
  }

  /// Removes all preferences from presistent storage. Ater this, the persistent
  /// storage is empty.
  ///
  /// Completes with a boolean once the operation finished. The boolean value
  /// indicates whethever the operation completed successfully or failed.
  static Future<bool> clear() async {
    print('AppSharedPreferences.clear()');
    return _sharedPreferences!.clear();
  }
}
