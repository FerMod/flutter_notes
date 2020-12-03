import 'dart:developer' as developer;

import 'package:flutter/material.dart';

class CardHero extends StatelessWidget {
  const CardHero({
    Key key,
    this.tag,
    this.child,
    this.onTap,
    this.onLongPress,
    this.color,
    this.shape,
    this.margin,
  }) : super(key: key);

  final String tag;
  final Widget child;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  final Color color;
  final ShapeBorder shape;
  final EdgeInsetsGeometry margin;

  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: shape,
        elevation: 8,
        margin: margin,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: 4),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
