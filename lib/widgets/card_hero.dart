import 'package:flutter/material.dart';

class CardHero extends StatelessWidget {
  const CardHero({
    super.key,
    required this.tag,
    this.shape,
    this.elevation,
    this.margin,
    this.decoration,
    this.width,
    this.color,
    this.backgroundColor,
    this.onTap,
    this.onLongPress,
    this.child,
  });

  /// The identifier for this particular hero. If the tag of this hero matches
  /// the tag of a hero on a [PageRoute] that we're navigating to or from, then
  /// a hero animation will be triggered.
  final Object tag;

  /// The shape of the card's [Material].
  ///
  /// Defines the card's [Material.shape].
  ///
  /// If this property is null then [CardTheme.shape] of [ThemeData.cardTheme]
  /// is used. If that's null then the shape will be a [RoundedRectangleBorder]
  /// with a circular corner radius of 4.0.
  final ShapeBorder? shape;

  /// The decoration to paint behind the [child].
  ///
  /// If this property is null then as the default decoration is:
  ///
  /// ```dart
  /// Border(
  ///   top: Divider.createBorderSide(
  ///     context,
  ///     color: color,
  ///     width: width,
  ///   ),
  /// )
  /// ```
  ///
  /// See also:
  ///
  ///  * [width] to change the border width.
  ///  * [color] to change the border color.
  ///  * [backgroundColor] to change the background color.
  final Decoration? decoration;

  /// The width of the the default [decoration] border.
  ///
  /// If this property is null then the default width of 5.0 is used.
  final double? width;
  static const double _defaultWidth = 5.0;

  /// The color of the default [decoration] border.
  ///
  /// If this property is null then [DividerThemeData.color] is used. If that is
  /// also null, then [ThemeData.dividerColor] is used.
  final Color? color;

  /// The color of the default [decoration] background color.
  ///
  /// If this property is null then [CardTheme.color] of [ThemeData.cardTheme]
  /// is used. If that's null then [ThemeData.cardColor] is used.
  final Color? backgroundColor;

  /// The z-coordinate at which to place this card. This controls the size of
  /// the shadow below the card.
  ///
  /// Defines the card's [Material.elevation].
  ///
  /// If this property is null then the default elevation of 4.0 is used.
  final double? elevation;
  static const double _defaultElevation = 4.0;

  /// The empty space that surrounds the card.
  ///
  /// Defines the card's outer [Container.margin].
  ///
  /// If this property is null then [CardTheme.margin] of
  /// [ThemeData.cardTheme] is used. If that's null, the default margin is 4.0
  /// logical pixels on all sides: `EdgeInsets.all(4.0)`.
  final EdgeInsetsGeometry? margin;

  /// The widget below this widget in the tree.
  final Widget? child;

  /// A tap with a primary button has occurred.
  final GestureTapCallback? onTap;

  /// Called when a long press gesture with a primary button has been
  /// recognized.
  ///
  /// Triggered when a pointer has remained in contact with the screen at the
  /// same location for a long period of time.
  final GestureLongPressCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = CardTheme.of(context);

    Color? resolvedCardColor = backgroundColor ?? cardTheme.color ?? theme.cardColor;
    if (backgroundColor == null && theme.brightness == Brightness.light) {
      resolvedCardColor = Color.lerp(resolvedCardColor, color, 0.4);
    }

    Widget content = Ink(
      decoration: decoration ??
          BoxDecoration(
            border: Border(
              top: Divider.createBorderSide(
                context,
                color: color,
                width: width ?? _defaultWidth,
              ),
            ),
          ),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      content = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: content,
      );
    }

    return Hero(
      tag: tag,
      child: Card(
        elevation: elevation ?? _defaultElevation,
        shape: shape,
        margin: margin,
        color: resolvedCardColor,
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  }
}
