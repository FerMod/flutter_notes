import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../src/cache/cached_color.dart';

class ColorToggleButtons extends StatefulWidget {
  const ColorToggleButtons({
    super.key,
    this.initialValue,
    this.colors = const <Color>[],
    this.onPressed,
  });

  final List<Color?> colors;
  final Color? initialValue;
  final void Function(int index)? onPressed;

  @override
  State<ColorToggleButtons> createState() => _ColorToggleButtonsState();
}

class _ColorToggleButtonsState extends State<ColorToggleButtons> {
  late List<CachedColor> _cachedColors;
  late List<Widget> _children;
  late List<bool> _isSelected;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final colorsList = widget.colors;
    // Init list of selection state of buttons
    _isSelected = List.filled(colorsList.length, false);
    developer.log(_isSelected.toString());

    // Find the index of the initial value and update the selection state.
    // If none is found, set the first index as default.
    final index = colorsList.indexOf(widget.initialValue);
    _currentIndex = index != -1 ? index : 0;
    _isSelected[_currentIndex] = true;

    // Init list of cached colors
    _cachedColors = List.generate(
      colorsList.length,
      (index) => CachedColor(colorsList[index]!),
    );

    // Init the list of the color buttons that will be used.
    _children = List.generate(
      colorsList.length,
      (index) => ColorButton(
        color: _cachedColors[index].value,
        icon: const Icon(Icons.check),
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

    // Call onPressed function if it's not null
    widget.onPressed?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
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
      children: _children,
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
    super.key,
    required this.color,
    this.icon,
  });

  final Color? color;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.iconTheme.color!, width: 1.0),
        borderRadius: const BorderRadius.all(Radius.circular(2.0)),
        color: color,
      ),
      child: icon ?? const Icon(null),
    );
  }
}
