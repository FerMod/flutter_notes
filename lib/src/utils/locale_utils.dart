import 'dart:ui';

class LocaleUtils {
  const LocaleUtils._();

  /// Returns a Locale from a valid Unicode BCP47 Locale Identifier.
  ///
  /// Some examples of such identifiers: "en", "es-419", "hi-Deva-IN" and
  /// "zh-Hans-CN". See http://www.unicode.org/reports/tr35/ for technical
  /// details.
  static Locale localeFromLanguageTag(String languageTag) {
    final regExprString = r'^([A-Za-z]{2,3}|[A-Za-z]{5,8})'
        r'(?:[-_]([A-Za-z]{4}))?'
        r'(?:[-_]([A-Za-z]{2}|[0-9]{3}))?$';
    final regExp = RegExp(regExprString);
    final match = regExp.firstMatch(languageTag);
    return Locale.fromSubtags(
      languageCode: match?.group(1) ?? 'und',
      scriptCode: match?.group(2),
      countryCode: match?.group(3),
    );
  }
}
