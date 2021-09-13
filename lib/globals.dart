import 'package:flutter/foundation.dart' show immutable;

@immutable
class Global {
  /// This class is not meant to be instantiated or extended.
  /// This constructor prevents instantiation and extension.
  const Global._();

  /// A constant that sets the URL strategy of the web app to use paths instead
  /// of a leading hash.
  static const bool usePathUrlStrategy = false;

  /// A constant that configures the use of the Firebase Firestore emulator.
  static const bool useFirestoreEmulator = false;

  /// A constant that configures if the made changes while offline should
  /// persist.
  ///
  /// When reading and writing data, Firestore uses a local database which
  /// automatically synchronizes with the server. Cloud Firestore functionality
  /// continues offline, and automatically handles data synchronization when
  /// connectivity is regained.
  static const bool enableOfflineFirestore = true;

  /// A constant that configures the use of the Firebase Authentication
  /// emulator.
  static const bool useAuthEmulator = false;
}
