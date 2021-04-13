import 'dart:convert';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;

import '../model_binding.dart';
import '../src/utils/locale_utils.dart';
import 'local/app_shared_preferences.dart';

/// The system-reported text scale.
///
/// This establishes the text scaling factor to use when rendering text,
/// according to the user's platform preferences.
double get deviceTextScaleFactor {
  return WidgetsFlutterBinding.ensureInitialized().platformDispatcher.textScaleFactor;
}

/// The system-reported default locale of the device.
///
/// This establishes the language and formatting conventions that application
/// should, if possible, use to render their user interface.
///
/// This is the first locale selected by the user and is the user's primary
/// locale (the locale the device UI is displayed in).
Locale get deviceLocale {
  return WidgetsFlutterBinding.ensureInitialized().platformDispatcher.locale;
}

/// The full system-reported supported locales of the device.
///
/// This establishes the language and formatting conventions that application
/// should, if possible, use to render their user interface.
List<Locale> get deviceLocales {
  return WidgetsFlutterBinding.ensureInitialized().platformDispatcher.locales;
}

List<Locale>? _lastDeviceLocales;

Locale? _deviceResolvedLocale;
Locale get deviceResolvedLocale => _deviceResolvedLocale ?? Locale.fromSubtags();
set deviceResolvedLocale(Locale locale) {
  final equalLocales = const ListEquality().equals(_lastDeviceLocales, deviceLocales);
  if (!equalLocales) {
    _deviceResolvedLocale = locale;
    _lastDeviceLocales = deviceLocales;
  }
}

// Fake locale to represent the system Locale option.
final systemLocaleOption = const Locale('system');

/// The settings of the app.
@immutable
class AppOptions {
  /// Creates the settings used in the app.
  const AppOptions({
    this.themeMode = ThemeMode.system,
    double? textScaleFactor,
    Locale? locale,
    this.platform,
  })  : _textScaleFactor = textScaleFactor,
        _locale = locale;

  /// Describes which theme will be used.
  final ThemeMode themeMode;

  /// The number of font pixels for each logical pixel.
  ///
  /// If the text scale factor is 1.5, text will be 50% larger than the
  /// specified font size.
  ///
  /// If no text scale is set or is not valid, returns the value selected in the
  /// device's system settings.
  ///
  /// See:
  ///
  /// * [isValidTextScale], to check if the text scale factor in the app
  ///   settings is considered as valid.
  double get textScaleFactor => isValidTextScale() ? _textScaleFactor! : deviceTextScaleFactor;
  final double? _textScaleFactor;

  /// The platform that user interaction should adapt to target.
  final TargetPlatform? platform;

  /// An identifier used to select a user's language and formatting preferences.
  ///
  /// If no locale is set or is not valid, returns the supported language
  /// selected in the device's system settings.
  ///
  /// See:
  ///
  /// * [isValidLocale], to check if the locale in the app settings is
  ///   considered as valid.
  Locale get locale => isValidLocale() ? _locale! : deviceResolvedLocale;
  final Locale? _locale;

  /// Returns true if the text scale stored in the app settings is considered
  /// valid.
  bool isValidTextScale() {
    return _textScaleFactor != null && _textScaleFactor! > 0.0;
  }

  /// Returns true if the locale that should be using is the one stored in these
  /// settings.
  bool isValidLocale() {
    return _locale != null && _locale != Locale.fromSubtags();
  }

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
        brightness = WidgetsBinding.instance!.window.platformBrightness;
    }

    return brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
  }

  /// Creates the settings used in the app from a Json string.
  factory AppOptions.fromJson(String str) => AppOptions.fromMap(json.decode(str));

  /// Creates the settings used in the app from a map.
  factory AppOptions.fromMap(Map<String, dynamic> map) {
    return AppOptions(
      themeMode: ThemeMode.values.firstWhere(
        (e) => describeEnum(e) == map['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      textScaleFactor: map['textScaleFactor'],
      locale: LocaleUtils.localeFromLanguageTag(map['locale']),
      platform: TargetPlatform.values.firstWhere(
        (e) => describeEnum(e) == map['platform'],
        orElse: () => defaultTargetPlatform,
      ),
    );
  }

  factory AppOptions.load({AppOptions defaultSettings = const AppOptions()}) {
    final prefs = AppSharedPreferences.instance!;
    final dataString = prefs.getString('settings');
    if (dataString?.isNotEmpty ?? false) {
      try {
        defaultSettings = AppOptions.fromJson(dataString!);
      } on FormatException catch (e) {
        developer.log('Could not load the stored settings.\n$e');
      }
    }
    return defaultSettings;
  }

  static void save(AppOptions settings) {
    final prefs = AppSharedPreferences.instance!;
    prefs.setString('settings', settings.toJson());
  }

  /// Creates a copy of this settings object with the given fields
  /// replaced with the new values.
  AppOptions copyWith({
    ThemeMode? themeMode,
    double? textScaleFactor,
    Locale? locale,
    TargetPlatform? platform,
  }) {
    return AppOptions(
      themeMode: themeMode ?? this.themeMode,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
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
  ///
  /// If [updateShouldNotify] is true, it will cause to rebuild the widget
  /// regardless of the current model being the same as the [newModel] one.
  static void update(BuildContext context, AppOptions model, {bool updateShouldNotify = false}) {
    final modelUpdated = ModelBinding.update<AppOptions>(
      context,
      model,
      updateShouldNotify: updateShouldNotify,
    );
    if (modelUpdated) AppOptions.save(model);
  }

  /// Update the [AppOptions] with the new given fields parameters, and notifies
  /// that the internal state of this object has changed.
  static void updateField(
    BuildContext context, {
    ThemeMode? themeMode,
    double? textScaleFactor,
    Locale? locale,
    TargetPlatform? platform,
  }) {
    final objectCopy = AppOptions.of(context).copyWith(
      themeMode: themeMode,
      textScaleFactor: textScaleFactor,
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
      'themeMode': describeEnum(themeMode),
      'textScaleFactor': textScaleFactor,
      'locale': locale.toLanguageTag(),
      'platform': describeEnum(platform!),
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
    return appOptions.themeMode == themeMode && appOptions.textScaleFactor == textScaleFactor && appOptions.platform == platform && appOptions.locale == locale;
  }

  @override
  int get hashCode => hashValues(
        themeMode,
        textScaleFactor,
        locale,
        platform,
      );

  @override
  String toString() => 'AppOptions(themeMode: $themeMode, textScaleFactor: $textScaleFactor, locale: $locale, platform: $platform)';
}
