import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Code derived from:
// https://medium.com/flutter/managing-flutter-application-state-with-inheritedwidgets-1140452befe1
// https://gist.github.com/HansMuller/a3a6d520c6a24238bf1b1b9e3d473bf5

class _ModelBindingScope<T> extends InheritedWidget {
  const _ModelBindingScope({
    Key key,
    this.model,
    @required this.modelBindingState,
    Widget child,
  })  : assert(modelBindingState != null),
        super(key: key, child: child);

  final T model;
  final _ModelBindingState<T> modelBindingState;

  @override
  bool updateShouldNotify(_ModelBindingScope<T> old) => model != old.model;
}

/// A generic implementation of an [InheritedWidget].
///
/// Any descendant of this widget can obtain `initialModel` with an instance of
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
  /// If no [ModelBinding] widget is in scope then this function will return
  /// null.
  static T of<T>(BuildContext context) {
    assert(context != null);
    final scope =
        context.dependOnInheritedWidgetOfExactType<_ModelBindingScope<T>>();
    return scope?.modelBindingState?.currentModel;
  }

  /// Updates its model with the new given one and notifies the framework that
  /// the internal state of this object has changed.
  ///
  /// Returns the nearest [ModelBinding] widget up its widget tree that
  /// corresponds to the given [context] and returns its value.
  static void update<T>(BuildContext context, T newModel) {
    assert(context != null);
    assert(newModel != null);
    final scope =
        context.dependOnInheritedWidgetOfExactType<_ModelBindingScope<T>>();
    assert(scope != null, 'a ModelBinding<T> ancestor was not found');
    scope?.modelBindingState?.updateModel(newModel);
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
    updateModel(widget.initialModel);
  }

  @override
  void didUpdateWidget(ModelBinding<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialModel != oldWidget.initialModel) {
      updateModel(widget.initialModel);
    }
  }

  void updateModel(T newModel) {
    setState(() {
      _currentModel = newModel;
    });
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
