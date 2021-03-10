import 'dart:ui';

import 'package:flutter_notes/src/utils/locale_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocaleUtils', () {
    String createlanguageTag({
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
      final languageCode = 'thisShouldBeWrong';
      String? scriptCode;
      String? countryCode = 'EE';
      final languageTag = createlanguageTag(
        languageCode: languageCode,
        scriptCode: scriptCode,
        countryCode: countryCode,
      );
      expect(
        LocaleUtils.localeFromLanguageTag(languageTag),
        Locale.fromSubtags(),
      );
    });

    test('returns a locale with the corect language code', () {
      final languageCode = 'en';
      String? scriptCode;
      String? countryCode;
      final languageTag = createlanguageTag(
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

    test('returns a locale with the corect script code', () {
      var languageCode = 'es';
      String? scriptCode;
      String? countryCode = '419';
      final languageTag = createlanguageTag(
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

    test('returns a locale with the corect country code', () {
      var languageCode = 'zh';
      String? scriptCode = 'Hans';
      String? countryCode = 'CN';
      var languageTag = createlanguageTag(
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
      languageTag = createlanguageTag(
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
