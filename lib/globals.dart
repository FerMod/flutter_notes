import 'package:flutter/foundation.dart' show immutable;

@immutable
class Global {
  /// This class is not meant to be instantiated or extended.
  /// This constructor prevents instantiation and extension.
  const Global._();

  /// Sets the URL strategy of the web app to use paths instead of a leading
  /// hash.
  static const bool usePathUrlStrategy = true;

  /// A constant that configures the use of the firebase firestore emulator.
  static const bool useFirebaseFirestoreEmulator = false;

  /// A constant that configures the use of the firebase auth emulator.
  static const bool useFirebaseAuthEmulator = false;

  /// A constant that configures if the made changes should persist.
  static const bool persistChanges = true;
}
