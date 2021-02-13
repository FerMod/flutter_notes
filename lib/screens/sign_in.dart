import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import '../data/firebase_service.dart';
import '../data/models/user_model.dart';
import '../routes.dart';
import '../widgets/checkbox_field.dart';
import '../widgets/form_message.dart';
import '../widgets/form_widget.dart';
import 'notes_list.dart';
import 'sign_form.dart';
import 'sign_up.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return SignFormScreen(
      title: Text(localizations.signIn),
      builder: (context) => _SignInForm(),
    );
  }
}

class _SignInForm extends StatefulWidget {
  const _SignInForm({Key key}) : super(key: key);

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _userData = UserData<UserModel>(collection: 'users');

  @override
  void initState() {
    super.initState();
    // TODO: remove initState
    _emailController.text = 'test@email.com';
    //_emailController.text = 'a';
    _passwordController.text = 'password123';
    /////////////////////////
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future _handleOnSignIn() async {
    final formState = _formKey.currentState;
    if (!formState.validate()) return;

    try {
      final credential = await _userData.signIn(_emailController.text, _passwordController.text);
      developer.log('$credential');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => NotesListScreen()),
        ModalRoute.withName(AppRoute.notes), // TODO: Improve routes
      );
    } on FirebaseAuthException catch (e) {
      developer.log('$e');
      Message.show(context, message: e.message);
    }
  }

  void _handleOnSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        //mainAxisAlignment: kIsWeb ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Text(
            localizations.signIn,
            style: theme.textTheme.headline4,
          ),
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _BodyWidget(
                emailController: _emailController,
                passwordController: _passwordController,
                onSignIn: _handleOnSignIn,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: _NoAccount(
                  onPressed: _handleOnSignUp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyWidget extends StatelessWidget {
  const _BodyWidget({
    Key key,
    @required this.emailController,
    @required this.passwordController,
    this.onSignIn,
  }) : super(key: key);

  final Function() onSignIn;

  final TextEditingController emailController;
  final TextEditingController passwordController;

  Validation<String> _validateNotEmpty(BuildContext context, String labelText) {
    final localizations = AppLocalizations.of(context);
    return Validation(
      errorMessage: localizations.validationEmpty(labelText),
      test: (value) => value.isEmpty,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final usernameInput = TextFormInput(
      labelText: localizations.email,
      icon: Icon(Icons.person, color: theme.iconTheme.color),
      controller: emailController,
      validations: [
        _validateNotEmpty(context, localizations.username),
      ],
    );

    final passwordInput = TextFormInput(
      labelText: localizations.email,
      icon: Icon(Icons.lock, color: theme.iconTheme.color),
      obscureText: true,
      controller: passwordController,
      validations: [
        _validateNotEmpty(context, localizations.password),
      ],
    );

    final signUpButton = _SignInButton(onPressed: onSignIn);

    final divider = DividerText(
      text: Text(localizations.signInOr),
      color: theme.cardColor,
    );

    final formFields = [
      usernameInput,
      passwordInput,
      signUpButton,
      divider,
      //...signInMethods,
    ];
    return FormFields(fields: formFields);
  }
}

class _NoAccount extends StatelessWidget {
  const _NoAccount({
    Key key,
    @required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(localizations.signInNoAccount),
        _SignUpButton(
          onPressed: onPressed,
        ),
      ],
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({
    Key key,
    @required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        child: Text(localizations.signIn),
        onPressed: onPressed,
      ),
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton({
    Key key,
    @required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: OutlineButton(
        child: Text(localizations.signUp),
        onPressed: onPressed,
      ),
    );
  }
}

class _RememberMeCheckbox extends StatelessWidget {
  const _RememberMeCheckbox({
    Key key,
    @required this.onChanged,
  }) : super(key: key);

  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return CheckboxFormField(
      title: Text(localizations.signInRememberMe),
      onChanged: onChanged,
    );
    // return CheckboxListTile(
    //   value: value,
    //   onChanged: onChanged,
    // );
    // return FormField(
    //   builder: (field) {
    //     return Checkbox(
    //       value: value,
    //       onChanged: onChanged,
    //     );
    //   },
    // );
  }
}

List<Widget> signInMethods(BuildContext context) {
  final localizations = AppLocalizations.of(context);
  return [
    SignInButton(
      Buttons.Google,
      text: localizations.signInWith('Google'),
      onPressed: () => developer.log('Sign in Google'),
    ),
    SignInButton(
      Buttons.Facebook,
      text: localizations.signInWith('Facebook'),
      onPressed: () => developer.log('Sign in Facebook'),
    ),
    SignInButton(
      Buttons.Twitter,
      text: localizations.signInWith('Twitter'),
      onPressed: () => developer.log('Sign in Twitter'),
    ),
    SignInButton(
      Buttons.GitHub,
      text: localizations.signInWith('GitHub'),
      onPressed: () => developer.log('Sign in GitHub'),
    ),
    SignInButton(
      Buttons.Yahoo,
      text: localizations.signInWith('Yahoo'),
      onPressed: () => developer.log('Sign in Method1'),
    ),
    SignInButton(
      Buttons.Microsoft,
      text: localizations.signInWith('Microsoft'),
      onPressed: () => developer.log('Sign in Microsoft'),
    ),
    SignInButton(
      Buttons.Apple,
      text: localizations.signInWith('Apple'),
      onPressed: () => developer.log('Sign in Apple'),
    ),
  ];
}