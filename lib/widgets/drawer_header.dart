import 'package:flutter/material.dart';

class TitleDrawerHeader extends StatelessWidget {
  const TitleDrawerHeader({
    Key key,
    this.margin = const EdgeInsets.only(bottom: 8.0),
    this.padding = const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.fastOutSlowIn,
    @required this.child,
  }) : super(key: key);

  final EdgeInsets margin;
  final EdgeInsets padding;
  final Duration duration;
  final Curve curve;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return SafeArea(
      top: false,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: theme.primaryColor,
          border: Border(
            bottom: Divider.createBorderSide(context),
          ),
        ),
        child: AnimatedContainer(
          padding: padding.add(EdgeInsets.only(top: statusBarHeight)),
          duration: duration,
          curve: curve,
          child: child,
        ),
      ),
    );
  }
}

@deprecated
class AccountDrawerHeader extends StatelessWidget {
  const AccountDrawerHeader({
    Key key,
    this.margin = const EdgeInsets.only(bottom: 8.0),
    this.padding = const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.fastOutSlowIn,
    @required this.child,
  }) : super(key: key);

  final EdgeInsets margin;
  final EdgeInsets padding;
  final Duration duration;
  final Curve curve;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TitleDrawerHeader(
      margin: margin,
      padding: padding,
      duration: duration,
      curve: curve,
      child: UserAccountsDrawerHeader(
        currentAccountPicture: null,
        accountName: null,
        accountEmail: null,
        onDetailsPressed: () {},
        otherAccountsPictures: [],
      ),
    );
  }
}
