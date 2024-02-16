import 'package:flutter/material.dart';

class UserAccountTile extends StatelessWidget {
  const UserAccountTile({
    super.key,
    this.image,
    this.title,
    this.subtitle,
    this.imageSize,
    this.margin,
    this.padding,
    this.decoration,
    this.onTap,
    this.onLongPress,
  });

  final Widget? image;
  final Widget? title;
  final Widget? subtitle;

  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;
  final Size? imageSize;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget? imageWidget;
    if (image != null) {
      imageWidget = IconTheme.merge(
        data: theme.primaryIconTheme.copyWith(
          size: imageSize?.longestSide,
        ),
        child: image!,
      );
    }

    Widget? titleWidget;
    if (title != null) {
      titleWidget = DefaultTextStyle(
        style: theme.primaryTextTheme.bodyLarge!,
        child: title!,
      );
    }

    Widget? subtitleWidget;
    if (subtitle != null) {
      subtitleWidget = DefaultTextStyle(
        style: theme.primaryTextTheme.bodyMedium!,
        child: subtitle!,
      );
    }

    return Container(
      margin: margin,
      padding: padding,
      decoration: decoration
      // ??
      //     BoxDecoration(
      //       color: theme.primaryColor,
      //     )
      ,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: SizedBox.fromSize(
          size: imageSize,
          child: imageWidget,
        ),
        title: titleWidget,
        subtitle: subtitleWidget,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
      // child: Row(
      //   children: [
      //     Flexible(
      //       flex: 2,
      //       child: SizedBox.fromSize(
      //         size: imageSize,
      //         child: imageWidget,
      //       ),
      //     ),
      //     Expanded(
      //       flex: 5,
      //       child: ListTile(
      //         //leading: image,
      //         title: titleWidget,
      //         subtitle: subtitleWidget,
      //         onTap: onTap,
      //         onLongPress: onLongPress,
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}
