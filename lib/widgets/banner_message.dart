import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Signature for a function that creates a widget with a message.
///
/// Used by [BannerMessage.messageBuilder].
typedef MessageWidgetBuilder = Widget Function(BuildContext context, BannerMessageData message);

@immutable
class BannerMessageData with Diagnosticable {
  const BannerMessageData({
    this.isVisible = false,
    this.message,
    this.actions = const <Widget>[],
  });

  const factory BannerMessageData.empty() = BannerMessageData;

  final bool isVisible;
  final String? message;
  final List<Widget> actions;

  BannerMessageData copyWith({
    bool? isVisible,
    String? message,
    List<Widget>? actions,
  }) {
    return BannerMessageData(
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
    final listEquals = const DeepCollectionEquality().equals;

    return other is BannerMessageData && other.isVisible == isVisible && other.message == message && listEquals(other.actions, actions);
  }

  @override
  int get hashCode {
    return hashValues(
      isVisible,
      message,
      hashList(actions),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('isVisible', value: isVisible, ifTrue: 'true', ifFalse: 'false', showName: true));
    properties.add(StringProperty('message', message));
    properties.add(IterableProperty<Widget>('actions', actions));
  }
}

class BannerMessage extends StatefulWidget {
  const BannerMessage({
    Key? key,
    BannerMessageData data = const BannerMessageData.empty(),
    this.onChange,
    required this.messageBuilder,
    required this.child,
  })  : _data = data,
        super(key: key);

  final BannerMessageData _data;
  final ValueChanged<BannerMessageData>? onChange;
  final MessageWidgetBuilder messageBuilder;
  final Widget child;

  static BannerMessageState? of(BuildContext context) {
    final inheritedMessage = context.dependOnInheritedWidgetOfExactType<_InheritedMessage>();
    return inheritedMessage?.message;
  }

  static BannerMessageData? dataOf(BuildContext context) {
    final messageState = BannerMessage.of(context);
    return messageState?.data;
  }

  static MessageController<T?> show<T extends Object?>(BuildContext context, {String? message, List<Widget>? actions}) {
    return BannerMessage.of(context)!.show(message: message, actions: actions);
  }

  static void hide<T extends Object?>(BuildContext context, [T? result]) {
    BannerMessage.of(context)!.hide(result);
  }

  @override
  BannerMessageState createState() => BannerMessageState();
}

/// The state for a [BannerMessage] widget.
///
/// A reference to this class can be obtained by calling [BannerMessage.of].
class BannerMessageState extends State<BannerMessage> {
  /// The data contained in the message.
  late BannerMessageData data;

  MessageController? _messageController;

  @override
  void initState() {
    super.initState();
    data = widget._data;
  }

  @override
  void didUpdateWidget(BannerMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget._data != oldWidget._data) {
      data = widget._data;
    }
  }

  void _update({bool? isVisible, String? message, List<Widget>? actions}) {
    final newData = data.copyWith(
      isVisible: isVisible,
      message: message,
      actions: actions,
    );
    _handleOnChange(newData);
  }

  void _handleOnChange(BannerMessageData newData) {
    if (data == newData) return;
    setState(() {
      data = newData;
    });
    widget.onChange?.call(newData);
  }

  MessageController<T?> show<T extends Object?>({String? message, List<Widget>? actions}) {
    _messageController ??= MessageController<T>._(Completer<T>(), hide);
    _update(isVisible: true, message: message, actions: actions);
    return _messageController as MessageController<T>;
  }

  void hide<T extends Object?>([T? result]) {
    _update(isVisible: false);
    _messageController?._completer.complete(result);
  }
  @override
  Widget build(BuildContext context) {
    return _InheritedMessage(
      message: this,
      data: data,
      child: Column(
        children: [
          data.isVisible ? widget.messageBuilder(context, data) : const SizedBox.shrink(),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    data.debugFillProperties(properties);
  }
}

class _InheritedMessage extends InheritedWidget {
  const _InheritedMessage({
    Key? key,
    required this.message,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  final BannerMessageState message;
  final BannerMessageData data;

  @override
  bool updateShouldNotify(_InheritedMessage old) => data != old.data;
}

/// An interface for controlling a message.
///
/// Commonly obtained from [BannerMessage.show].
class MessageController<T> {
  const MessageController._(this._completer, this.close);

  /// Completes when the message controlled by this object is no longer visible.
  Future<T?> get closed => _completer.future;
  final Completer<T?> _completer;

  /// Remove the message.
  final void Function(T? result) close;
}
