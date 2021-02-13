import 'dart:convert';

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

  /// Creates the settings used in the app from a Json string .
  factory AppOptions.fromJson(String str) => AppOptions.fromMap(json.decode(str));

  /// Creates the settings used in the app from a map.
  factory AppOptions.fromMap(Map<String, dynamic> map) {
    return AppOptions(
      themeMode: map['themeMode'],
      locale: map['locale'],
      platform: map['platform'],
    );
  }

  /// Describes which theme will be used.
  final ThemeMode themeMode;

  /// The platform that user interaction should adapt to target.
  final TargetPlatform platform;

  /// An identifier used to select a user's language and formatting preferences.
  Locale get locale => _locale ?? deviceLocale;
  final Locale _locale;

  /// Returns a [SystemUiOverlayStyle] based on the [ThemeMode] setting.
  /// If the theme is dark, returns light; if the theme is light, returns dark.
  @Deprecated('Not used anywhere in the code. Already exists \'ThemeMode.system\'')
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

  /// Returns the [AppOptions] object for the widget tree that corresponds to
  /// the given `context`.
  ///
  /// Returns null if no object exists within the given `context`.
  static AppOptions of(BuildContext context) {
    return ModelBinding.of<AppOptions>(context);
  }

  /// Update the [AppOptions] with the new given [model] parameter, and notifies
  /// that the internal state of this object has changed.
  static void update(BuildContext context, AppOptions model) {
    ModelBinding.update<AppOptions>(context, model);
  }

  /// Update the [AppOptions] with the new given fields parameters, and notifies
  /// that the internal state of this object has changed.
  static void updateField(
    BuildContext context, {
    ThemeMode themeMode,
    Locale locale,
    TargetPlatform platform,
  }) {
    final objectCopy = AppOptions.of(context).copyWith(
      themeMode: themeMode,
      locale: locale,
      platform: platform,
    );
    AppOptions.update(context, objectCopy);
  }

  /// Returns a Json string of this class.
  String toJson() => json.encode(toMap());

  /// Converts this class to a [Map].
  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode,
      'locale': locale,
      'platform': platform,
    };
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
  String toString() => 'AppOptions(themeMode: $themeMode, locale: $_locale, platform: $platform)';
}
