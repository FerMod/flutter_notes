import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Stores a [Color] value and keeps the created instance in a cache for later
/// use.
///
/// Contains the [relativeLuminance], that is a value calculated with
/// [Color.computeLuminance], a computational expensive operation. For that
/// reason the value is lazily initialized, and only computed when needed.
///
/// See also:
///
/// * <https://en.wikipedia.org/wiki/Relative_luminance>
class CachedColor {
  /// Creates a [CachedColor] instance that caches the color [value].
  ///
  /// The value is looked up in the cached colors and if there isn't any, it is
  /// added to the the cache for future access.
  factory CachedColor(Color? value) {
    return _cache.putIfAbsent(value, () => CachedColor._internal(value));
  }

  CachedColor._internal(this.value);

  /// The [Color] value stored in the cache.
  final Color? value;

  /// The relative luminance of the color. A brightness value between
  /// 0 (darkest) and 1 (lightest).
  ///
  /// See <https://www.w3.org/TR/WCAG20/#relativeluminancedef>.
  double get relativeLuminance => _relativeLuminance ??= value!.computeLuminance();
  double? _relativeLuminance;

  /// The ratio of the luminance of the brightest color (white) to that of the
  /// darkest color (black).
  ///
  /// See <https://www.w3.org/TR/WCAG20/#contrast-ratiodef>.
  static double contrastRatio = math.sqrt(1.05 * 0.05) - 0.05;

  /// A view of the cached colors [Map]. This view disallow modifying the map.
  ///
  /// The cached map is wrapped around with an [UnmodifiableMapView], that
  /// forwards all members to the map, except for operations that modify the
  /// map. Modifying operations throw instead.
  static UnmodifiableMapView<Color?, CachedColor> get cache => UnmodifiableMapView(_cache);
  static final Map<Color?, CachedColor> _cache = {};

  /// Returns the color [Colors.black] or [Colors.white] that has more contrast
  /// with the color [value].
  ///
  /// If the [relativeLuminance] is greater than the [contrastRatio], the
  /// returned color is [Colors.black], otherwise, returns [Colors.white].
  ///
  /// See:
  ///  - [CachedColor.brightness]
  Color contrastingColor() {
    return brightness() == Brightness.light ? Colors.black : Colors.white;
  }

  /// Returns the estimated [Brightness] of the color [value]. The returned
  /// values are [Brightness.light], when it's considered a light color and
  /// [Brightness.dark], when it's considered a dark color.
  ///
  /// If the [relativeLuminance] is greater than the [contrastRatio], the
  /// returned brightness is [Brightness.light], otherwise, it returns
  /// [Brightness.dark].
  ///
  /// [Brightness.light] means that it will require a dark color to achieve
  /// readable contrast, and with [Brightness.dark] it will require a light
  /// color.
  Brightness brightness() {
    // https://stackoverflow.com/a/3943023/4134376
    return relativeLuminance > contrastRatio ? Brightness.light : Brightness.dark;
  }

  @override
  String toString() => "$CachedColor(value: $value, relativeLuminance: $_relativeLuminance, contrastRatio: $contrastRatio)";
}
