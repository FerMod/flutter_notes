import 'package:flutter/foundation.dart';

class Global {
  Global._internal();
  static final Global _instance = Global._internal();

  factory Global() {
    return _instance;
  }

  /// A constant that is true if the application was compiled in debug mode.
  static final bool isDebugMode = kDebugMode;

  /// A constant that represents if should use the firebase emulator.
  static final bool useFirebaseEmulator = true;
}
