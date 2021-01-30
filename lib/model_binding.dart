import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Code derived from:
// https://medium.com/flutter/managing-flutter-application-state-with-inheritedwidgets-1140452befe1
// https://gist.github.com/HansMuller/a3a6d520c6a24238bf1b1b9e3d473bf5

class _ModelBindingScope<T> extends InheritedWidget {
  const _ModelBindingScope({
    Key key,
    this.model,
    @required this.modelBindingState,
    @required Widget child,
  })  : assert(modelBindingState != null),
        super(key: key, child: child);

  final T model;
  final _ModelBindingState<T> modelBindingState;

  @override
  bool updateShouldNotify(_ModelBindingScope<T> old) => model != old.model;
}

/// A generic implementation of an [InheritedWidget].
///
/// Any descendant of this widget can obtain [initialModel] with an instance of
/// ModelBinding returned by [ModelBinding.of].
class ModelBinding<T> extends StatefulWidget {
  const ModelBinding({
    Key key,
    @required this.initialModel,
    this.child,
  })  : assert(initialModel != null),
        super(key: key);

  /// The model returned by [ModelBinding.of] will be specific to this initial
  /// model.
  final T initialModel;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  _ModelBindingState<T> createState() => _ModelBindingState<T>();

  /// Returns the nearest [ModelBinding] widget up its widget tree that
  /// corresponds to the given [context] and returns its value.
  ///
  /// If there is no [ModelBinding] in scope, then this will assert in
  /// debug mode, and throw an exception in release mode.
  static T of<T>(BuildContext context) {
    assert(
      context != null,
      'Tried to call ModelBinding.of<$T> on a `context` that is `null`.\n'
      'This can happen if context of a StatefulWidget is used and that'
      'StatefulWidget was disposed.',
    );
    assert(
      T != dynamic,
      'Tried to call ModelBinding.of<dynamic>.\n'
      'If you want to expose a variable that can be anything, consider '
      'replacing `dynamic` with `Object` instead.',
    );
    assert(debugCheckHasModelBinding<T>(context));

    final scope = context.dependOnInheritedWidgetOfExactType<_ModelBindingScope<T>>();
    return scope.modelBindingState.currentModel;
  }

  /// Returns the nearest [ModelBinding] widget up its widget tree that
  /// corresponds to the given [context] and returns its value.
  ///
  /// If no [ModelBinding] widget is in scope then the [ModelBinding.of]
  /// method will return null.
  ///
  /// See also:
  ///
  /// * [of], which is a similar function, except that it will throw an
  ///   exception if a [ModelBinding] is not found in the given context.
  static T maybeOf<T>(BuildContext context) {
    assert(
      context != null,
      'Tried to call ModelBinding.maybeOf<$T> on a `context` that is `null`.\n'
      'This can happen if context of a StatefulWidget is used and that'
      'StatefulWidget was disposed.',
    );
    assert(
      T != dynamic,
      'Tried to call ModelBinding.of<dynamic>.\n'
      'If you want to expose a variable that can be anything, consider '
      'replacing `dynamic` with `Object` instead.',
    );

    final scope = context.dependOnInheritedWidgetOfExactType<_ModelBindingScope<T>>();
    return scope?.modelBindingState?.currentModel;
  }

  /// Updates the model that corresponds to the given [context] with the new
  /// given one and notifies the framework that the internal state of this
  /// object has changed.
  static void update<T>(BuildContext context, T newModel) {
    assert(
      context != null,
      'Tried to call ModelBinding.update<$T> on a `context` that is `null`.\n'
      'This can happen if context of a StatefulWidget is used and that'
      'StatefulWidget was disposed.',
    );
    // assert(newModel != null); // Should we allow null?
    assert(
      T != dynamic,
      'Tried to call ModelBinding.update<dynamic>.\n'
      'If you want to expose a variable that can be anything, consider '
      'replacing `dynamic` with `Object` instead.',
    );
    assert(debugCheckHasModelBinding<T>(context));

    final scope = context.dependOnInheritedWidgetOfExactType<_ModelBindingScope<T>>();
    //assert(scope != null, 'a ModelBinding<T> ancestor was not found');
    scope.modelBindingState.updateModel(newModel);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<T>('initialModel', initialModel));
  }
}

class _ModelBindingState<T> extends State<ModelBinding<T>> {
  final GlobalKey _modelBindingScopeKey = GlobalKey();

  T _currentModel;
  T get currentModel => _currentModel;

  @override
  void initState() {
    super.initState();
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
  void updateModel(T newModel) {
    if (_currentModel != newModel) {
      setState(() {
        _currentModel = newModel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ModelBindingScope<T>(
      key: _modelBindingScopeKey,
      model: _currentModel,
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
    if (context.findAncestorWidgetOfExactType<_ModelBindingScope<T>>() == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('No ModelBinding<$T> widget found.'),
        ErrorDescription('${context.widget.runtimeType} widgets require a ModelBinding<$T> widget ancestor.'),
        ...context.describeMissingAncestor(expectedAncestorType: ModelBinding),
        ErrorHint(
          'Typically, the $T widget should have a ModelBinding<$T> as a parent widget.\n'
          'Try to wrap the ',
        ),
        ErrorHint('The used `BuildContext` is of an ancestor of the ModelBinding<$T> you are trying to access.'),
        ErrorHint('The used `BuildContext` is in another route.'),
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
