import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormFields extends StatelessWidget {
  const FormFields({
    Key? key,
    this.fields = const <Widget>[],
  }) : super(key: key);

  final List<Widget> fields;

  Widget _buildItem(int index) {
    final itemIndex = index ~/ 2;
    return index.isEven ? fields[itemIndex] : const SizedBox(height: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    final _listLength = fields.length * 2 - 1;

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
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    this.validations = const [],
    AutovalidateMode? autovalidateMode,
  }) : super(
          key: key,
          builder: (state) {
            final validator = FieldValidator<String?>(validations: validations);
            return TextFormField(
              controller: controller,
              textInputAction: textInputAction,
              inputFormatters: inputFormatters,
              keyboardType: keyboardType,
              validator: validator.validate,
              autovalidateMode: autovalidateMode,
              obscureText: obscureText,
              decoration: InputDecoration(
                // enabledBorder: InputBorder.none,
                // focusedBorder: InputBorder.none,
                icon: icon,
                labelText: labelText,
                errorMaxLines: 2,
                // labelStyle: TextStyle(color: theme.hintColor),
                contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                // suffixIcon: const Icon(Icons.check_circle),
                filled: true,
              ),
            );
          },
        );

  final List<Validation<String?>> validations;
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
  const FieldValidator({
    this.validations = const [],
  });

  /// The list of validations.
  final List<Validation<T?>> validations;

  /// The error message of the first [Validation] satisfying [test], or `null`
  /// if there are none.
  String? validate(T? value) {
    final validation = validations.firstWhereOrNull(
      (e) => e.test(value),
    );
    return validation?.errorMessage;
  }
}

/// Represents a [FormField] validation.
///
/// Normally used with [FieldValidator].
class Validation<T> {
  /// Creates a validation that takes as parameters the [errorMessage] of this
  /// validation that should be shown when satisfying [test].
  const Validation({
    required this.errorMessage,
    required this.test,
  });

  /// The message that explaining the why the validation failed.
  final String errorMessage;

  /// The function signature that performs the validation.
  final bool Function(T? value) test;
}
