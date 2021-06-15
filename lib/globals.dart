import 'package:flutter/foundation.dart';

class Global {
  Global._internal();
  static final Global _instance = Global._internal();
  factory Global() => _instance;

  /// Sets the URL strategy of the web app to use paths instead of a leading
  /// hash.
  static const bool usePathUrlStrategy = false;

  /// A constant that is true if the application was compiled in debug mode.
  static const bool isDebugMode = kDebugMode;

  /// A constant that is true if the application was compiled in release mode.
  static const bool isReleaseMode = kReleaseMode;

  /// A constant that represents if should use the firebase firestore emulator.
  static const bool useFirebaseFirestoreEmulator = false;

  /// A constant that represents if should use the firebase auth emulator.
  static const bool useFirebaseAuthEmulator = false;

  /// A constant that represents if should persist the made changes.
  static const bool persistChanges = false;

  /// A constant that represents if should use local storage.
  static const bool localStorage = true;
}
