import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ColorToggleButtons extends StatefulWidget {
  const ColorToggleButtons({
    Key key,
    this.initialValue,
    this.colors = const <Color>[],
    this.onPressed,
  }) : super(key: key);

  final List<Color> colors;
  final Color initialValue;
  final void Function(int index) onPressed;

  @override
  _ColorToggleButtonsState createState() => _ColorToggleButtonsState();
}

class _ColorToggleButtonsState extends State<ColorToggleButtons> {
  List<CachedColor> _cachedColors;
  List<Widget> _children;
  List<bool> _isSelected;
  int _currentIndex;

  @override
  void initState() {
    super.initState();
    final colorsList = widget.colors;
    // Init list of selection state of buttons
    _isSelected = List.filled(colorsList.length, false);
    print(_isSelected.toString());

    // Find the index of the intial value and update the selection state.
    // If none is found, set the first index as default.
    final index = colorsList.indexOf(widget.initialValue);
    _currentIndex = index != -1 ? index : 0;
    _isSelected[_currentIndex] = true;
    print(_isSelected.toString());

    // Init list of cached colors
    _cachedColors = List.generate(
      colorsList.length,
      (index) => CachedColor(colorsList[index]),
    );

    // Init the list of the color buttons that will be used.
    _children = List.generate(
      colorsList.length,
      (index) => ColorButton(color: _cachedColors[index].value),
    );
  }

  void _handleOnPressed(int index) {
    assert(_isSelected[_currentIndex] == true);
    if (index == _currentIndex) return;

    setState(() {
      _isSelected[_currentIndex] = false;
      _isSelected[index] = true;
    });
    _currentIndex = index;

    // Call onPressed function if it's not null
    widget.onPressed?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    final theme = Theme.of(context);
    return ToggleButtons(
      children: _children,
      isSelected: _isSelected,
      onPressed: _handleOnPressed,
      color: Colors.transparent,
      //selectedColor: _contrastColor(widget.colors[_currentIndex]), //theme.colorScheme.primary,
      selectedColor: _cachedColors[_currentIndex].contrastingColor(),
      fillColor: Colors.transparent,
      // focusColor: null,
      // hoverColor: null,
      // highlightColor: null,
      // splashColor: null,
      renderBorder: false,
      // borderWidth: 1,
      // borderColor: Colors.transparent,
      // selectedBorderColor: Colors.transparent,
      // disabledColor: null,
      // disabledBorderColor: null,
    );
  }
}

class ColorButton extends StatelessWidget {
  const ColorButton({
    Key key,
    @required this.color,
  }) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      child: Icon(Icons.check),
      decoration: BoxDecoration(
        border: Border.all(color: theme.iconTheme.color, width: 1.0),
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
        color: color,
      ),
    );
  }
}

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
  /// The [Color] value stored in the cache.
  final Color value;

  /// The relative luminance of the color. A brightness value between
  /// 0 (darkest) and 1 (lightest).
  ///
  /// See <https://www.w3.org/TR/WCAG20/#relativeluminancedef>.
  double get relativeLuminance => _relativeLuminance ??= value.computeLuminance();
  double _relativeLuminance;

  /// The ratio of the luminance of the brightest color (white) to that of the
  /// darkest color (black).
  ///
  /// See <https://www.w3.org/TR/WCAG20/#contrast-ratiodef>.
  static double contrastRatio = math.sqrt(1.05 * 0.05) - 0.05;

  static final Map<Color, CachedColor> _cache = {};

  /// Creates a [CachedColor] instance that caches the color [value].
  ///
  /// The value is looked up in the cached colors and if there isn't any, it is
  /// added to the the cache for future access.
  factory CachedColor(Color value) {
    return _cache.putIfAbsent(value, () => CachedColor._internal(value));
  }

  CachedColor._internal(this.value);

  /// Returns the color [Colors.black] or [Colors.white] that has more contrast
  /// with the color [value].
  ///
  /// If the [relativeLuminance] is greater than the [contrastRatio], the
  /// returned color is [Colors.black], otherwise, returns [Colors.white].
  Color contrastingColor() {
    // https://stackoverflow.com/a/3943023/4134376
    return relativeLuminance > contrastRatio ? Colors.black : Colors.white;
  }

  @override
  String toString() => "CachedColor(value: $value, relativeLuminance: $_relativeLuminance, contrastRatio: $contrastRatio)";
}
