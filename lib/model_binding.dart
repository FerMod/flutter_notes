import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Code derived from:
// https://medium.com/flutter/managing-flutter-application-state-with-inheritedwidgets-1140452befe1
// https://gist.github.com/HansMuller/a3a6d520c6a24238bf1b1b9e3d473bf5

class _ModelBindingScope<T> extends InheritedWidget {
  const _ModelBindingScope({
    Key? key,
    required this.model,
    required this.modelBindingState,
    bool updateShouldNotify = false,
    required Widget child,
  })   : _updateShouldNotify = updateShouldNotify,
        super(key: key, child: child);

  final T model;
  final _ModelBindingState<T> modelBindingState;
  final bool _updateShouldNotify;

  @override
  bool updateShouldNotify(_ModelBindingScope<T> old) {
    return model != old.model || _updateShouldNotify;
  }
}

/// A generic implementation of an [InheritedWidget].
///
/// Any descendant of this widget can obtain [initialModel] with an instance of
/// [ModelBinding] returned by [ModelBinding.of].
class ModelBinding<T> extends StatefulWidget {
  /// Creates a widget that provides the [ModelBinding] model data to its
  /// descendants.
  const ModelBinding({
    Key? key,
    required this.initialModel,
    required this.child,
  }) : super(key: key);

  /// Contains the model data.
  final T initialModel;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  _ModelBindingState<T> createState() => _ModelBindingState<T>();

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
  /// If there is no [ModelBinding] in scope, this will throw a [TypeError]
  /// exception in release builds, and throw a descriptive [FlutterError] in
  /// debug builds.
  ///
  /// See also:
  ///
  ///  * [maybeOf], which doesn't throw or assert if it doesn't find a
  ///    [ModelBinding] ancestor, it returns null instead.
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

    final scope = context.dependOnInheritedWidgetOfExactType<_ModelBindingScope<T>>()!;
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
  ///  * [of], which will throw if it doesn't find a [ModelBinding] ancestor,
  ///    instead of returning null.
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
      'Tried to call ModelBinding.of<dynamic>.\n'
      'If you want to expose a variable that can be anything, consider '
      'replacing `dynamic` with `Object` instead.',
    );

    final scope = context.dependOnInheritedWidgetOfExactType<_ModelBindingScope<T>>();
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

    final scope = context.dependOnInheritedWidgetOfExactType<_ModelBindingScope<T>>()!;
    //assert(scope != null, 'a ModelBinding<T> ancestor was not found');
    return scope.modelBindingState.updateModel(newModel, updateShouldNotify: updateShouldNotify);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<T>('initialModel', initialModel));
  }
}

class _ModelBindingState<T> extends State<ModelBinding<T>> {
  final GlobalKey _modelBindingScopeKey = GlobalKey();

  late T _currentModel;
  T get currentModel => _currentModel;
  late bool _updateShouldNotify;

  @override
  void initState() {
    super.initState();
    _updateShouldNotify = false;
    _currentModel = widget.initialModel;
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
      key: _modelBindingScopeKey,
      model: _currentModel,
      updateShouldNotify: _updateShouldNotify,
      modelBindingState: this,
      child: widget.child,
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
        ErrorSummary('No ModelBinding<$T> widget found.'),
        ErrorDescription('${context.widget.runtimeType} widgets require a ModelBinding<$T> widget ancestor.'),
        context.describeWidget('The specific widget that could not find a ModelBinding<$T> ancestor was'),
        context.describeOwnershipChain('The ownership chain for the affected widget is'),
        ErrorHint(
          'No ModelBinding<$T> ancestor could be found starting from the context '
          'that was passed to ModelBinding<$T>.of(). This can happen because you '
          'have not added a ModelBinding<$T> widget, or it can happen if the '
          'context you use comes from a widget above that widgets.',
        ),
      ]);
    }
    return true;
  }());
  return true;
}

/// Asserts that the type [T] is not of type `dynamic`.
///
/// Used to make sure that the type is not
///
/// To invoke this function, use the following pattern, typically in the
/// relevant Widget's build method:
///
/// ```dart
/// assert(debugCheckNotOfTypeDynamic<MyType>());
/// ```
///
/// Does nothing if asserts are disabled. Always returns true.
bool debugCheckNotOfTypeDynamic<T>() {
  assert(() {
    if (T == dynamic) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Use of type `dynamic` is not allowed.'),
        ErrorHint(
          'If you want to expose a variable that can be anything, consider '
          'replacing `dynamic` with `Object` instead.',
        ),
      ]);
    }
    return true;
  }());
  return true;
}
