import 'dart:developer' as developer;

import 'package:flutter/material.dart';

class CardHero extends StatelessWidget {
  const CardHero({
    Key key,
    this.tag,
    this.shape,
    this.margin,
    this.color,
    this.child,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  final String tag;
  final ShapeBorder shape;
  final EdgeInsetsGeometry margin;
  final Color color;
  final Widget child;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;

  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Card(
        elevation: 8.0,
        shape: shape,
        margin: margin,
        clipBehavior: Clip.antiAlias,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: color, width: 4.0),
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
