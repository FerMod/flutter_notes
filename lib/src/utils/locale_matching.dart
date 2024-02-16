import 'dart:ui';

import 'package:collection/collection.dart';
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
    // If the fallback function is defined, use it. If the returned value by the
    // fallback function is not null return that value. Otherwise, return the
    // first locale in the supported list. If that value is also null then
    // return the default resolved value.
    //
    // The returned values could be the one given by the fallback funtion, or
    // it could be "und", or the first value of the supported locales.
    return _resolveLocale(
      desiredLocales,
      supportedLocales,
      fallback: fallback ?? () => supportedLocales.firstOrNull,
    );
  }

  /// This algorithm will resolve to the earliest preferred locale that
  /// matches the most fields, prioritizing in the order of perfect match:
  /// language_script_country > language_country > language_script > language
  ///
  /// When a desired locale matches more than one supported locale, it will
  /// resolve to the first matching locale listed in the [supportedLocales].
  ///
  /// When no match at all is found, the `und` locale will be returned. If the
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
  ///    the value fallback locale. Otherwise, returns `und` locale as a
  ///    fallback.
  ///
  /// This algorithm does not take language distance (how similar languages are
  /// to each other) into account.
  static Locale localeLookup(Locale? desiredLocale, Iterable<Locale> supportedLocales, {FallbackLocale? fallback}) {
    return _resolveLocale(
      [if (desiredLocale != null) desiredLocale],
      supportedLocales,
      fallback: fallback,
    );
  }

  static Locale _resolveLocale(List<Locale>? desiredLocales, Iterable<Locale> supportedLocales, {FallbackLocale? fallback}) {
    final locale = _localeResolution(desiredLocales, supportedLocales);
    if (locale != const Locale.fromSubtags()) {
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
  /// When no match at all is found, the `und` locale will be returned.
  ///
  /// To summarize, the main matching priority is:
  ///
  /// 1. [Locale.languageCode], [Locale.scriptCode], and [Locale.countryCode].
  /// 1. [Locale.languageCode] and [Locale.countryCode] only.
  /// 1. [Locale.languageCode] and [Locale.scriptCode] only.
  /// 1. [Locale.languageCode] only.
  /// 1. Returns a `und` locale as a fallback.
  ///
  /// This algorithm does not take language distance (how similar languages are
  /// to each other) into account.
  static Locale _localeResolution(List<Locale>? desiredLocales, Iterable<Locale> supportedLocales) {
    var bestSupported = const Locale.fromSubtags();
    if (desiredLocales?.isEmpty ?? true) return bestSupported;

    var bestWeightedDistance = double.infinity;

    for (var i = 0; i < desiredLocales!.length; i++) {
      final desired = desiredLocales[i];
      for (final supported in supportedLocales) {
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
            // Language and country code match, and they are not null
            matchDistance = 0.5;
          } else if (supported.scriptCode != null && supported.scriptCode == desired.scriptCode) {
            // Language and script code match, and they are not null
            matchDistance = 0.75;
          }

          // The more we go down the list the less the weight is
          final weightedDistance = i + matchDistance;
          if (kDebugMode) debugPrint('$i $desired $supported, WeightedDistance: $weightedDistance, BestWeightedDistance $bestWeightedDistance');
          if (bestWeightedDistance == 0.0) {
            // Cannot improve, is a perfect match and the best without a doubt
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
