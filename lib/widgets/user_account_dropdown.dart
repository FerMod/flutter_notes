import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A material design that identifies the app's user.
///
/// Requires one of its ancestors to be a [Material] widget.
class UserAccountDropdown extends StatefulWidget {
  /// Creates a material design account widget.
  ///
  /// Requires one of its ancestors to be a [Material] widget.
  const UserAccountDropdown({
    super.key,
    this.decoration,
    this.margin = const EdgeInsets.only(bottom: 8.0),
    this.accountPicture,
    required this.accountName,
    required this.accountEmail,
    this.onTap,
    this.showArrow = false,
    this.arrowColor = Colors.white,
  });

  /// The height value of the account details.
  ///
  /// This defaults to a minimum height of `56.0` defined by [kToolbarHeight].
  static const double accountDetailsHeight = kToolbarHeight;

  /// The header's background. If decoration is null then a [BoxDecoration]
  /// with its background color set to the current theme's primaryColor is used.
  final Decoration? decoration;

  /// The margin around the drawer header.
  final EdgeInsetsGeometry margin;

  /// A widget placed in the left that represents the current user's account
  /// picture. Normally a [CircleAvatar].
  final Widget? accountPicture;

  /// A widget that represents the user's current account name. It is displayed
  /// on the right of the [accountPicture], on top of the [accountEmail].
  final Widget accountName;

  /// A widget that represents the email address of the user's current account.
  /// It is displayed on the right of the [accountPicture], below the
  /// [accountName].
  final Widget accountEmail;

  /// A callback that is called when the horizontal area which contains the
  /// [accountPicture], [accountName] and [accountEmail] is tapped.
  final VoidCallback? onTap;

  /// Show an arrow that responds to the user clicks.
  final bool showArrow;

  /// The [Color] of the arrow icon.
  final Color arrowColor;

  @override
  State<UserAccountDropdown> createState() => _UserAccountDropdownState();
}

class _UserAccountDropdownState extends State<UserAccountDropdown> {
  bool _isOpen = false;

  void _handleDetailsPressed() {
    setState(() {
      _isOpen = !_isOpen;
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: MaterialLocalizations.of(context).signedInLabel,
      child: Container(
        decoration: widget.decoration ??
            BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
        margin: widget.margin,
        //padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          top: false,
          bottom: false,
          child: _AccountDetails(
            accountPicture: widget.accountPicture,
            accountName: widget.accountName,
            accountEmail: widget.accountEmail,
            isOpen: _isOpen,
            onTap: widget.showArrow ? _handleDetailsPressed : widget.onTap,
            showArrow: widget.showArrow,
            arrowColor: widget.arrowColor,
          ),
        ),
      ),
    );
  }
}

class _AccountDetails extends StatefulWidget {
  const _AccountDetails({
    super.key,
    this.accountPicture,
    this.accountName,
    this.accountEmail,
    this.child,
    this.onTap,
    required this.isOpen,
    this.showArrow = false,
    this.arrowColor,
  });

  final Widget? accountPicture;
  final Widget? accountName;
  final Widget? accountEmail;
  final Widget? child;
  final VoidCallback? onTap;
  final bool isOpen;
  final bool showArrow;
  final Color? arrowColor;

  @override
  _AccountDetailsState createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<_AccountDetails> with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.showArrow) {
      _controller = AnimationController(
        value: widget.isOpen ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _animation = CurvedAnimation(
        parent: _controller!,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.fastOutSlowIn.flipped,
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_AccountDetails oldWidget) {
    super.didUpdateWidget(oldWidget);

    // We are not showing the arrow, there is no need to update the animation
    if (!widget.showArrow) return;

    // If the state of the arrow did not change, there is no need to trigger the
    // animation
    if (oldWidget.isOpen != widget.isOpen) {
      widget.isOpen ? _controller!.reverse() : _controller!.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasMaterialLocalizations(context));

    final theme = Theme.of(context);

    Widget accountDetails = CustomMultiChildLayout(
      delegate: _AccountDetailsLayout(
        textDirection: Directionality.of(context),
      ),
      children: [
        if (widget.accountPicture != null)
          LayoutId(
            id: _AccountDetailsLayout.accountPicture,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 8.0, 2.0),
              child: Semantics(
                explicitChildNodes: true,
                child: widget.accountPicture,
              ),
            ),
          ),
        if (widget.accountName != null)
          LayoutId(
            id: _AccountDetailsLayout.accountName,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: DefaultTextStyle(
                style: theme.primaryTextTheme.bodyLarge!,
                overflow: TextOverflow.ellipsis,
                child: widget.accountName as Widget,
              ),
            ),
          ),
        if (widget.accountEmail != null)
          LayoutId(
            id: _AccountDetailsLayout.accountEmail,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: DefaultTextStyle(
                style: theme.primaryTextTheme.bodyMedium!,
                overflow: TextOverflow.ellipsis,
                child: widget.accountEmail as Widget,
              ),
            ),
          ),
        if (widget.showArrow)
          LayoutId(
            id: _AccountDetailsLayout.dropdownIcon,
            child: _AnimatedArrow(
              animation: _animation,
              onTap: widget.onTap,
              height: UserAccountDropdown.accountDetailsHeight,
              width: UserAccountDropdown.accountDetailsHeight,
              color: widget.arrowColor,
            ),
          ),
      ],
    );

    if (widget.onTap != null) {
      accountDetails = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onTap,
          excludeFromSemantics: true,
          child: accountDetails,
        ),
      );
    }

    return SizedBox(
      height: UserAccountDropdown.accountDetailsHeight,
      child: accountDetails,
    );
  }
}

class _AccountDetailsLayout extends MultiChildLayoutDelegate {
  _AccountDetailsLayout({required this.textDirection});

  static const String accountPicture = 'accountPicture';
  static const String accountName = 'accountName';
  static const String accountEmail = 'accountEmail';
  static const String dropdownIcon = 'dropdownIcon';

  final TextDirection textDirection;

  @override
  void performLayout(Size size) {
    Size? iconSize;
    if (hasChild(dropdownIcon)) {
      // place the dropdown icon in bottom right (LTR) or bottom left (RTL)
      iconSize = layoutChild(dropdownIcon, BoxConstraints.loose(size));
      positionChild(dropdownIcon, _offsetForIcon(size, iconSize));
    }

    Size? pictureSize;
    if (hasChild(accountPicture)) {
      // place the picture in the right (LTR) or left (RTL)
      pictureSize = layoutChild(accountPicture, BoxConstraints.loose(size));
      positionChild(accountPicture, _offsetForPicture(size, pictureSize));
    }

    final bottomLine = hasChild(accountEmail) ? accountEmail : (hasChild(accountName) ? accountName : null);
    if (bottomLine != null) {
      iconSize ??= const Size(UserAccountDropdown.accountDetailsHeight, UserAccountDropdown.accountDetailsHeight);
      pictureSize ??= const Size(0.0, 0.0);

      final constraintSize = Size(size.width - iconSize.width - pictureSize.width, size.height);

      // place bottom line center at same height as icon center
      final bottomLineSize = layoutChild(bottomLine, BoxConstraints.loose(constraintSize));
      final bottomLineOffset = _offsetForBottomLine(size, iconSize, pictureSize, bottomLineSize);
      positionChild(bottomLine, bottomLineOffset);

      // place account name above account email
      if (bottomLine == accountEmail && hasChild(accountName)) {
        final nameSize = layoutChild(accountName, BoxConstraints.loose(constraintSize));
        positionChild(accountName, _offsetForName(size, nameSize, pictureSize, bottomLineOffset));
      }
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => true;

  // ignore: missing_return
  Offset _offsetForIcon(Size size, Size iconSize) {
    final y = size.height - iconSize.height;
    switch (textDirection) {
      case TextDirection.ltr:
        return Offset(size.width - iconSize.width, y);
      case TextDirection.rtl:
        return Offset(0.0, y);
    }
  }

  // ignore: missing_return
  Offset _offsetForPicture(Size size, Size pictureSize) {
    final y = size.height * 0.5 - pictureSize.height * 0.5;
    switch (textDirection) {
      case TextDirection.ltr:
        return Offset(0.0, y);
      case TextDirection.rtl:
        return Offset(size.width - pictureSize.width, y);
    }
  }

  // ignore: missing_return
  Offset _offsetForBottomLine(Size size, Size iconSize, Size pictureSize, Size bottomLineSize) {
    final y = size.height * 0.5;
    switch (textDirection) {
      case TextDirection.ltr:
        return Offset(pictureSize.width, y);
      case TextDirection.rtl:
        return Offset(size.width - pictureSize.width - bottomLineSize.width, y);
    }
  }

  // ignore: missing_return
  Offset _offsetForName(Size size, Size nameSize, Size pictureSize, Offset bottomLineOffset) {
    final y = bottomLineOffset.dy - nameSize.height;
    switch (textDirection) {
      case TextDirection.ltr:
        return Offset(pictureSize.width, y);
      case TextDirection.rtl:
        return Offset(size.width - pictureSize.width - nameSize.width, y);
    }
  }
}

class _AnimatedArrow extends AnimatedWidget {
  const _AnimatedArrow({
    super.key,
    this.onTap,
    this.height,
    this.width,
    this.color,
    required Animation<double> animation,
  }) : super(
          listenable: animation,
        );

  final Color? color;
  final double? height;
  final double? width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Animation value has changed
    final animation = listenable as Animation<double>;

    return Semantics(
      container: true,
      button: true,
      child: SizedBox(
        height: height,
        width: width,
        child: Center(
          child: Transform.rotate(
            angle: animation.value * math.pi,
            child: IconButton(
              icon: const Icon(Icons.arrow_drop_down),
              onPressed: onTap,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
