import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes/src/utils/device_type.dart';

import '../widgets/drawer_menu.dart';
import '../widgets/form_message.dart';
import 'settings.dart';

class SignFormScreen extends StatelessWidget {
  const SignFormScreen({
    Key? key,
    this.title,
    required this.builder,
  }) : super(key: key);

  /// The [AppBar.title] title widget.
  final Widget? title;

  /// The content of this widget.
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final childWidget = LayoutBuilder(
      builder: (context, constraints) {
        if (DeviceType.isDesktopOrWeb) {
          final textScaleFactor = MediaQuery.textScaleFactorOf(context);
          final desktopMaxWidth = 400.0 + 100.0 * (textScaleFactor - 1);
          constraints = constraints.copyWith(maxWidth: desktopMaxWidth);
        }

        return Center(
          child: Container(
            constraints: constraints,
            child: Builder(builder: builder),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: const [
          SettingsScreenButton(),
        ],
      ),
      drawer: DrawerMenu(),
      body: Message(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: childWidget,
          ),
        ),
      ),
    );
  }
}

/// A widget that allows to remove focus by tapping outside a focusable widget.
class DismissibleKeyboard extends StatelessWidget {
  /// Creates a widget that allows the keyboard to be be dismissed. When a tap
  /// is detected in a non focusable widget in the [child], unfocuses from the
  /// last element, hiding the keyboard.
  ///
  /// The [child] argument is required and must not be null.
  const DismissibleKeyboard({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          currentFocus.unfocus();
        }
      },
      child: child,
    );
  }
}
