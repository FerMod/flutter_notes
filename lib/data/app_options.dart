import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;

import '../model_binding.dart';

Locale _deviceLocale;
Locale get deviceLocale => _deviceLocale;
set deviceLocale(Locale locale) => _deviceLocale ??= locale;

/// The settings of the app.
@immutable
class AppOptions {
  /// Creates the settings used in the app.
  const AppOptions({
    this.themeMode,
    Locale locale,
    this.platform,
  }) : _locale = locale;

  final ThemeMode themeMode;
  final TargetPlatform platform;
  final Locale _locale;

  Locale get locale => _locale ?? deviceLocale;

  SystemUiOverlayStyle resolvedSystemUiOverlayStyle() {
    Brightness brightness;
    switch (themeMode) {
      case ThemeMode.light:
        brightness = Brightness.light;
        break;
      case ThemeMode.dark:
        brightness = Brightness.dark;
        break;
      default:
        brightness = WidgetsBinding.instance.window.platformBrightness;
    }

    return brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
  }

  /// Creates a copy of this settings object with the given fields
  /// replaced with the new values.
  AppOptions copyWith({
    ThemeMode themeMode,
    Locale locale,
    TargetPlatform platform,
  }) {
    return AppOptions(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      platform: platform ?? this.platform,
    );
  }

  static AppOptions of(BuildContext context) {
    return ModelBinding.of<AppOptions>(context);
  }

  static void update(BuildContext context, AppOptions newModel) {
    ModelBinding.update<AppOptions>(context, newModel);
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    final AppOptions appOptions = other;
    return appOptions.themeMode == themeMode && appOptions.platform == platform && appOptions.locale == locale;
  }

  @override
  int get hashCode => hashValues(
        themeMode,
        locale,
        platform,
      );

  @override
  String toString() => '${objectRuntimeType(this, 'AppOptions')}($themeMode, $locale, $platform)';
}
