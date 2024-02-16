import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreferences {
  AppSharedPreferences._internal();
  static final AppSharedPreferences _instance = AppSharedPreferences._internal();

  /// The current [SharedPreferences] instance, if one has been created.
  ///
  /// Is safe to assume the value to be not `null`, if the function [initialize]
  /// is called at least once, otherwhise, this will return `null`.
  ///
  /// See also:
  ///
  ///  * [SharedPreferences], a class that provides persistent storage for
  ///    simple data.
  static SharedPreferences? get instance => _instance._sharedPreferences;
  SharedPreferences? _sharedPreferences;

  static Future<SharedPreferences> initialize() async {
    return _instance._sharedPreferences ??= await SharedPreferences.getInstance();
  }

  /// Reads the value from persistent storage for the given [key], or `null` if
  /// [key] is not in the map.
  ///
  /// If the key is not present and [orDefault] is provided, returns the result
  /// value returned by [orDefault].
  static T? load<T extends Object?>(String key, {T? Function()? orDefault}) {
    if (instance!.containsKey(key)) {
      return instance!.get(key) as T?;
    }
    return orDefault?.call();
  }

  /// Stores to persistent storage the [key] with the given [value].
  ///
  /// Completes with a boolean once the operation finished. The boolean value
  /// indicates whethever the operation completed successfully or failed.
  static Future<bool> save<T extends Object>(String key, T value) async {
    if (value is bool) {
      return instance!.setBool(key, value);
    }
    if (value is int) {
      return instance!.setInt(key, value);
    }
    if (value is double) {
      return instance!.setDouble(key, value);
    }
    if (value is List<String>) {
      return instance!.setStringList(key, value);
    }

    return instance!.setString(key, value as String);
  }

  /// Removes from persistent storage the value associated with the [key].
  ///
  /// Completes with a boolean once the operation finished. The boolean value
  /// indicates whethever the operation completed successfully or failed.
  static Future<bool> remove(String key) async {
    return instance!.remove(key);
  }

  /// Removes all preferences from presistent storage. Ater this, the persistent
  /// storage is empty.
  ///
  /// Completes with a boolean once the operation finished. The boolean value
  /// indicates whethever the operation completed successfully or failed.
  static Future<bool> clear() async {
    return instance!.clear();
  }
}
