import 'package:flutter/material.dart';

class CardHero extends StatelessWidget {
  const CardHero({
    Key key,
    this.tag,
    this.child,
    this.onTap,
    this.color,
    this.margin,
  }) : super(key: key);

  final String tag;
  final Widget child;
  final VoidCallback onTap;
  final Color color;
  final EdgeInsetsGeometry margin;

  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        elevation: 8,
        margin: margin,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
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
      ),
    );
  }
}
