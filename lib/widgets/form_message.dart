import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'message.dart';

@immutable
class MessageData with Diagnosticable {
  const MessageData({
    this.isVisible = false,
    this.message,
    this.actions = const [],
  }) : assert(isVisible != null);

  const factory MessageData.empty() = MessageData;

  final bool isVisible;
  final String message;
  final List<Widget> actions;

  MessageData copyWith({
    bool isVisible,
    String message,
    List<Widget> actions,
  }) {
    return MessageData(
      isVisible: isVisible ?? this.isVisible,
      message: message ?? this.message,
      actions: actions ?? this.actions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is MessageData
        && other.isVisible == isVisible
        && other.message == message
        && other.actions == actions;
  }

  @override
  int get hashCode {
    return hashValues(
      isVisible,
      message,
      actions,
    );
  }
}

class Message extends StatefulWidget {
  const Message({
    Key key,
    this.data = const MessageData.empty(),
    this.onChange,
    @required this.child,
  })  : assert(child != null),
        assert(data != null),
        super(key: key);

  final MessageData data;
  final ValueChanged<MessageData> onChange;
  final Widget child;

  // static Message _scopeOf(BuildContext context) {
  //   assert(
  //     context != null,
  //     'Tried to call a function on a `context` that is `null`.\n'
  //     'This can happen if context of a StatefulWidget is used and that'
  //     'StatefulWidget was disposed.',
  //   );
  //   final inheritedMessage = context.dependOnInheritedWidgetOfExactType<_InheritedMessage>();
  //   return inheritedMessage?.message;
  // }
  //
  // static MessageData of(BuildContext context) {
  //   final scope = Message._scopeOf(context);
  //   return scope?.data;
  // }
  //
  // static void _update(BuildContext context, {bool isVisible, String message, List<Widget> actions}) {
  //   final scope = Message._scopeOf(context);
  //   if (scope != null) {
  //     final newModel = scope.data.copyWith(
  //       isVisible: isVisible,
  //       message: message,
  //       actions: actions,
  //     );
  //     scope.onChange?.call(newModel);
  //   }
  // }

  static MessageState of(BuildContext context) {
    assert(
      context != null,
      'Tried to call a function on a `context` that is `null`.\n'
      'This can happen if context of a StatefulWidget is used and that'
      'StatefulWidget was disposed.',
    );
    final inheritedMessage = context.dependOnInheritedWidgetOfExactType<_InheritedMessage>();
    return inheritedMessage?.message;
  }

  static MessageData dataOf(BuildContext context) {
    final inheritedMessage = Message.of(context);
    return inheritedMessage?.data;
  }

  static void show(BuildContext context, {String message, List<Widget> actions}) {
    Message.of(context).show(message: message, actions: actions);
  }

  static void hide(BuildContext context) {
    Message.of(context).hide();
  }

  @override
  MessageState createState() => MessageState();
}

class MessageState extends State<Message> {
  /// The data contained in the message
  MessageData data;

  @override
  void initState() {
    super.initState();
    data = widget.data;
  }

  @override
  void didUpdateWidget(covariant Message oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      data = widget.data;
    }
  }

  void _update({bool isVisible, String message, List<Widget> actions}) {
    final newData = data.copyWith(
      isVisible: isVisible,
      message: message,
      actions: actions,
    );
    _handleOnChange(newData);
  }

  void _handleOnChange(MessageData newData) {
    if (data != newData) {
      setState(() {
        data = newData;
      });
      widget.onChange?.call(newData);
    }
  }

  void show({String message, List<Widget> actions}) {
    _update(isVisible: true, message: message, actions: actions);
  }

  void hide() {
    _update(isVisible: false);
  }

  @override
  Widget build(BuildContext context) {
    var messageWidget = widget.child;
    if (data?.isVisible ?? false) {
      messageWidget = Column(
        children: [
          FormMessageWidget(onChange: _handleOnChange),
          messageWidget,
        ],
      );
    }

    return _InheritedMessage(
      message: this,
      child: messageWidget,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<MessageData>('data', widget.data, showName: false));
  }
}

class _InheritedMessage extends InheritedWidget {
  const _InheritedMessage({
    Key key,
    @required this.message,
    @required Widget child,
  })  : assert(message != null),
        super(key: key, child: child);

  final MessageState message;

  @override
  bool updateShouldNotify(_InheritedMessage old) => message.data != old.message.data;
}

class FormMessageWidget extends StatelessWidget {
  const FormMessageWidget({
    Key key,
    this.onChange,
  }) : super(key: key);

  final ValueChanged<MessageData> onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messageData = Message.of(context).data;

    Widget titleWidget;
    if (messageData.message != null) {
      titleWidget = SelectableText(messageData.message);
    }

    List<Widget> actionsList;
    if (messageData.actions.isEmpty) {
      final materialLocalizations = MaterialLocalizations.of(context);
      actionsList = [
        TextButton(
          child: Text(materialLocalizations.closeButtonLabel),
          onPressed: () => Message.hide(context),
        ),
      ];
    }

    Widget messageWidget = MessageWidget(
      leading: const Icon(Icons.warning_rounded),
      title: titleWidget,
      decoration: BoxDecoration(
        border: Border.all(
          width: 2.0,
          color: theme.colorScheme.error,
        ),
      ),
      actions: actionsList ?? messageData.actions,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(8.0),
      child: messageWidget,
    );
  }
}

@deprecated
class FormMessage extends StatelessWidget {
  const FormMessage({
    Key key,
    this.messageData,
    this.onChange,
  }) : super(key: key);

  final MessageData messageData;
  final ValueChanged<MessageData> onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget titleWidget;
    if (messageData.message != null) {
      titleWidget = SelectableText(messageData.message);
    }

    List<Widget> actionsList;
    if (messageData.actions.isEmpty) {
      final materialLocalizations = MaterialLocalizations.of(context);
      actionsList = [
        TextButton(
          child: Text(materialLocalizations.closeButtonLabel),
          onPressed: () => Message.hide(context),
        ),
      ];
    }
    Widget messageWidget = MessageWidget(
      // visible: messageData.isVisible,
      leading: const Icon(Icons.warning_rounded),
      title: titleWidget,
      decoration: BoxDecoration(
          border: Border.all(
        width: 2.0,
        color: theme.colorScheme.error,
      )),
      actions: actionsList ?? messageData.actions,
    );

    return messageData.isVisible
        ? Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.all(8.0),
            child: messageWidget,
          )
        : SizedBox.shrink();
  }
}