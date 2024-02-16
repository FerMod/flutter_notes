import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../src/cache/cached_color.dart';

/// A material design that displays the app's user avatar.
class UserAvatar extends StatelessWidget {
  /// Displays the image given the [imageUrl], or generates an image with one of
  /// more initials with [nameText].
  ///
  /// If both of [imageUrl] and [nameText], are null or empty then a default
  /// user icon will be displayed.
  ///
  /// Requires one of its ancestors to be a [Material] widget.
  const UserAvatar({
    super.key,
    String? imageUrl,
    String? nameText,
    this.fit = BoxFit.cover,
    this.shape = BoxShape.circle,
    this.alignment = Alignment.center,
    this.radius,
    this.minRadius,
    this.maxRadius,
    this.onTap,
    this.onImageError,
  })  : imageUrl = imageUrl ?? '',
        nameText = nameText ?? '',
        assert(
          radius == null || (minRadius == null && maxRadius == null),
          'Cannot provide a radius and also a minRadius and/or maxRadius\n'
          'Use only radius or use only minRadius and/or maxRadius.',
        );

  /// The user image url string.
  final String imageUrl;

  /// Text that will be used in case of a missing image to generate one or more
  /// initial as an avatar.
  final String nameText;

  /// How the image should be inscribed into the box.
  ///
  /// The default value is [BoxFit.cover].
  final BoxFit fit;

  /// The shape of the widget.
  final BoxShape shape;

  /// Align the content within the widget. Defaults to [Alignment.center].
  final AlignmentGeometry alignment;

  /// This function is called when the user makes tap in the avatar.
  final VoidCallback? onTap;

  /// An optional error callback for errors emitted when loading [imageUrl].
  final ImageErrorListener? onImageError;

  /// The size of the avatar, expressed as the radius. Default value is 20.0
  /// radius.
  ///
  /// If [radius] is specified, then neither [minRadius] nor [maxRadius] may be
  /// specified. Specifying [radius] is equivalent to specifying a [minRadius]
  /// and [maxRadius], both with the value of [radius].
  final double? radius;

  /// The minimum size of the avatar, expressed as the radius. Defaults to zero.
  ///
  /// If [minRadius] is specified, then [radius] must not also be specified.
  final double? minRadius;

  /// The maximum size of the avatar, expressed as the radius. Defaults to
  /// [double.infinity].
  ///
  /// If [maxRadius] is specified, then [radius] must not also be specified.
  final double? maxRadius;

  /// The default radius if nothing is specified.
  static const double defaultRadius = 20.0;

  /// The default min if only the max is specified.
  static const double _defaultMinRadius = 0.0;

  /// The default max if only the min is specified.
  static const double _defaultMaxRadius = double.infinity;

  double get _minDiameter {
    if (radius == null && minRadius == null && maxRadius == null) {
      return defaultRadius * 2.0;
    }
    return 2.0 * (radius ?? minRadius ?? _defaultMinRadius);
  }

  double get _maxDiameter {
    if (radius == null && minRadius == null && maxRadius == null) {
      return defaultRadius * 2.0;
    }
    return 2.0 * (radius ?? maxRadius ?? _defaultMaxRadius);
  }

  Color _getRandomColor([int? seed]) {
    return Color((math.Random(seed).nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget? accountWidget;
    DecorationImage? decorationImage;
    Color? backgroundColor;
    if (imageUrl.isNotEmpty) {
      backgroundColor = theme.primaryIconTheme.color;
      decorationImage = DecorationImage(
        image: NetworkImage(imageUrl),
        onError: onImageError,
        fit: fit,
        alignment: alignment,
      );
    } else {
      final regExp = RegExp(r'(?=\D)(\w)');
      final match = regExp.firstMatch(nameText)?.group(1);

      final cachedColor = CachedColor(_getRandomColor(match.hashCode)); //TODO: Implement better cache system

      if (match != null) {
        backgroundColor = cachedColor.value;
        accountWidget = MediaQuery(
          // Need to ignore the ambient textScaleFactor here so that the
          // text doesn't escape the avatar when the textScaleFactor is large.
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: Text(
            match.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: cachedColor.contrastingColor(),
            ),
          ),
        );
      } else {
        backgroundColor = cachedColor.contrastingColor();
        accountWidget = Icon(
          Icons.account_circle,
          size: defaultRadius * 2.0,
          color: cachedColor.value,
        );
      }
    }

    final boxDecoration = BoxDecoration(
      color: backgroundColor,
      image: decorationImage,
      shape: shape,
    );

    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: boxDecoration,
        child: InkWell(
          customBorder: ShapeDecoration.fromBoxDecoration(boxDecoration).shape,
          onTap: onTap,
          child: FittedBox(
            fit: fit,
            child: AnimatedContainer(
              duration: kThemeChangeDuration,
              curve: Curves.easeIn,
              constraints: BoxConstraints(
                minWidth: _minDiameter,
                minHeight: _minDiameter,
                maxWidth: _maxDiameter,
                maxHeight: _maxDiameter,
              ),
              alignment: alignment,
              child: accountWidget,
            ),
          ),
        ),
      ),
    );
  }
}
