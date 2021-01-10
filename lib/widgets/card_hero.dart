import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CardHero extends StatelessWidget {
  const CardHero({
    Key key,
    this.tag,
    this.shape,
    // this.decoration,
    this.elevation = 8.0,
    this.margin,
    this.color,
    this.child,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  /// The identifier for this particular hero. If the tag of this hero matches
  /// the tag of a hero on a [PageRoute] that we're navigating to or from, then
  /// a hero animation will be triggered.
  final String tag;

  /// The shape of the card's [Material].
  ///
  /// Defines the card's [Material.shape].
  ///
  /// If this property is null then [CardTheme.shape] of [ThemeData.cardTheme]
  /// is used. If that's null then the shape will be a [RoundedRectangleBorder]
  /// with a circular corner radius of 4.0.
  final ShapeBorder shape;

  // final Decoration decoration;

  /// The z-coordinate at which to place this card. This controls the size of
  /// the shadow below the card.
  ///
  /// Defines the card's [Material.elevation].
  ///
  /// If this property is null then [CardTheme.elevation] of
  /// [ThemeData.cardTheme] is used. If that's null, the default value is 1.0.
  final double elevation;

  /// The empty space that surrounds the card.
  ///
  /// Defines the card's outer [Container.margin].
  ///
  /// If this property is null then [CardTheme.margin] of
  /// [ThemeData.cardTheme] is used. If that's null, the default margin is 4.0
  /// logical pixels on all sides: `EdgeInsets.all(4.0)`.
  final EdgeInsetsGeometry margin;

  /// The color of this side of the border.
  final Color color;

  /// The widget below this widget in the tree.
  final Widget child;

  /// A tap with a primary button has occurred.
  final GestureTapCallback onTap;

  /// Called when a long press gesture with a primary button has been recognized.
  ///
  /// Triggered when a pointer has remained in contact with the screen at the
  /// same location for a long period of time.
  final GestureLongPressCallback onLongPress;

  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Card(
        elevation: elevation,
        shape: shape,
        margin: margin,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: 5.0),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
