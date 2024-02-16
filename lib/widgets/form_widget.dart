import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormFields extends StatelessWidget {
  const FormFields({
    super.key,
    this.separator = const SizedBox(height: 16.0),
    this.children = const <Widget>[],
  });

  final List<Widget> children;
  final Widget separator;

  Widget _buildItem(int index) {
    final itemIndex = index ~/ 2;
    return index.isEven ? children[itemIndex] : separator;
  }

  @override
  Widget build(BuildContext context) {
    final listLength = children.length * 2 - 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < listLength; i++) _buildItem(i),
      ],
    );
  }
}

class TextFormInput extends FormField<String> {
  TextFormInput({
    super.key,
    Icon? icon,
    String? labelText,
    TextInputAction? textInputAction,
    TextEditingController? controller,
    bool obscureText = false,
    bool autocorrect = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    this.fieldValidator = const FieldValidator<String?>(),
    AutovalidateMode? autovalidateMode,
    InputDecoration? decoration,
    ValueChanged<String>? onChanged,
    GestureTapCallback? onTap,
    //VoidCallback? onEditingComplete,
    ValueChanged<String>? onFieldSubmitted,
    FormFieldSetter<String>? onSaved,
  }) : super(
          builder: (state) => TextFormField(
            controller: controller,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            keyboardType: keyboardType,
            onChanged: onChanged,
            onTap: onTap,
            //onEditingComplete: onEditingComplete,
            onFieldSubmitted: onFieldSubmitted,
            onSaved: onSaved,
            validator: fieldValidator.validate,
            autovalidateMode: autovalidateMode,
            obscureText: obscureText,
            autocorrect: autocorrect,
            decoration: decoration ??
                InputDecoration(
                  // enabledBorder: InputBorder.none,
                  // focusedBorder: InputBorder.none,
                  // errorBorder: const UnderlineInputBorder(
                  //   borderSide: BorderSide(color: Colors.redAccent),
                  // ),
                  icon: icon,
                  labelText: labelText,
                  errorMaxLines: 3,
                  labelStyle: TextStyle(color: Theme.of(state.context).hintColor),
                  // errorStyle: const TextStyle(color: Colors.redAccent),
                  contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  // suffixIcon: const Icon(Icons.check_circle),
                  filled: true,
                ),
          ),
        );

  final FieldValidator<String?> fieldValidator;
}

/// A widget that creates two [Divider]s with another widget positioned between
/// them.
///
/// The [Divider]s can be at most as large as the available space, but is allowed
/// to be smaller.
class DividerText extends StatelessWidget {
  /// Creates two [Divider]s with the given [child] positioned in the middle.
  const DividerText({
    super.key,
    required this.child,
  });

  /// The widget placed between the two [Divider]. Normally a [Text] widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Flexible(
          child: Divider(
            thickness: 2.0,
            indent: 0.0,
            endIndent: 8.0,
          ),
        ),
        child,
        const Flexible(
          child: Divider(
            thickness: 2.0,
            indent: 8.0,
            endIndent: 0.0,
          ),
        )
      ],
    );
  }
}

/// A class to help to perform multiple validations on a single [FormField].
///
/// See also:
///
///  * [Validation], a class that represents a single validation.
class FieldValidator<T> {
  /// Creates a field validator that takes a list of [validations].
  /// the order in which the validations are defined matters, since it runs each
  /// validation in iteration order.
  const FieldValidator([this.validations = const []]);

  /// The collection of validations to perform.
  final List<Validation<T>> validations;

  /// Returns the error message of the first [Validation] that does not satisfy
  /// the assertion, or `null` if there are none.
  ///
  /// This function iterates over each element defined in the [validations]
  /// collection and calls another function that asserts the given [value]. For
  /// each element, if the result of the [Validation.isValid] expression
  /// defined in [Validation] is `true`, the assertion succeeds and execution
  /// continues. If it’s false, the assertion fails and returns the error
  /// message defined in [Validation.errorMessage]. If all the assertions are
  /// resolved as `true`, the returned value is `null`.
  ///
  /// If there are no [validations] to run, then this function validation always
  /// succeeds, and as a consecuence always returns `null`.
  String? validate(T value) {
    final validation = validations.firstWhereOrNull(
      (e) => e.isNotValid(value),
    );
    return validation?.errorMessage;
  }
}

/// The function signature that runs a validation over [value].
typedef Assertion<T> = bool Function(T value);

/// Represents a [FormField] validation.
///
/// Normally used with [FieldValidator].
class Validation<T> {
  /// Creates a validation that takes as parameters the [errorMessage] of this
  /// validation that should be shown when [assertion] does not satisfy the
  /// condition.
  const Validation({
    required this.errorMessage,
    required Assertion<T?> assertion,
  }) : _assertion = assertion;

  /// The message that explaining the why the validation failed.
  final String errorMessage;

  /// The function that contains the validation assertion, invoked when calling
  /// the function [isValid].
  final Assertion<T?> _assertion;

  /// Whether the [value] is valid.
  ///
  /// This function executes the validation over the given [value]. The
  /// validation can be any expression that resolves to a boolean value.
  ///
  /// See also:
  ///
  ///  * [isNotValid], whether the [value] is considered as not valid.
  bool isValid(T? value) => _assertion(value);

  /// Whether the [value] is not valid.
  ///
  /// This function executes the validation over the given [value]. The
  /// validation can be any expression that resolves to a boolean value.
  ///
  /// See also:
  ///
  ///  * [isValid], whether the [value] is considered valid.
  bool isNotValid(T? value) => !isValid(value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Validation<T> && //
        other.errorMessage == errorMessage &&
        other._assertion == _assertion;
  }

  @override
  int get hashCode => Object.hash(errorMessage, _assertion);
}
