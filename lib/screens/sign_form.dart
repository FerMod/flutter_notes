import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../widgets/drawer_menu.dart';
import '../widgets/form_message.dart';

/// Signature for reporting errors throwed from the form.
typedef FormErrorListener = void Function(Object exception, StackTrace stackTrace);

class SignFormScreen extends StatelessWidget {
  const SignFormScreen({
    Key? key,
    this.title,
    this.builder,
  }) : super(key: key);

  /// The [AppBar.title] title widget.
  final Widget? title;

  /// The content of this widget.
  final WidgetBuilder? builder;

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;

    BoxConstraints? constraints;
    if (isWeb) {
      final textScaleFactor = MediaQuery.textScaleFactorOf(context);
      final desktopMaxWidth = 400.0 + 100.0 * (textScaleFactor - 1);
      constraints = BoxConstraints(maxWidth: desktopMaxWidth);
    }

    final childWidget = Scrollbar(
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: constraints,
            child: Builder(builder: builder!),
          ),
        ),
      ),
    );

    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: title,
        ),
        drawer: DrawerMenu(),
        body: Message(
          child: childWidget,
        ),
      ),
    );
  }
}
