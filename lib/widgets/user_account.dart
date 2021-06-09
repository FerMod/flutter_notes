import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../src/cache/cached_color.dart';

/// A material design that displays the app's user avatar.
class UserAvatar extends StatelessWidget {
  /// Constant of the [Icon] size value that should have.
  static const double alternativeImageIconSize = 40.0;

  /// Displays the image given the [imageUrl], or generates an image with one of
  /// more initials with [nameText].
  ///
  /// If both of [imageUrl] and [nameText], are null or empty then a default
  /// user icon will be displayed.
  ///
  /// Requires one of its ancestors to be a [Material] widget.
  const UserAvatar({
    Key? key,
    String? imageUrl,
    String? nameText,
    this.fit = BoxFit.cover,
    this.shape = BoxShape.circle,
    this.alignment = Alignment.center,
    this.onTap,
    this.radius,
    this.minRadius,
    this.maxRadius,
  })  : imageUrl = imageUrl ?? '', // 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
        nameText = nameText ?? '',
        assert(
          radius == null || (minRadius == null && maxRadius == null),
          'Cannot provide a radius and also a minRadius and/or maxRadius\n'
          'Use only radius or use only minRadius and/or maxRadius.',
        ),
        super(key: key);

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

  // /// The internal padding for the widget's content.
  // final EdgeInsets padding;

  // final EdgeInsets margin;

  /// This function is called when the user makes tap in the avatar.
  final VoidCallback? onTap;

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

  // The default radius if nothing is specified.
  static const double _defaultRadius = 20.0;

  // The default min if only the max is specified.
  static const double _defaultMinRadius = 0.0;

  // The default max if only the min is specified.
  static const double _defaultMaxRadius = double.infinity;

  double get _minDiameter {
    if (radius == null && minRadius == null && maxRadius == null) {
      return _defaultRadius * 2.0;
    }
    return 2.0 * (radius ?? minRadius ?? _defaultMinRadius);
  }

  double get _maxDiameter {
    if (radius == null && minRadius == null && maxRadius == null) {
      return _defaultRadius * 2.0;
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
    late Color backgroundColor;
    if (imageUrl.isNotEmpty) {
      backgroundColor = theme.colorScheme.onPrimary;
      decorationImage = DecorationImage(
        image: NetworkImage(imageUrl),
        //onError: onBackgroundImageError,
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
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
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
          size: alternativeImageIconSize,
          color: cachedColor.value,
        );
      }
    }

    final boxDecoration = BoxDecoration(
      color: backgroundColor,
      image: decorationImage,
      shape: shape,
    );

    return FittedBox(
      fit: fit,
      child: AnimatedContainer(
        decoration: boxDecoration,
        constraints: BoxConstraints(
          minHeight: _minDiameter,
          minWidth: _minDiameter,
          maxWidth: _maxDiameter,
          maxHeight: _maxDiameter,
        ),
        alignment: alignment,
        duration: kThemeChangeDuration,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: ShapeDecoration.fromBoxDecoration(boxDecoration).shape,
            onTap: onTap,
            child: accountWidget,
          ),
        ),
      ),
    );
  }
}

/// A ListTile that displays the app's user name, email and image.
@deprecated
class UserAccountListTile extends StatelessWidget {
  /// Creates a material design account widget. Displays the user name and email
  /// given [nameText] and [emailText] with a leading image loaded from the url
  /// [imageUrl] passed as parameter.
  ///
  /// Requires one of its ancestors to be a [Material] widget.
  const UserAccountListTile({
    Key? key,
    this.image,
    this.name,
    this.email,
    this.onTap,
    this.onTapImage,
  }) : super(key: key);

  /// A widget placed in the left that represents the current user's account
  /// image.
  ///
  /// Normally an [Icon], a [UserAvatar] or a [CircleAvatar] widget.
  final Widget? image;

  /// A widget that represents the current user's account name. It is displayed
  /// on the right of the [image], above the [email] widget.
  final Widget? name;

  /// A widget that represents the current user's account email. It is displayed
  /// on the right of the [image], below the [name] widget.
  final Widget? email;

  final VoidCallback? onTap;

  final VoidCallback? onTapImage;

  Color? _iconColor(ThemeData theme) {
    switch (theme.brightness) {
      case Brightness.light:
        return Colors.black45;
      case Brightness.dark:
      default:
        return null; // null - use current icon theme color

    }
  }

  Image _loadImage(String src) {
    return Image.network(
      src,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(seconds: 1),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        final theme = Theme.of(context);
        final iconThemeData = IconThemeData(color: _iconColor(theme));

        return IconTheme.merge(
          data: iconThemeData,
          child: const Icon(Icons.account_circle),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Widget? tittleWidget;
    // if (nameText?.isNotEmpty ?? false) {
    //   tittleWidget = Text(nameText!);
    // }

    // Widget? subtitleWidget;
    // if (emailText?.isNotEmpty ?? false) {
    //   subtitleWidget = Text(emailText!);
    // }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: image,
      title: name,
      subtitle: email,
      onTap: onTap,
      mouseCursor: MouseCursor.defer,
    );
  }
}
