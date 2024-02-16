import 'package:flutter/material.dart';

class TitleDrawerHeader extends StatelessWidget {
  const TitleDrawerHeader({
    super.key,
    this.decoration,
    this.margin = const EdgeInsets.only(bottom: 8.0),
    this.padding = const EdgeInsets.all(16.0),
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.fastOutSlowIn,
    required this.child,
  });

  final Decoration? decoration;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Duration duration;
  final Curve curve;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Ink(
      padding: margin,
      decoration: BoxDecoration(
        color: theme.primaryColor,
        border: Border(
          bottom: Divider.createBorderSide(context),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: AnimatedContainer(
          decoration: decoration,
          padding: padding,
          duration: duration,
          curve: curve,
          child: child,
        ),
      ),
    );
  }
}
