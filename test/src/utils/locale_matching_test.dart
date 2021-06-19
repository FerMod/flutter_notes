import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter_notes/src/utils/locale_matching.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocaleMatcher', () {
    test('resolve locales only with language code', () {
      Locale expectedLocale;
      Locale resolvedLocale;

      // Returns based on preference priority
      expectedLocale = Locale.fromSubtags(languageCode: 'es');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          Locale.fromSubtags(languageCode: 'es'),
          Locale.fromSubtags(languageCode: 'en'),
          Locale.fromSubtags(languageCode: 'fr'),
        ],
        [
          Locale.fromSubtags(languageCode: 'mk'),
          Locale.fromSubtags(languageCode: 'ja'),
          Locale.fromSubtags(languageCode: 'eu'),
          expectedLocale,
          Locale.fromSubtags(languageCode: 'en'),
        ],
      );
      expect(resolvedLocale.toLanguageTag(), expectedLocale.toLanguageTag());

      // Returns the closest match. Should prefer the the one without script code
      expectedLocale = Locale.fromSubtags(languageCode: 'en');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          Locale.fromSubtags(languageCode: 'en'),
          Locale.fromSubtags(languageCode: 'fr'),
          Locale.fromSubtags(languageCode: 'es'),
        ],
        [
          expectedLocale,
          Locale.fromSubtags(languageCode: 'ed'),
          Locale.fromSubtags(languageCode: 'ja'),
          Locale.fromSubtags(languageCode: 'eu'),
        ],
      );
      expect(resolvedLocale.toLanguageTag(), expectedLocale.toLanguageTag());
    });

    test('resolve locales with language and country code', () {
      Locale expectedLocale;
      Locale resolvedLocale;

      // Returns based on preference priority
      expectedLocale = Locale.fromSubtags(languageCode: 'es', countryCode: 'ES');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
          Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
        ],
        [
          Locale.fromSubtags(languageCode: 'mk'),
          Locale.fromSubtags(languageCode: 'ja', countryCode: 'PG'),
          Locale.fromSubtags(languageCode: 'eu', countryCode: 'ES'),
          expectedLocale,
          Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
        ],
      );
      expect(resolvedLocale.toLanguageTag(), expectedLocale.toLanguageTag());

      // Returns the closest match. Should prefer the the one without script code
      expectedLocale = Locale.fromSubtags(languageCode: 'en', countryCode: 'US');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
          Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
        ],
        [
          Locale.fromSubtags(languageCode: 'ed'),
          Locale.fromSubtags(languageCode: 'en', countryCode: 'US', scriptCode: 'script'),
          Locale.fromSubtags(languageCode: 'ja', countryCode: 'JP'),
          Locale.fromSubtags(languageCode: 'eu', countryCode: 'ES'),
          expectedLocale,
        ],
      );
      expect(resolvedLocale.toLanguageTag(), expectedLocale.toLanguageTag());

      // Should prefer the the one that matches also the country code
      expectedLocale = Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA'),
          Locale.fromSubtags(languageCode: 'es'),
          Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
        ],
        [
          Locale.fromSubtags(languageCode: 'es'),
          Locale.fromSubtags(languageCode: 'en', countryCode: 'US', scriptCode: 'script'),
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
          expectedLocale,
        ],
      );
      expect(resolvedLocale.toLanguageTag(), expectedLocale.toLanguageTag());

      // Return the closest match, ignoring the country code difference
      expectedLocale = Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
          Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
        ],
        [
          Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          expectedLocale,
        ],
      );
      expect(resolvedLocale.toLanguageTag(), expectedLocale.toLanguageTag());

      // Country code match but should return the full matching one
      expectedLocale = Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
          Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
        ],
        [
          Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA', scriptCode: 'scriptcode'),
          expectedLocale,
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'CC'),
        ],
      );
      expect(resolvedLocale.toLanguageTag(), expectedLocale.toLanguageTag());
    });

    test('resolve locale with language, country and script codes', () {
      Locale expectedLocale;
      Locale resolvedLocale;

      // No country neither script code match. Should return the one with
      // country and script code
      expectedLocale = Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA', scriptCode: 'scriptcode');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
          Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
        ],
        [
          Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          expectedLocale,
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'BE'),
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'CC'),
        ],
      );
      expect(resolvedLocale.toLanguageTag(), expectedLocale.toLanguageTag());

      // No country neither script code match. Should return the first with
      // script code
      expectedLocale = Locale.fromSubtags(languageCode: 'fr', countryCode: 'DD', scriptCode: 'expected');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
          Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
        ],
        [
          Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          expectedLocale,
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA', scriptCode: 'scriptcode'),
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'CC'),
        ],
      );
      expect(resolvedLocale.toLanguageTag(), expectedLocale.toLanguageTag());

      // No country code match, but script code matches. Should return the first with
      // the same language and script code
      expectedLocale = Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR', scriptCode: 'expected');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
        ],
        [
          Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA', scriptCode: 'scriptcode'),
          expectedLocale,
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'CC'),
        ],
      );
      expect(resolvedLocale.toLanguageTag(), expectedLocale.toLanguageTag());

      // No country code match, should return the first with the same language
      // and script code
      expectedLocale = Locale.fromSubtags(languageCode: 'fr', scriptCode: 'expected');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR', scriptCode: 'expected'),
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
        ],
        [
          Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA', scriptCode: 'scriptcode'),
          expectedLocale,
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'CC'),
        ],
      );
      expect(resolvedLocale.toLanguageTag(), expectedLocale.toLanguageTag());

      // Should return the first with the same codes
      expectedLocale = Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR', scriptCode: 'expected');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR', scriptCode: 'expected'),
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
        ],
        [
          Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA', scriptCode: 'scriptcode'),
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR', scriptCode: 'notexpected'),
          expectedLocale,
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'CC'),
        ],
      );
      expect(resolvedLocale.toLanguageTag(), expectedLocale.toLanguageTag());
    });

    test('returns the first supported locale if no match is found in desired locales', () {
      Locale expectedLocale;
      Locale resolvedLocale;

      expectedLocale = Locale.fromSubtags(languageCode: 'es', countryCode: 'ES');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
        ],
        [
          expectedLocale,
          Locale.fromSubtags(languageCode: 'eus', countryCode: 'ES'),
          Locale.fromSubtags(languageCode: 'pl', countryCode: 'PL'),
        ],
      );
      expect(resolvedLocale.toLanguageTag(), expectedLocale.toLanguageTag());

      expectedLocale = Locale.fromSubtags(languageCode: 'en', countryCode: 'US');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
          Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
        ],
        [
          expectedLocale,
          Locale.fromSubtags(languageCode: 'en', countryCode: 'UK'),
        ],
      );
      expect(resolvedLocale.toLanguageTag(), expectedLocale.toLanguageTag());
    });

    test('returns the fallback locale if no match is found in desired locales', () {
      Locale expectedLocale;
      Locale resolvedLocale;

      final desiredLocales = [
        Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
        Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
      ];

      expectedLocale = Locale.fromSubtags(languageCode: 'es', countryCode: 'ES');
      var supportedLocales = <Locale>[
        expectedLocale,
        Locale.fromSubtags(languageCode: 'eus', countryCode: 'ES'),
        Locale.fromSubtags(languageCode: 'pl', countryCode: 'PL'),
      ];

      resolvedLocale = LocaleMatcher.localeListResolution(
        desiredLocales,
        supportedLocales,
        fallback: () => supportedLocales.firstOrNull,
      );
      expect(resolvedLocale.toLanguageTag(), expectedLocale.toLanguageTag());

      expectedLocale = Locale.fromSubtags(languageCode: 'es', countryCode: 'EU');
      supportedLocales = [
        Locale.fromSubtags(languageCode: 'en', countryCode: 'UK'),
        expectedLocale,
      ];
      resolvedLocale = LocaleMatcher.localeListResolution(
        desiredLocales,
        supportedLocales,
      );
      expect(resolvedLocale.toLanguageTag(), expectedLocale.toLanguageTag());
    });

    test('returns "und" locale if supported and desired locales are not defined', () {
      Locale expectedLocale;
      Locale resolvedLocale;

      expectedLocale = Locale.fromSubtags();
      resolvedLocale = LocaleMatcher.localeListResolution(null, []);
      expect(resolvedLocale.toLanguageTag(), expectedLocale.toLanguageTag());

      expectedLocale = Locale.fromSubtags();
      resolvedLocale = LocaleMatcher.localeListResolution([], []);
      expect(resolvedLocale.toLanguageTag(), expectedLocale.toLanguageTag());
    });

    test('returns "und" locale if no supported locales are defined', () {
      Locale expectedLocale;
      Locale resolvedLocale;

      expectedLocale = Locale.fromSubtags();
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
          Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
        ],
        [],
      );
      expect(resolvedLocale.toLanguageTag(), expectedLocale.toLanguageTag());
    });
  });
}
