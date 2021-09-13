import 'package:universal_platform/universal_platform.dart';

/// Helper class to perform platform detection and obtain the platform on which
/// the current code executing.
///
/// This class is not platform dependant and it can be used in any platform
/// without throwing any exceptions.
///
/// For example:
///
/// ```dart
/// if(DeviceType.isAndroid) {
///   // Do something
/// }
/// ```
abstract class DeviceType {
  // Proxy the UniversalPlatform methods so we can reference a single API.
  static bool get isAndroid => UniversalPlatform.isAndroid;
  static bool get isFuchsia => UniversalPlatform.isFuchsia;
  static bool get isIOS => UniversalPlatform.isIOS;
  static bool get isLinux => UniversalPlatform.isLinux;
  static bool get isMacOS => UniversalPlatform.isMacOS;
  static bool get isWindows => UniversalPlatform.isWindows;
  static bool get isWeb => UniversalPlatform.isWeb;

  // Higher level device class abstractions.
  static bool get isDesktop => isWindows || isMacOS || isLinux;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktopOrWeb => isDesktop || isWeb;
  static bool get isMobileOrWeb => isMobile || isWeb;
}
