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
    this.onTap,
  })  : imageUrl = imageUrl ?? '',
        nameText = nameText ?? '',
        super(key: key);

  /// The user image url string.
  final String imageUrl;

  /// Text that will be used in case of a missing image to generate one or more
  /// initial as an avatar.
  final String nameText;

  /// This function is called when the user makes tap in the avatar.
  final VoidCallback? onTap;

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

  Color _getRandomColor([int? seed]) {
    return Color((math.Random(seed).nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget? leadingWidget;

    ImageProvider? imageProvider;
    Color? backgroundColor;
    Color? foregroundColor;
    if (imageUrl.isNotEmpty) {
      imageProvider = NetworkImage(imageUrl);
      backgroundColor = theme.colorScheme.onPrimary;
    } else {
      final regExp = RegExp(r'(?=\D)(\w)');
      final match = regExp.firstMatch(nameText)?.group(1);

      final cachedColor = CachedColor(_getRandomColor(match.hashCode)); //TODO: Implement better cache system

      if (match != null) {
        backgroundColor = cachedColor.value;
        foregroundColor = cachedColor.contrastingColor();
        leadingWidget = Text(
          match.toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      } else {
        foregroundColor = cachedColor.value;
        backgroundColor = cachedColor.contrastingColor();
        leadingWidget = Icon(
          Icons.account_circle,
          size: alternativeImageIconSize,
        );
      }
    }

    return InkWell(
      onTap: onTap,
      mouseCursor: MouseCursor.defer,
      child: CircleAvatar(
        backgroundImage: imageProvider,
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        child: leadingWidget,
      ),
    );
  }
}

/// A ListTile that displays the app's user name, email and image.
class UserAccountListTile extends StatelessWidget {
  /// Creates a material design account widget. Displays the user name and email
  /// given [nameText] and [emailText] with a leading image loaded from the url
  /// [imageUrl] passed as parameter.
  ///
  /// Requires one of its ancestors to be a [Material] widget.
  const UserAccountListTile({
    Key? key,
    this.imageUrl,
    this.nameText,
    this.emailText,
    this.onTap,
    this.onTapImage,
  }) : super(key: key);

  final String? imageUrl;
  final String? nameText;
  final String? emailText;
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
    Widget? tittleWidget;
    if (nameText?.isNotEmpty ?? false) {
      tittleWidget = Text(nameText!);
    }

    Text? subtitleWidget;
    if (emailText?.isNotEmpty ?? false) {
      subtitleWidget = Text(emailText!);
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: UserAvatar(
        imageUrl: imageUrl,
        nameText: nameText,
        onTap: onTapImage,
      ),
      title: tittleWidget,
      subtitle: subtitleWidget,
      onTap: onTap,
      mouseCursor: MouseCursor.defer,
    );
  }
}
