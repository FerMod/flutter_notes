import 'package:flutter/material.dart';

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField({
    Widget? title,
    FormFieldSetter<bool>? onSaved,
    FormFieldValidator<bool>? validator,
    ValueChanged<bool?>? onChanged,
    bool initialValue = false,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.leading,
  }) : super(
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue,
          enabled: enabled,
          autovalidateMode: autovalidateMode,
          builder: (state) {
            // ignore: avoid_positional_boolean_parameters
            void onChangedHandler(bool? value) {
              state.didChange(value);
              onChanged?.call(value);
            }

            return CheckboxListTile(
              dense: state.hasError,
              title: title,
              value: state.value,
              onChanged: onChangedHandler,
              subtitle: state.hasError
                  ? Builder(
                      builder: (context) {
                        return Text(
                          state.errorText!,
                          style: TextStyle(color: Theme.of(context).errorColor),
                        );
                      },
                    )
                  : null,
              controlAffinity: controlAffinity,
            );
          },
        );
}
