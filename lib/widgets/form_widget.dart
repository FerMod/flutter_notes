import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormFields extends StatelessWidget {
  const FormFields({
    Key? key,
    this.separator = const SizedBox(height: 16.0),
    this.children = const <Widget>[],
  }) : super(key: key);

  final List<Widget> children;
  final Widget separator;

  Widget _buildItem(int index) {
    final itemIndex = index ~/ 2;
    return index.isEven ? children[itemIndex] : separator;
  }

  @override
  Widget build(BuildContext context) {
    final _listLength = children.length * 2 - 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _listLength; i++) _buildItem(i),
      ],
    );
  }
}

class TextFormInput extends FormField<String> {
  TextFormInput({
    Key? key,
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
          key: key,
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
                  errorMaxLines: 2,
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

class DividerText extends StatelessWidget {
  const DividerText({
    Key? key,
    required this.text,
    required this.color,
  }) : super(key: key);

  final Widget text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Divider(thickness: 2.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          color: color,
          child: text,
        ),
      ],
    );
  }
}

/// A class to help to perform multiple validations on a single [FormField].
///
/// See:
/// * [Validation], that represents a single validation
class FieldValidator<T> {
  /// Creates a field validator that takes a list of [validations].
  const FieldValidator([this.validations = const []]);

  /// The list of validations.
  final List<Validation<T?>> validations;

  /// The error message of the first [Validation] satisfying [assertion], or `null`
  /// if there are none.
  String? validate(T? value) {
    final validation = validations.firstWhereOrNull(
      (e) => !e.assertion(value),
    );
    return validation?.errorMessage;
  }
}

/// Represents a [FormField] validation.
///
/// Normally used with [FieldValidator].
class Validation<T> {
  /// Creates a validation that takes as parameters the [errorMessage] of this
  /// validation that should be shown when [assertion] does not satisfy the
  /// condition.
  const Validation({
    required this.errorMessage,
    required this.assertion,
  });

  /// The message that explaining the why the validation failed.
  final String errorMessage;

  /// The function signature that performs the validation.
  final bool Function(T? value) assertion;
}
