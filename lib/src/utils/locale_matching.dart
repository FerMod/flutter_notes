import 'dart:ui';

import 'package:flutter/foundation.dart';

typedef FallbackLocale = Locale? Function();

/// Implementation for Locale matching and resolution.
class LocaleMatcher {
  /// This algorithm will resolve to the earliest preferred locale that
  /// matches the most fields, prioritizing in the order of perfect match:
  /// language_script_country > language_country > language_script > language
  ///
  /// When a desired locale matches more than one supported locale, it will
  /// resolve to the first matching locale listed in the [supportedLocales].
  ///
  /// When no match at all is found, the first (default) locale in
  /// [supportedLocales] will be returned. If the fallback locale is given with
  /// [fallback] and the returned value is not null, that locale will be used
  /// instead.
  ///
  /// To summarize, the main matching priority is:
  ///
  /// 1. [Locale.languageCode], [Locale.scriptCode], and [Locale.countryCode].
  /// 1. [Locale.languageCode] and [Locale.countryCode] only.
  /// 1. [Locale.languageCode] and [Locale.scriptCode] only.
  /// 1. [Locale.languageCode] only.
  /// 1. If [fallback] is defined and the value is not null returns that fallback
  ///    locale. Otherwise, returns the first element of [supportedLocales] as a
  ///    fallback.
  ///
  /// This algorithm does not take language distance (how similar languages are
  /// to each other) into account.
  static Locale localeListResolution(List<Locale>? desiredLocales, Iterable<Locale> supportedLocales, {FallbackLocale? fallback}) {
    var locale = _localeResolution(desiredLocales, supportedLocales);
    //final locale = basicLocaleListResolution(desiredLocales, supportedLocales);
    if (locale != Locale.fromSubtags()) {
      return locale;
    }

    // Set the first locale in the supported list as the resolved locale
    if (supportedLocales.isNotEmpty) {
      locale = supportedLocales.first;
    }

    // If is defined the fallback value, use it. If the returned value is
    // not null return that value, otherwise use the default fallback locale. It
    // could be "und", or the first value of the supported locales.
    return fallback?.call() ?? locale;
  }

  /// This algorithm will resolve to the earliest preferred locale that
  /// matches the most fields, prioritizing in the order of perfect match:
  /// language_script_country > language_country > language_script > language
  ///
  /// When a desired locale matches more than one supported locale, it will
  /// resolve to the first matching locale listed in the [supportedLocales].
  ///
  /// When no match at all is found, the "und" locale will be returned. If the
  /// fallback locale is given with [fallback] and the returned value is not
  /// null, that locale will used instead.
  ///
  /// To summarize, the main matching priority is:
  ///
  /// 1. [Locale.languageCode], [Locale.scriptCode], and [Locale.countryCode].
  /// 1. [Locale.languageCode] and [Locale.countryCode] only.
  /// 1. [Locale.languageCode] and [Locale.scriptCode] only.
  /// 1. [Locale.languageCode] only.
  /// 1. If [fallback] is defined and the returned value is not null returns
  ///    the value fallback locale. Otherwise, returns "und" locale as a fallback.
  ///
  /// This algorithm does not take language distance (how similar languages are
  /// to each other) into account.
  static Locale localeLookup(Locale desiredLocale, Iterable<Locale> supportedLocales, {FallbackLocale? fallback}) {
    final locale = _localeResolution([desiredLocale], supportedLocales);
    if (locale != Locale.fromSubtags()) {
      return locale;
    }

    // If is defined the fallback value, use it. If the returned value is
    // not null return that value, otherwise use the default fallback locale.
    return fallback?.call() ?? locale;
  }

  /// This algorithm will resolve to the earliest preferred locale that
  /// matches the most fields, prioritizing in the order of perfect match:
  /// language_script_country > language_country > language_script > language
  ///
  /// When a desired locale matches more than one supported locale, it will
  /// resolve to the first matching locale listed in the [supportedLocales].
  ///
  /// When no match at all is found, the "und" locale will be returned.
  ///
  /// To summarize, the main matching priority is:
  ///
  ///  1. [Locale.languageCode], [Locale.scriptCode], and [Locale.countryCode].
  ///  1. [Locale.languageCode] and [Locale.countryCode] only.
  ///  1. [Locale.languageCode] and [Locale.scriptCode] only.
  ///  1. [Locale.languageCode] only.
  ///  1. Returns a locale "und" as a fallback.
  ///
  /// This algorithm does not take language distance (how similar languages are
  /// to each other) into account.
  static Locale _localeResolution(List<Locale>? desiredLocales, Iterable<Locale> supportedLocales) {
    // Set best supported the first locale, if no desired locales are found that
    // should be used as the default one.
    // var bestSupported = supportedLocales.isNotEmpty ? supportedLocales.first : Locale.fromSubtags();
    var bestSupported = Locale.fromSubtags();
    if (desiredLocales?.isEmpty ?? true) return bestSupported;

    var bestWeightedDistance = double.infinity;

    for (var i = 0; i < desiredLocales!.length; i++) {
      final desired = desiredLocales[i];
      for (var supported in supportedLocales) {
        // Match priority (of desired):
        // language_script_country > language_country > language_script > language
        //
        // Distance values (lower better):
        // 0.0 > 0.5 > 0.75 > 1.0
        if (desired.languageCode != 'und' && supported.languageCode == desired.languageCode) {
          // The lower is the value, the better
          var matchDistance = 1.0;
          if (supported.countryCode == desired.countryCode && supported.scriptCode == desired.scriptCode) {
            // Full match, closest distance
            matchDistance = 0.0;
          } else if (supported.countryCode != null && supported.countryCode == desired.countryCode) {
            // Language and country code match and both are not null
            matchDistance = 0.5;
          } else if (supported.scriptCode != null && supported.scriptCode == desired.scriptCode) {
            // Language and country code match and both are not null
            matchDistance = 0.75;
          }

          // The more we go down the list the less the weight is
          final weightedDistance = i + matchDistance;
          if (kDebugMode) {
            print('$i $desired $supported, WeightedDistance: $weightedDistance, BestWeightedDistance $bestWeightedDistance');
          }
          if (bestWeightedDistance == 0.0) {
            // Cannot improve, is a perfect match, and the best without a doubt
            return bestSupported;
          } else if (weightedDistance < bestWeightedDistance) {
            bestWeightedDistance = weightedDistance;
            bestSupported = supported;
          }
        }
      }
    }
    return bestSupported;
  }

}
