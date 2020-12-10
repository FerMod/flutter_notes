import 'dart:math' as math;

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
  List<bool> _isSelected;
  int _currentIndex;

  // https://www.w3.org/TR/WCAG20/#relativeluminancedef
  // static final Map<Color, double> _relativeLuminanceCache = {};

  @override
  void initState() {
    super.initState();
    // Init list of selection state of buttons
    _isSelected = List.filled(widget.colors.length, false);
    //_relativeLuminance = List.filled(widget.colors.length, [])
    //print(_isSelected.toString());
    // Find the index of the intial value and update the selection state.
    // If none is found, set the first index as default.
    final index = widget.colors.indexOf(widget.initialValue);
    _currentIndex = index != -1 ? index : 0;
    _isSelected[_currentIndex] = true;
    print(_isSelected.toString());
  }

  // https://stackoverflow.com/a/3943023/4134376
  Color _contrastColor(Color color) {
    //final luminance = _relativeLuminanceCache.putIfAbsent(color, () => color.computeLuminance());
    final luminance = color.computeLuminance();
    final contrast = math.sqrt(1.05 * 0.05) - 0.05;
    return (luminance > contrast) ? Colors.black : Colors.white;
  }

  Widget _createColorButton(Color color) {
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

  void _handleOnPressed(int index) {
    assert(_isSelected[_currentIndex] == true);
    if (index == _currentIndex) return;

    setState(() {
      _isSelected[_currentIndex] = false;
      _isSelected[index] = true;
    });
    _currentIndex = index;

    if (widget.onPressed != null) {
      widget.onPressed(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    final theme = Theme.of(context);
    return ToggleButtons(
      children: [
        for (var color in widget.colors) _createColorButton(color),
      ],
      onPressed: _handleOnPressed,
      isSelected: _isSelected,
      color: Colors.transparent,
      selectedColor: _contrastColor(widget.colors[_currentIndex]), //theme.colorScheme.primary,
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
