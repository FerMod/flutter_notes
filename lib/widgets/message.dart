import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  /// The `color` and `decoration` arguments cannot both be supplied, since
  /// it would potentially result in the decoration drawing over the background
  /// color. To supply a decoration with a color, use
  /// `decoration: BoxDecoration(color: color)`.
  const MessageWidget({
    Key key,
    this.leading,
    this.title,
    this.contentTextStyle,
    this.actions = const <Widget>[],
    this.color,
    this.decoration,
    this.leadingPadding,
    this.contentPadding,
    this.actionsPadding,
    this.margin,
    this.minActionsHeight = 52.0,
    this.forceActionsBelow = false,
  })  : assert(actions != null),
        assert(forceActionsBelow != null),
        assert(
          color == null || decoration == null,
          'Cannot provide both a color and a decoration\n'
          'To provide both, use "decoration: BoxDecoration(color: color)".',
        ),
        super(key: key);

  /// A widget to display before the title.
  ///
  /// Typically an [Icon] or a [CircleAvatar] widget.
  final Widget leading;

  /// The primary content of the [MessageWidget].
  ///
  /// Typically a [Text] widget.
  final Widget title;

  /// Style for the text in the [title] of the [MessageWidget].
  ///
  /// If `null`, [MaterialBannerThemeData.contentTextStyle] is used. If that is
  /// also `null`, [TextTheme.bodyText2] of [ThemeData.textTheme] is used.
  final TextStyle contentTextStyle;

  /// The set of actions that are displayed at the bottom or trailing side of
  /// the [MessageWidget].
  ///
  /// Typically this is a list of [ElevatedButton] or [TextButton] widgets.
  final List<Widget> actions;

  /// The color of the surface of this [MessageWidget].
  ///
  /// This property should be preferred when the background is a simple color.
  /// For other cases, such as gradients or images, use the [decoration]
  /// property.
  ///
  /// If the [decoration] is used, this property must be null. A background
  /// color may still be painted by the [decoration] even if this property is
  /// null.
  ///
  /// If `null`, [MaterialBannerThemeData.backgroundColor] is used. If that is
  /// also `null`, [ColorScheme.surface] of [ThemeData.colorScheme] is used. In
  /// case of all the last colors to be `null`, [Colors.transparent] is used.
  final Color color;

  /// The decoration to paint behind.
  ///
  /// Use the [color] property to specify a simple solid color.
  final Decoration decoration;

  /// The [MessageWidget]'s internal padding, the empty space to inscribe inside
  /// the [decoration]. The [leading], [title] and [actions] widgets, are placed
  /// inside this padding.
  ///
  /// If the [actions] are below the [title], this defaults to
  /// `EdgeInsetsDirectional.only(start: 16.0, top: 24.0, end: 16.0, bottom: 4.0)`.
  ///
  /// If the [actions] are trailing the [title], this defaults to
  /// `EdgeInsetsDirectional.only(start: 16.0, top: 2.0)`.
  ///
  /// This padding is in addition to any padding inherent in the [decoration];
  /// see [Decoration.padding].
  final EdgeInsetsGeometry contentPadding;

  /// Empty space to surround the [decoration] and the [leading], [title] and
  /// [actions] widgets.
  final EdgeInsetsGeometry margin;

  /// The amount of space by which to inset the [leading] widget.
  ///
  /// This defaults to `EdgeInsetsDirectional.only(end: 16.0)`.
  final EdgeInsetsGeometry leadingPadding;

  /// The amount of space by which to inset the [actions] widgets.
  ///
  /// This defaults to `EdgeInsets.symmetric(horizontal: 8.0)`.
  final EdgeInsetsGeometry actionsPadding;

  /// The minimum height allocated for the [actions] widgets.
  ///
  /// This defaults to a minimum height of `52.0`.
  final double minActionsHeight;

  /// An override to force the [actions] to be below the [title] regardless of
  /// how many there are.
  ///
  /// If this is true, the [actions] will be placed below the [title]. If
  /// this is false, the [actions] will be placed on the trailing side of the
  /// [title] if [actions]'s length is one and below the [title] if greater
  /// than one.
  final bool forceActionsBelow;

  bool get _isSingleRow => actions.length < 2 && !forceActionsBelow;

  EdgeInsetsDirectional get _defaultContentPadding {
    if (_isSingleRow) {
      return const EdgeInsetsDirectional.only(start: 16.0, top: 2.0);
    }
    return const EdgeInsetsDirectional.only(start: 16.0, top: 24.0, end: 16.0, bottom: 4.0);
  }

  EdgeInsetsDirectional get _defaultLeadingPadding {
    return const EdgeInsetsDirectional.only(end: 16.0);
  }

  EdgeInsets get _defaultActionsPadding {
    return const EdgeInsets.symmetric(horizontal: 8.0);
  }

  TextStyle _textStyle(ThemeData theme, MaterialBannerThemeData bannerTheme) {
    final style = contentTextStyle ?? bannerTheme?.contentTextStyle ?? theme.textTheme.bodyText2;
    final color = _textColor(theme, bannerTheme, style.color);
    return _isSingleRow ? style.copyWith(fontSize: 15.0, color: color) : style.copyWith(color: color);
  }

  Color _iconColor(ThemeData theme) {
    switch (theme.brightness) {
      case Brightness.light:
        return Colors.black45;
      case Brightness.dark:
      default:
        return null; // null - use current icon theme color
    }
  }

  Color _textColor(ThemeData theme, MaterialBannerThemeData bannerTheme, Color defaultColor) {
    return bannerTheme?.contentTextStyle?.color ?? defaultColor;
  }

  Color _backgroundColor(ThemeData theme, MaterialBannerThemeData bannerTheme) {
    if (color != null) {
      return color;
    }
    if (bannerTheme?.backgroundColor != null) {
      return bannerTheme.backgroundColor;
    }
    if (theme?.colorScheme?.surface != null) {
      return theme.colorScheme.surface;
    }

    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bannerTheme = MaterialBannerTheme.of(context);

    Widget leadingIcon;
    if (leading != null) {
      final iconThemeData = IconThemeData(color: _iconColor(theme));
      final resolvedLeadingPadding = leadingPadding ?? bannerTheme?.leadingPadding ?? _defaultLeadingPadding;
      leadingIcon = Padding(
        padding: resolvedLeadingPadding,
        child: IconTheme.merge(
          data: iconThemeData,
          child: leading,
        ),
      );
    }

    Widget titleText;
    if (title != null) {
      titleText = Expanded(
        child: AnimatedDefaultTextStyle(
          style: _textStyle(theme, bannerTheme),
          duration: kThemeChangeDuration,
          child: title,
        ),
      );
    }

    final buttonBar = ButtonBar(
      layoutBehavior: ButtonBarLayoutBehavior.constrained,
      buttonPadding: actionsPadding ?? _defaultActionsPadding,
      buttonHeight: minActionsHeight,
      children: actions ?? const [],
    );

    final resolvedContentPadding = contentPadding ?? bannerTheme.padding ?? _defaultContentPadding;

    final defaultDecoration = BoxDecoration(
      color: color ?? _backgroundColor(theme, bannerTheme),
      border: Border(
        bottom: Divider.createBorderSide(
          context,
          width: 1.0,
        ),
      ),
    );

    return SafeArea(
      child: Container(
        margin: margin,
        decoration: decoration ?? defaultDecoration,
        child: Column(
          children: [
            Padding(
              padding: resolvedContentPadding,
              child: Row(
                children: [
                  if (leadingIcon != null) leadingIcon,
                  if (titleText != null) titleText,
                  if (_isSingleRow) buttonBar,
                ],
              ),
            ),
            if (!_isSingleRow) buttonBar,
          ],
        ),
      ),
    );
  }
}
