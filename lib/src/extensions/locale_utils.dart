import 'dart:ui' show Locale;

extension LocaleUtils on Locale {
  static const String languageTagRegExp = r'^([A-Za-z]{2,3}|[A-Za-z]{5,8})'
      r'(?:[-_]([A-Za-z]{4}))?'
      r'(?:[-_]([A-Za-z]{2}|[0-9]{3}))?$';

  /// Creates a Locale from a valid Unicode BCP47 Locale Identifier. If
  /// [languageTag] is null or empty, it will return a locale with a language
  /// code of "und", an undefined language code.
  ///
  /// Some examples of such identifiers: "en", "es-419", "hi-Deva-IN" and
  /// "zh-Hans-CN". See <http://www.unicode.org/reports/tr35/> for technical
  /// details.
  static Locale localeFromLanguageTag(String? languageTag) {
    if (languageTag?.isEmpty ?? true) return const Locale.fromSubtags();

    final regExp = RegExp(languageTagRegExp);
    final match = regExp.firstMatch(languageTag!);

    return Locale.fromSubtags(
      languageCode: match?.group(1) ?? 'und',
      scriptCode: match?.group(2),
      countryCode: match?.group(3),
    );
  }
}
