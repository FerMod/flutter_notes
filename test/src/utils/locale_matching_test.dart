import 'dart:ui';

import 'package:flutter_notes/src/utils/locale_matching.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocaleMatcher', () {
    test('resolve locales only with language code', () {
      Locale expectedLocale;
      Locale resolvedLocale;

      // Returns based on preference priority
      expectedLocale = const Locale.fromSubtags(languageCode: 'es');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          const Locale.fromSubtags(languageCode: 'es'),
          const Locale.fromSubtags(languageCode: 'en'),
          const Locale.fromSubtags(languageCode: 'fr'),
        ],
        [
          const Locale.fromSubtags(languageCode: 'en'),
          const Locale.fromSubtags(languageCode: 'fr'),
          const Locale.fromSubtags(languageCode: 'ja'),
          expectedLocale,
          const Locale.fromSubtags(languageCode: 'eu'),
        ],
      );
      expect(resolvedLocale, expectedLocale);

      // Returns the closest match
      expectedLocale = const Locale.fromSubtags(languageCode: 'en');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          const Locale.fromSubtags(languageCode: 'en'),
          const Locale.fromSubtags(languageCode: 'es'),
          const Locale.fromSubtags(languageCode: 'fr'),
        ],
        [
          expectedLocale,
          const Locale.fromSubtags(languageCode: 'fr'),
          const Locale.fromSubtags(languageCode: 'es'),
          const Locale.fromSubtags(languageCode: 'eu'),
        ],
      );
      expect(resolvedLocale, expectedLocale);
    });

    test('resolve locales with language and country code', () {
      Locale expectedLocale;
      Locale resolvedLocale;

      // Returns based on preference priority
      expectedLocale = const Locale.fromSubtags(languageCode: 'es', countryCode: 'ES');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          const Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
          const Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
        ],
        [
          const Locale.fromSubtags(languageCode: 'mk'),
          const Locale.fromSubtags(languageCode: 'ja', countryCode: 'PG'),
          const Locale.fromSubtags(languageCode: 'eu', countryCode: 'ES'),
          expectedLocale,
          const Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
        ],
      );
      expect(resolvedLocale, expectedLocale);

      // Returns the closest match. Should prefer the the one without script code
      expectedLocale = const Locale.fromSubtags(languageCode: 'en', countryCode: 'US');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          const Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
          const Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
        ],
        [
          const Locale.fromSubtags(languageCode: 'ed'),
          const Locale.fromSubtags(languageCode: 'en', countryCode: 'US', scriptCode: 'script'),
          const Locale.fromSubtags(languageCode: 'ja', countryCode: 'JP'),
          const Locale.fromSubtags(languageCode: 'eu', countryCode: 'ES'),
          expectedLocale,
        ],
      );
      expect(resolvedLocale, expectedLocale);

      // Should prefer the the one that matches also the country code
      expectedLocale = const Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA'),
          const Locale.fromSubtags(languageCode: 'es'),
          const Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
        ],
        [
          const Locale.fromSubtags(languageCode: 'es'),
          const Locale.fromSubtags(languageCode: 'en', countryCode: 'US', scriptCode: 'script'),
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
          expectedLocale,
        ],
      );
      expect(resolvedLocale, expectedLocale);

      // Return the closest match, ignoring the country code difference
      expectedLocale = const Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
          const Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
        ],
        [
          const Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          expectedLocale,
        ],
      );
      expect(resolvedLocale, expectedLocale);

      // Country code match but should return the full matching one
      expectedLocale = const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
          const Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
        ],
        [
          const Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA', scriptCode: 'scriptcode'),
          expectedLocale,
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'CC'),
        ],
      );
      expect(resolvedLocale, expectedLocale);
    });

    test('resolve locale with language, country and script codes', () {
      Locale expectedLocale;
      Locale resolvedLocale;

      // No country neither script code match. Should return the one with
      // country and script code
      expectedLocale = const Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA', scriptCode: 'scriptcode');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
          const Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
        ],
        [
          const Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          expectedLocale,
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'BE'),
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'CC'),
        ],
      );
      expect(resolvedLocale, expectedLocale);

      // No country neither script code match. Should return the first with
      // script code
      expectedLocale = const Locale.fromSubtags(languageCode: 'fr', countryCode: 'DD', scriptCode: 'expected');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
          const Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
        ],
        [
          const Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          expectedLocale,
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA', scriptCode: 'scriptcode'),
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'CC'),
        ],
      );
      expect(resolvedLocale, expectedLocale);

      // No country code match, but script code matches. Should return the first with
      // the same language and script code
      expectedLocale = const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR', scriptCode: 'expected');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          const Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
        ],
        [
          const Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA', scriptCode: 'scriptcode'),
          expectedLocale,
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'CC'),
        ],
      );
      expect(resolvedLocale, expectedLocale);

      // No country code match, should return the first with the same language
      // and script code
      expectedLocale = const Locale.fromSubtags(languageCode: 'fr', scriptCode: 'expected');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          const Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR', scriptCode: 'expected'),
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
        ],
        [
          const Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA', scriptCode: 'scriptcode'),
          expectedLocale,
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'CC'),
        ],
      );
      expect(resolvedLocale, expectedLocale);

      // Should return the first with the same codes
      expectedLocale = const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR', scriptCode: 'expected');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          const Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR', scriptCode: 'expected'),
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
        ],
        [
          const Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA', scriptCode: 'scriptcode'),
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR', scriptCode: 'notexpected'),
          expectedLocale,
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'CC'),
        ],
      );
      expect(resolvedLocale, expectedLocale);
    });

    test('returns the first supported locale if no match is found in desired locales', () {
      Locale expectedLocale;
      Locale resolvedLocale;

      expectedLocale = const Locale.fromSubtags(languageCode: 'es', countryCode: 'ES');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          const Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
        ],
        [
          expectedLocale,
          const Locale.fromSubtags(languageCode: 'eus', countryCode: 'ES'),
          const Locale.fromSubtags(languageCode: 'pl', countryCode: 'PL'),
        ],
      );
      expect(resolvedLocale, expectedLocale);

      expectedLocale = const Locale.fromSubtags(languageCode: 'en', countryCode: 'US');
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
          const Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
        ],
        [
          expectedLocale,
          const Locale.fromSubtags(languageCode: 'en', countryCode: 'UK'),
        ],
      );
      expect(resolvedLocale, expectedLocale);
    });

    test('returns the fallback locale if no match is found in desired locales', () {
      Locale expectedLocale;
      Locale resolvedLocale;

      final desiredLocales = [
        const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
        const Locale.fromSubtags(languageCode: 'en', countryCode: 'EU'),
      ];

      expectedLocale = const Locale.fromSubtags(languageCode: 'es', countryCode: 'ES');
      var supportedLocales = <Locale>[
        expectedLocale,
        const Locale.fromSubtags(languageCode: 'eus', countryCode: 'ES'),
        const Locale.fromSubtags(languageCode: 'pl', countryCode: 'PL'),
      ];

      resolvedLocale = LocaleMatcher.localeListResolution(
        desiredLocales,
        supportedLocales,
      );
      expect(resolvedLocale, expectedLocale);

      supportedLocales = [
        const Locale.fromSubtags(languageCode: 'eus', countryCode: 'ES'),
        const Locale.fromSubtags(languageCode: 'pl', countryCode: 'PL'),
      ];
      resolvedLocale = LocaleMatcher.localeListResolution(
        desiredLocales,
        supportedLocales,
        fallback: () => expectedLocale,
      );
      expect(resolvedLocale, expectedLocale);
    });

    test('returns "und" locale if supported and desired locales are not defined', () {
      Locale expectedLocale;
      Locale resolvedLocale;

      expectedLocale = const Locale.fromSubtags();
      resolvedLocale = LocaleMatcher.localeListResolution(null, []);
      expect(resolvedLocale, expectedLocale);

      expectedLocale = const Locale.fromSubtags();
      resolvedLocale = LocaleMatcher.localeListResolution([], []);
      expect(resolvedLocale, expectedLocale);
    });

    test('returns "und" locale if no supported locales are defined', () {
      Locale expectedLocale;
      Locale resolvedLocale;

      expectedLocale = const Locale.fromSubtags();
      resolvedLocale = LocaleMatcher.localeListResolution(
        [
          const Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
          const Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
          const Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
        ],
        [],
      );
      expect(resolvedLocale, expectedLocale);
    });
  });
}
