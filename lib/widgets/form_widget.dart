import 'package:flutter/material.dart';

class FormFields extends StatelessWidget {
  final List<Widget> fields;

  const FormFields({
    Key key,
    this.fields = const <Widget>[],
  }) : super(key: key);

  Widget _buildItem(int index) {
    final itemIndex = index ~/ 2;
    return index.isEven ? fields[itemIndex] : const SizedBox(height: 16);
  }

  @override
  Widget build(BuildContext context) {
    //  return ListView.separated(
    //   shrinkWrap: true,
    //   itemBuilder: (context, index) => fields[index],
    //   itemCount: fields.length,
    //   separatorBuilder: const SizedBox(height: 16),
    // );

    final _listLength = fields.length * 2;

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
    Key key,
    Icon icon,
    String labelText,
    TextEditingController controller,
    bool obscureText = false,
    this.validations = const [],
  }) : super(
          key: key,
          builder: (state) {
            final validator = FieldValidator<String>(validations: validations);
            return TextFormField(
              controller: controller,
              validator: validator.validate,
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

  final List<Validation<String>> validations;
}

class DividerText extends StatelessWidget {
  const DividerText({
    Key key,
    @required this.text,
    @required this.color,
  }) : super(key: key);

  final Widget text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Divider(thickness: 2.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: text,
          color: color,
        ),
      ],
    );
  }
}

class FieldValidator<T> {
  const FieldValidator({
    this.validations = const [],
  }) : assert(validations != null);

  final List<Validation<T>> validations;

  String validate(T value) {
    ;

    final validation = validations.firstWhere(
      (e) => e.test?.call(value),
      orElse: () => null,
    );
    return validation?.errorMessage;
  }
}

class Validation<T> {
  const Validation({this.errorMessage, this.test});

  final String errorMessage;
  final bool Function(T value) test;
}
