import 'package:flutter/material.dart';

import '../src/utils/device_type.dart';
import '../widgets/banner_message.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/message.dart';
import 'settings.dart';

class SignFormScreen extends StatelessWidget {
  const SignFormScreen({
    super.key,
    this.title,
    required this.builder,
  });

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
        body: BannerMessage(
          messageBuilder: (context, message) => _MessageCard(message: message),
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (DeviceType.isDesktopOrWeb) {
                  final textScaleFactor = MediaQuery.textScalerOf(context);
                  final desktopMaxWidth = 400.0 + 100.0 * (textScaleFactor.textScaleFactor - 1);
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
    super.key,
    required this.message,
  });

  final MessageData message;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasBannerMessage(context));

    final theme = Theme.of(context);
    final MessageData data = message;

    Widget? titleWidget;
    if (data.message != null) {
      titleWidget = SelectableText(data.message!);
    }

    List<Widget>? actionsList;
    if (data.actions.isEmpty) {
      final materialLocalizations = MaterialLocalizations.of(context);
      actionsList = <Widget>[
        TextButton(
          onPressed: () => BannerMessage.hide(context),
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
    super.key,
    required this.child,
  });

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
