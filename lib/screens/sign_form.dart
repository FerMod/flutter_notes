import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes/src/utils/device_type.dart';
import 'package:flutter_notes/widgets/message.dart';

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
    return DismissibleKeyboard(
      child: Scaffold(
        appBar: AppBar(
          title: title,
          actions: const [
            SettingsScreenButton(),
          ],
        ),
        drawer: DrawerMenu(),
        body: Message(
          messageBuilder: (context, message) => _MessageCard(message: message),
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (DeviceType.isDesktopOrWeb) {
                  final textScaleFactor = MediaQuery.textScaleFactorOf(context);
                  final desktopMaxWidth = 400.0 + 100.0 * (textScaleFactor - 1);
                  constraints = constraints.copyWith(maxWidth: desktopMaxWidth);
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: constraints,
                    child: Builder(builder: builder),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    Key? key,
    required this.message,
  }) : super(key: key);

  final MessageData message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final MessageData data = message;

    Widget? titleWidget;
    if (data.message != null) {
      titleWidget = SelectableText(data.message!);
    }

    List<Widget>? actionsList;
    if (data.actions.isEmpty) {
      final materialLocalizations = MaterialLocalizations.of(context);
      actionsList = [
        TextButton(
          onPressed: () => Message.hide(context),
          child: Text(materialLocalizations.closeButtonLabel),
        ),
      ];
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(8.0),
      child: MessageWidget(
        leading: const Icon(Icons.warning_rounded),
        content: titleWidget,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2.0,
            color: theme.colorScheme.error,
          ),
        ),
        actions: actionsList ?? data.actions,
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
