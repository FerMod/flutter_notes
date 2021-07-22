import 'dart:ui';

import 'package:flutter_notes/src/extensions/locale_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocaleUtils', () {
    String createLanguageTag({
      required String languageCode,
      String? scriptCode,
      String? countryCode,
      String separator = '-',
    }) {
      final sb = StringBuffer(languageCode);
      if (scriptCode != null && scriptCode.isNotEmpty) {
        sb.write('$separator$scriptCode');
      }
      if (countryCode != null && countryCode.isNotEmpty) {
        sb.write('$separator$countryCode');
      }
      return sb.toString();
    }

    test('returns a undefined locale if cannot parse language tag', () {
      const languageCode = 'thisShouldBeWrong';
      String? scriptCode;
      String? countryCode = 'EE';
      final languageTag = createLanguageTag(
        languageCode: languageCode,
        scriptCode: scriptCode,
        countryCode: countryCode,
      );
      expect(
        LocaleUtils.localeFromLanguageTag(languageTag),
        const Locale.fromSubtags(),
      );
    });

    test('returns a locale with the correct language code', () {
      const languageCode = 'en';
      String? scriptCode;
      String? countryCode;
      final languageTag = createLanguageTag(
        languageCode: languageCode,
        scriptCode: scriptCode,
        countryCode: countryCode,
      );
      expect(
        LocaleUtils.localeFromLanguageTag(languageTag),
        Locale.fromSubtags(
          languageCode: languageCode,
          scriptCode: scriptCode,
          countryCode: countryCode,
        ),
      );
    });

    test('returns a locale with the correct script code', () {
      var languageCode = 'es';
      String? scriptCode;
      String? countryCode = '419';
      final languageTag = createLanguageTag(
        languageCode: languageCode,
        scriptCode: scriptCode,
        countryCode: countryCode,
      );
      expect(
        LocaleUtils.localeFromLanguageTag(languageTag),
        Locale.fromSubtags(
          languageCode: languageCode,
          scriptCode: scriptCode,
          countryCode: countryCode,
        ),
      );
    });

    test('returns a locale with the correct country code', () {
      var languageCode = 'zh';
      String? scriptCode = 'Hans';
      String? countryCode = 'CN';
      var languageTag = createLanguageTag(
        languageCode: languageCode,
        scriptCode: scriptCode,
        countryCode: countryCode,
      );
      expect(
        LocaleUtils.localeFromLanguageTag(languageTag),
        Locale.fromSubtags(
          languageCode: languageCode,
          scriptCode: scriptCode,
          countryCode: countryCode,
        ),
      );

      languageCode = 'hi';
      scriptCode = 'Deva';
      countryCode = 'IN';
      languageTag = createLanguageTag(
        languageCode: languageCode,
        scriptCode: scriptCode,
        countryCode: countryCode,
      );

      expect(
        LocaleUtils.localeFromLanguageTag(languageTag),
        Locale.fromSubtags(
          languageCode: languageCode,
          scriptCode: scriptCode,
          countryCode: countryCode,
        ),
      );
    });
  });
}
