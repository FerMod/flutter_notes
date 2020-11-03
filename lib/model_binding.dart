import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Code from:
// https://medium.com/flutter/managing-flutter-application-state-with-inheritedwidgets-1140452befe1
// https://gist.github.com/HansMuller/a3a6d520c6a24238bf1b1b9e3d473bf5

class _ModelBindingScope<T> extends InheritedWidget {
  const _ModelBindingScope({
    Key key,
    @required this.modelBindingState,
    Widget child,
  })  : assert(modelBindingState != null),
        super(key: key, child: child);

  final _ModelBindingState<T> modelBindingState;

  @override
  bool updateShouldNotify(_ModelBindingScope oldWidget) => true;
}

/// A generic implementation of an [InheritedWidget].
///
/// Any descendant of this widget can obtain `initialModel` using [ModelBinding.of].
class ModelBinding<T> extends StatefulWidget {
  ModelBinding({
    Key key,
    @required this.initialModel,
    this.child,
  })  : assert(initialModel != null),
        super(key: key);

  /// The model returned by [ModelBinding.of] will be specific to this initial model.
  final T initialModel;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  _ModelBindingState<T> createState() => _ModelBindingState<T>();

  /// Obtains the nearest [ModelBinding] up its widget tree and returns its value.
  static T of<T>(BuildContext context) {
    assert(context != null);
    final scope =
        context.dependOnInheritedWidgetOfExactType<_ModelBindingScope<T>>();
    return scope?.modelBindingState?.currentModel;
  }

  /// Update the model with the given one and notify the framework that the
  /// internal state of this object has changed.
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
  final GlobalKey _localizedResourcesScopeKey = GlobalKey();

  T currentModel;

  @override
  void initState() {
    super.initState();
    currentModel = widget.initialModel;
  }

  @override
  void didUpdateWidget(ModelBinding<T> old) {
    super.didUpdateWidget(old);
    if (widget.initialModel != old.initialModel) {
      updateModel(widget.initialModel);
    }
  }

  void updateModel(T newModel) {
    if (newModel != currentModel) {
      setState(() {
        currentModel = newModel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ModelBindingScope<T>(
      key: _localizedResourcesScopeKey,
      modelBindingState: this,
      child: widget.child,
    );
  }
}
