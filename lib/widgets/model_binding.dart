import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Code derived from:
// https://medium.com/flutter/managing-flutter-application-state-with-inheritedwidgets-1140452befe1
// https://gist.github.com/HansMuller/a3a6d520c6a24238bf1b1b9e3d473bf5

/// Signature for [ModelBinding.dispose].
typedef Dispose<T> = void Function(BuildContext context, T value);

class _ModelBindingScope<T> extends InheritedWidget {
  const _ModelBindingScope({
    super.key,
    required this.model,
    required this.modelBindingState,
    bool updateShouldNotify = false,
    required super.child,
  }) : _updateShouldNotify = updateShouldNotify;

  final T model;
  final _ModelBindingState<T> modelBindingState;
  final bool _updateShouldNotify;

  static _ModelBindingScope<T>? of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ModelBindingScope<T>>();
  }

  @override
  bool updateShouldNotify(_ModelBindingScope<T> old) {
    return model != old.model || _updateShouldNotify;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<T>('model', model));
  }
}

/// A generic implementation of an [InheritedWidget].
///
/// Any descendant of this widget can obtain [initialModel] with an instance of
/// [ModelBinding] returned by [ModelBinding.of].
class ModelBinding<T> extends StatefulWidget {
  /// Creates a widget that provides the [ModelBinding] model data to its
  /// descendants.
  ///
  /// A least a [child] or a [builder] must be provided.
  const ModelBinding({
    super.key,
    required this.initialModel,
    this.child,
    this.builder,
    this.dispose,
  }) : assert(
          child != null || builder != null,
          'Must provide at least a child or a builder',
        );

  /// Contains the model data.
  final T initialModel;

  /// The widget below this widget in the tree.
  final Widget? child;

  /// Called to obtain the [child] widget from this callback, every time the
  /// [initialModel] value changes.
  ///
  /// This builder builds a widget given a [BuildContext] (as `context`) and a
  /// [Widget] (as `child`). If the child is `null`, it is the responsibility of
  /// the [builder] to provide a valid one.
  ///
  /// If [builder] is null, it is as if a builder was specified that returned
  /// the [child] directly.
  final TransitionBuilder? builder;

  /// A callback invoked when this widget is about to be removed from the tree
  /// permanently.
  final Dispose<T>? dispose;

  /// Returns the [ModelBinding] widgets [initialModel] from the closest
  /// instance of this class that encloses the given context.
  ///
  /// You can use this function to obtain the [initialModel]. When that
  /// information changes, your widget will be scheduled to be rebuilt, keeping
  /// your widget up-to-date.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// T model = ModelBinding.of<T>(context);
  /// ```
  ///
  /// If there is no [ModelBinding] in scope, then this will assert in
  /// debug mode, and throw an exception in release mode.
  ///
  /// See also:
  ///
  ///  * [maybeOf], which is a similar function but will return null instead of
  ///    throwing if there is no [ModelBinding] ancestor.
  ///  * [debugCheckHasModelBinding], which asserts that the given context
  ///    has a [ModelBinding] ancestor.
  static T of<T>(BuildContext context) {
    assert(
      // ignore: unnecessary_null_comparison
      context != null,
      'Tried to call ModelBinding.of<$T> on a `context` that is `null`.\n'
      'This can happen if context of a StatefulWidget is used and that '
      'StatefulWidget was disposed.',
    );
    assert(
      T != dynamic,
      'Tried to call ModelBinding.of<dynamic>.\n'
      'If you want to expose a variable that can be anything, consider '
      'replacing `dynamic` with `Object` instead.',
    );
    assert(debugCheckHasModelBinding<T>(context));

    final scope = _ModelBindingScope.of<T>(context)!;
    return scope.modelBindingState.currentModel;
  }

  /// Returns the [ModelBinding] widgets [initialModel] from the closest
  /// instance of this class that encloses the given context, if any.
  ///
  /// Use this function if you want to allow situations where no [ModelBinding]
  /// is in scope. Prefer using [ModelBinding.of] in situations where a
  /// [ModelBinding] is always expected to exist.
  ///
  /// If there is no [ModelBinding] in scope, then this function will return
  /// null.
  ///
  /// You can use this function to obtain the [initialModel]. When that
  /// information changes, your widget will be scheduled to be rebuilt, keeping
  /// your widget up-to-date.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// T? model = ModelBinding.maybeOf<T>(context);
  /// if (model == null) {
  ///   // Do something else instead.
  /// }
  /// ```
  ///
  /// See also:
  ///
  ///  * [of], which is a similar function, except that it will throw an
  ///   exception if a [ModelBinding] is not found in the given context.
  static T? maybeOf<T>(BuildContext context) {
    assert(
      // ignore: unnecessary_null_comparison
      context != null,
      'Tried to call ModelBinding.maybeOf<$T> on a `context` that is `null`.\n'
      'This can happen if context of a StatefulWidget is used and that '
      'StatefulWidget was disposed.',
    );
    assert(
      T != dynamic,
      'Tried to call ModelBinding.maybeOf<dynamic>.\n'
      'If you want to expose a variable that can be anything, consider '
      'replacing `dynamic` with `Object` instead.',
    );

    final scope = _ModelBindingScope.of<T>(context);
    return scope?.modelBindingState.currentModel;
  }

  /// Updates the model that corresponds to the given [context] with the new
  /// given one and notifies the framework that the internal state of this
  /// object has changed.
  ///
  /// If [updateShouldNotify] is true, it will cause to rebuild the widget
  /// regardless of the current model being the same as the [newModel] one.
  ///
  /// Returns true if the model will update with a new one, false if the model
  /// has not changed.
  ///
  /// If there is no [ModelBinding] in scope, then this will assert in debug
  /// mode, and throw an exception in release mode.
  ///
  /// See also:
  ///
  ///  * [debugCheckHasModelBinding], which asserts that the given context
  ///    has a [ModelBinding] ancestor.
  static bool update<T>(BuildContext context, T newModel, {bool updateShouldNotify = false}) {
    assert(
      // ignore: unnecessary_null_comparison
      context != null,
      'Tried to call ModelBinding.update<$T> on a `context` that is `null`.\n'
      'This can happen if context of a StatefulWidget is used and that '
      'StatefulWidget was disposed.',
    );
    assert(
      T != dynamic,
      'Tried to call ModelBinding.update<dynamic>.\n'
      'If you want to expose a variable that can be anything, consider '
      'replacing `dynamic` with `Object` instead.',
    );
    assert(debugCheckHasModelBinding<T>(context));

    final scope = _ModelBindingScope.of<T>(context)!;
    return scope.modelBindingState.updateModel(newModel, updateShouldNotify: updateShouldNotify);
  }

  @override
  State<ModelBinding<T>> createState() => _ModelBindingState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<T>('initialModel', initialModel));
  }
}

class _ModelBindingState<T> extends State<ModelBinding<T>> {
  late T _currentModel;
  T get currentModel => _currentModel;

  bool _updateShouldNotify = false;

  @override
  void initState() {
    super.initState();
    _currentModel = widget.initialModel;
  }

  @override
  void dispose() {
    widget.dispose?.call(context, _currentModel);
    super.dispose();
  }

  @override
  void didUpdateWidget(ModelBinding<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialModel != oldWidget.initialModel) {
      _currentModel = widget.initialModel;
    }
  }

  /// Updates its model with the new given one and notifies the framework that
  /// the internal state of this object has changed.
  ///
  /// If the [newModel] is different from the current model, [setState] will be
  /// called, which causes the framework to schedule a [build] for this [State]
  /// object.
  ///
  /// If [updateShouldNotify] is true, it will notify regardless of the current
  /// model being the same as the [newModel] one.
  ///
  /// Returns true if the model changed, causing to rebuild to reflect the
  /// changes.
  bool updateModel(T newModel, {bool updateShouldNotify = false}) {
    _updateShouldNotify = updateShouldNotify;

    final shouldUpdate = _currentModel != newModel;
    if (shouldUpdate || _updateShouldNotify) {
      setState(() {
        _currentModel = newModel;
      });
    }
    return shouldUpdate;
  }

  @override
  Widget build(BuildContext context) {
    return _ModelBindingScope<T>(
      model: _currentModel,
      updateShouldNotify: _updateShouldNotify,
      modelBindingState: this,
      child: widget.builder != null
          ? Builder(
              builder: (context) => widget.builder!(context, widget.child),
            )
          : widget.child!,
    );
  }
}

/// Asserts that the given context has a [ModelBinding] widget ancestor of type
/// [T] in its tree.
///
/// Used by various widgets to make sure that they are only used in an
/// appropriate context.
///
/// To invoke this function, use the following pattern, typically in the
/// relevant Widget's build method:
///
/// ```dart
/// assert(debugCheckHasModelBinding<MyType>(context));
/// ```
///
/// Does nothing if asserts are disabled. Always returns true.
bool debugCheckHasModelBinding<T>(BuildContext context) {
  assert(() {
    if (context.widget is! _ModelBindingScope<T> && context.findAncestorWidgetOfExactType<_ModelBindingScope<T>>() == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('No ModelBinding<$T> widget ancestor found.'),
        ErrorDescription('${context.widget.runtimeType} widget require a ModelBinding<$T> widget ancestor.'),
        context.describeWidget('The specific widget that could not find a ModelBinding<$T> ancestor was'),
        context.describeOwnershipChain('The ownership chain for the affected widget is'),
        ErrorHint(
          'No ModelBinding<$T> ancestor could be found starting from the context '
          'that was passed to ModelBinding.of<$T>(). This can happen because you '
          'have not added a ModelBinding<$T> widget, or it can happen if the '
          'context you use comes from a widget above that widget.',
        ),
      ]);
    }
    return true;
  }());
  return true;
}
