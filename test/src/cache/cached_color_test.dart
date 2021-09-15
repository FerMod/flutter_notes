import 'package:flutter/material.dart';
import 'package:flutter_notes/src/cache/cached_color.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CachedColor', () {
    const uniqueColors = <Color>[
      Color(0xFFFFFFFF), // white
      Color(0xFFE6B904), // yellow
      Color(0xFF65BA5A), // green
      Color(0xFFC78EFF), // purple
      Color(0xFF5AC0E7), // blue
      Color(0xFFFF5722), // dark orange
      Color(0xFF3E2723), // dark brown
      Color(0xFF000000), // black
    ];

    const repeatingColors = <Color>[
      Color(0xFFE6B904), // yellow
      Color(0xFF000000), // black
      Color(0xFFE6B904), // yellow
      Color(0xFFF44336), // red
      Color(0xFFF44336), // red
      Color(0xFF000000), // black
    ];

    tearDown(() {
      CachedColor.clear();
    });

    test('add colors to cache', () {
      var cachedValues = 0;
      for (var i = 0; i < uniqueColors.length; i++) {
        expect(CachedColor.cache.length, i);

        final color = uniqueColors[i];
        final cachedColor = CachedColor(color);
        expect(cachedColor.value.value, color.value);

        cachedValues++;
        expect(CachedColor.cache.length, cachedValues);
      }
    });

    test('adds colors to cache that are not already cached', () {
      var cachedValues = 0;
      for (var i = 0; i < repeatingColors.length; i++) {
        expect(CachedColor.cache.length, cachedValues);

        final color = repeatingColors[i];
        if (!CachedColor.cache.containsKey(color)) {
          cachedValues++;
        }

        final cachedColor = CachedColor(color);
        expect(cachedColor.value.value, color.value);

        expect(CachedColor.cache.length, cachedValues);
      }
    });

    test('calculates the color relative luminance', () {
      expect(CachedColor.cache.length, 0);
      final color = uniqueColors[0];
      final cachedColor = CachedColor(color);

      final luminance = color.computeLuminance();
      expect(cachedColor.relativeLuminance, luminance);
    });

    test('calculates the color brightness', () {
      expect(CachedColor.cache.length, 0);
      final cachedColor = CachedColor(uniqueColors[0]);
      final luminance = cachedColor.relativeLuminance;
      final contrastRatio = CachedColor.contrastRatio;

      final brightness = luminance > contrastRatio ? Brightness.light : Brightness.dark;
      expect(cachedColor.brightness(), brightness);
    });
  });
}
