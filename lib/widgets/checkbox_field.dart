import 'package:flutter/material.dart';

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField({
    super.key,
    Widget? title,
    super.onSaved,
    super.validator,
    ValueChanged<bool?>? onChanged,
    bool super.initialValue = false,
    super.enabled,
    super.autovalidateMode,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.leading,
  }) : super(
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
                      builder: (context) => Text(
                        state.errorText!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    )
                  : null,
              controlAffinity: controlAffinity,
            );
          },
        );
}
