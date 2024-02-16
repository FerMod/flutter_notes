import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Signature for a function that builds a [Widget] that uses the given [value].
///
/// Used by [BannerMessage.messageBuilder].
typedef MessageBuilder<T> = Widget Function(BuildContext context, T value);

@immutable
class MessageData with Diagnosticable {
  const MessageData({
    this.isVisible = false,
    this.message,
    this.actions = const <Widget>[],
  });

  const factory MessageData.empty() = MessageData;

  final bool isVisible;
  final String? message;
  final List<Widget> actions;

  MessageData copyWith({
    bool? isVisible,
    String? message,
    List<Widget>? actions,
  }) {
    return MessageData(
      isVisible: isVisible ?? this.isVisible,
      message: message ?? this.message,
      actions: actions ?? this.actions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    final listEquals = const DeepCollectionEquality().equals;
    return other is MessageData && other.isVisible == isVisible && other.message == message && listEquals(other.actions, actions);
  }

  @override
  int get hashCode {
    return Object.hash(
      isVisible,
      message,
      Object.hashAll(actions),
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

/// Manages banner messages for descendant widgets. This class provides APIs to
/// handle banner messages.
///
/// To display a banner message, obtain the [BannerMessageState] for the current
/// [BuildContext] via [BannerMessage.of] and use the [BannerMessageState.show].
/// To hide the banner message, the same steps as before can be followed, but
/// instead using the function [BannerMessageState.hide].
///
/// Alternatively, the functions [BannerMessage.show] and [BannerMessage.hide]
/// can be used to achieve the same goals.
///
/// See also:
///
///  * [MessageWidget], which is a temporary notification typically shown at the
///    top of the screen below the app bar.
///  * [debugCheckHasBannerMessage], which asserts that the given context
///    has a [BannerMessage] ancestor.
class BannerMessage extends StatefulWidget {
  /// Creates a widget that manages banner message widgets for the [child] and
  /// its descendants using the created widget by the [messageBuilder] callback.
  ///
  /// The [messageBuilder] callback is only called when the message is visible,
  /// and when its content changes.
  ///
  /// The [data] parameter can be used to start with the given initial message
  /// stored. If the [MessageData.isVisible] is true, the message content will
  /// be shown when the [BannerMessage] is built. By default the message data
  /// will be initialized with [MessageData.empty].
  ///
  /// The [child] and [messageBuilder] are required parameters, and must not be
  /// null.
  const BannerMessage({
    super.key,
    this.data = const MessageData.empty(),
    required this.messageBuilder,
    required this.child,
  });

  final MessageData data;
  final MessageBuilder<MessageData> messageBuilder;
  final Widget child;

  /// Returns the [BannerMessageState] from the closest instance of
  /// [BannerMessage] that encloses the given [context].
  ///
  /// If there is no [BannerMessage] in scope, then this will assert in
  /// debug mode, and throw an exception in release mode.
  ///
  /// See also:
  ///
  ///  * [maybeOf], which is a similar function but will return null instead of
  ///    throwing if there is no [BannerMessage] ancestor.
  ///  * [debugCheckHasBannerMessage], which asserts that the given context
  ///    has a [BannerMessage] ancestor.
  static BannerMessageState of(BuildContext context) {
    assert(debugCheckHasBannerMessage(context));

    final scope = context.dependOnInheritedWidgetOfExactType<_BannerMessageScope>()!;
    return scope.bannerMessageState;
  }

  /// Returns the [BannerMessageState] from the closest instance of
  /// [BannerMessage] that encloses the given [context], if any.
  ///
  /// If there is no [BannerMessage] in scope, then this function will return
  /// null.
  ///
  /// See also:
  ///
  ///  * [of], which is a similar function, except that it will throw an
  ///    exception if a [BannerMessage] is not found in the given context.
  static BannerMessageState? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_BannerMessageScope>();
    return scope?.bannerMessageState;
  }

  /// Returns the [MessageData] from the closest instance of [BannerMessage]
  /// that encloses the given [context].
  ///
  /// If there is no [BannerMessage] in scope, then this will assert in debug
  /// mode, and throw an exception in release mode.
  ///
  /// See also:
  ///
  ///  * [debugCheckHasBannerMessage], which asserts that the given context
  ///   has a [BannerMessage] ancestor.
  static MessageData dataOf(BuildContext context) {
    assert(debugCheckHasBannerMessage(context));

    final scope = context.dependOnInheritedWidgetOfExactType<_BannerMessageScope>()!;
    return scope.data;
  }

  /// Makes visible a message that most tightly encloses the given [context].
  /// The message text can be provided with the parameter [message] text and list of
  /// [actions].
  ///
  /// To remove the message use [BannerMessage.hide] or call
  /// [MessageController.close] on the returned [MessageController].
  ///
  /// The [T] type argument is the type of the return value of the message.
  ///
  /// If there is no [BannerMessage] in scope, then this will assert in debug
  /// mode, and throw an exception in release mode.
  static MessageController<T?> show<T>(BuildContext context, {String? message, List<Widget>? actions}) {
    return BannerMessage.of(context).show(message: message, actions: actions);
  }

  /// Hides the message that most tightly encloses the given [context].
  ///
  /// If non-null, [result] will be used as the result of the message that is
  /// closed.
  ///
  /// The [T] type argument is the type of the return value of the closed
  /// message.
  ///
  /// If there is no [BannerMessage] in scope, then this will assert in debug
  /// mode, and throw an exception in release mode.
  static void hide<T>(BuildContext context, [T? result]) {
    BannerMessage.of(context).hide(result);
  }

  @override
  BannerMessageState createState() => BannerMessageState();
}

/// The state for a [BannerMessage] widget.
///
/// A reference to this class can be obtained by calling [BannerMessage.of].
class BannerMessageState extends State<BannerMessage> {
  /// The data contained in the message.
  MessageData get data => _data;
  late MessageData _data;

  /// The object that provides some control over the displayed message.
  MessageController<Object?>? get messageController => _messageController;
  MessageController<Object?>? _messageController;

  @override
  void initState() {
    super.initState();
    _data = widget.data;
  }

  @override
  void didUpdateWidget(BannerMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _data = widget.data;
    }
  }

  /// Makes visible a message that most tightly encloses the given [context].
  /// The message text can be provided with the parameter [message] text and
  /// list of [actions].
  ///
  /// The type argument [T] is the message's result return type. The type
  /// `void` may be used if it does not return a value.
  MessageController<T> show<T>({String? message, List<Widget>? actions}) {
    _update(isVisible: true, message: message, actions: actions);
    _messageController ??= MessageController<T>._(Completer<T>(), hide);
    return _messageController as MessageController<T>;
  }

  /// Hides the message that most tightly encloses the given [context].
  ///
  /// If non-null, [result] will be used as the result of the message that is
  /// closed.
  ///
  /// The type argument [T] is the message's result return type. The type
  /// `void` may be used if it does not return a value.
  void hide<T>([T? result]) {
    _update(isVisible: false);
    final isClosed = _messageController?.isClosed ?? true;
    if (!isClosed) {
      _messageController!._completer.complete(result);
      _messageController = null;
    }
  }

  void _update({bool? isVisible, String? message, List<Widget>? actions}) {
    final newData = data.copyWith(
      isVisible: isVisible,
      message: message,
      actions: actions,
    );

    if (data != newData) {
      setState(() {
        _data = newData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BannerMessageScope(
      bannerMessageState: this,
      data: data,
      child: Column(
        children: [
          if (data.isVisible) widget.messageBuilder(context, data),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<MessageData>('data', data));
    properties.add(DiagnosticsProperty<MessageController?>('messageController', messageController));
  }
}

class _BannerMessageScope<T> extends InheritedWidget {
  const _BannerMessageScope({
    super.key,
    required this.bannerMessageState,
    required this.data,
    required super.child,
  });

  final BannerMessageState bannerMessageState;
  final MessageData data;

  @override
  bool updateShouldNotify(_BannerMessageScope old) => data != old.data || bannerMessageState != old.bannerMessageState;
}

/// An interface for controlling a message of a [BannerMessage].
///
/// Commonly obtained from [BannerMessage.show].
class MessageController<T> {
  const MessageController._(this._completer, this.close);

  /// Completes when the message controlled by this object is no longer visible.
  Future<T> get closed => _completer.future;
  final Completer<T> _completer;

  /// Whether the [closed] future has been completed. Reflects whether
  /// [Completer.complete] or [Completer.completeError] has been called.
  ///
  /// When this value is `true`, calls to [close] with a result does not change
  /// the already existing value of [closed].

  bool get isClosed => _completer.isCompleted;

  /// Remove the message that completes with the given `result`.
  final void Function([T? result]) close;
}

/// Asserts that the given context has a [BannerMessage] widget ancestor in
/// its tree.
///
/// Used by various widgets to make sure that they are only used in an
/// appropriate context.
///
/// To invoke this function, use the following pattern, typically in the
/// relevant Widget's build method:
///
/// ```dart
/// assert(debugCheckHasBannerMessage(context));
/// ```
///
/// Does nothing if asserts are disabled. Always returns true.
bool debugCheckHasBannerMessage(BuildContext context) {
  assert(() {
    if (context.widget is! _BannerMessageScope && context.findAncestorWidgetOfExactType<_BannerMessageScope>() == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('No $BannerMessage widget ancestor found.'),
        ErrorDescription('${context.widget.runtimeType} widget requires a $BannerMessage widget ancestor.'),
        context.describeWidget('The specific widget that could not find a $BannerMessage ancestor was'),
        context.describeOwnershipChain('The ownership chain for the affected widget is'),
        ErrorHint(
          'No $BannerMessage ancestor could be found starting from the context '
          'that was passed to $BannerMessage.of(). This can happen because you '
          'have not added a $BannerMessage widget, or it can happen if the '
          'context you use comes from a widget above that widget.',
        ),
      ]);
    }
    return true;
  }());
  return true;
}
