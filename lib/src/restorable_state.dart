import 'package:flutter/foundation.dart';

/// An object that stores a snapshot of another object's state.
@immutable
class DataState<T> {
  const DataState(this._state);

  /// The state of the object when this snapshot was taken.
  final T _state;

  /// Creates a copy of this object but with the given fields replaced with the
  /// new values.
  DataState<T> copyWith({
    T? state,
  }) {
    return DataState<T>(
      state ?? _state,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is DataState<T> && other._state == _state;
  }

  @override
  int get hashCode => _state.hashCode;

  @override
  String toString() {
    return '${describeIdentity(this)}(state: $_state)';
  }
}

class DataStateNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  /// Creates a [DataStateNotifier].
  DataStateNotifier(T value) : this.fromState(DataState<T>(value));

  /// Creates a [DataStateNotifier] from an initial [DataState].
  DataStateNotifier.fromState(DataState<T> state)
      : _value = state,
        _storedValue = state;

  @override
  T get value => _value._state;
  DataState<T> _value;
  set value(T newValue) {
    if (_value._state == newValue) return;
    _value = _value.copyWith(state: newValue);
    notifyListeners();
  }

  /// The stored value of the object.
  ///
  /// When the [value] and the [storedValue] are different, it is considered as
  /// [dirty].
  ///
  /// The function [save] stores the [value] that currently has the object. The
  /// function [restore], discards the stored [value] with the one in
  /// [storedValue]. By using the [save] and [restore] functions, marks the
  /// value as not [dirty].
  T get storedValue => _storedValue._state;
  DataState<T> _storedValue;

  /// Returns `true` if the current [value] is considered dirty.
  ///
  /// The data is considered dirty when the [value] and the [storedValue] are
  /// different. This uses the [operator ==] equality operator to check whether
  /// the two values are equal.
  bool get dirty => _value != _storedValue;

  /// Discards the stored [value] and replaces it with the one that has contains
  /// [storedValue].
  ///
  /// By calling this function makes [storedValue] and [value] contain the same
  /// value, and marks the stored value no longer dirty.
  void restore() {
    _value = _storedValue;
  }

  /// Stores the current [value] that currently has the object to [storedValue].
  ///
  /// By calling this function makes [storedValue] and [value] contain the same
  /// value, and marks the stored value no longer dirty.
  void save() {
    _storedValue = _value;
  }

  @override
  String toString() {
    return '${describeIdentity(this)}(value: $_value, storedValue: $_storedValue, isDirty: $dirty)';
  }
}
