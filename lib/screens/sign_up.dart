import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_notes/routes.dart';

import '../data/models.dart';
import '../widgets/form_message.dart';
import '../widgets/form_widget.dart';
import 'sign_form.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SignFormScreen(
      title: Text(localizations.signUp),
      builder: (context) => _SignUpForm(),
    );
  }
}

class _SignUpForm extends StatefulWidget {
  const _SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _userData = DataProvider.userData;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      // TODO: remove initState
      // _emailController.text = 'test@email.com';
      _usernameController.text = 'NewUser';
      _emailController.text = 'new_usermail.co4m';
      _passwordController.text = 'password123';
      _confirmPasswordController.text = 'password123';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future _handleOnSignUp() async {
    final formState = _formKey.currentState!;
    if (!formState.validate()) return;

    try {
      final credential = await _userData.signUp(
        _emailController.text,
        _passwordController.text,
        data: {
          'name': _usernameController.text,
          'image': '',
        },
      );
      developer.log('$credential');
      return Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoute.notes,
        ModalRoute.withName('/'), // TODO: Improve routes
      );
    } on FirebaseAuthException catch (e) {
      final localizations = AppLocalizations.of(context)!;
      late String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = localizations.errorEmailAlreadyInUse;
          break;
        case 'invalid-email':
          errorMessage = localizations.errorInvalidEmail;
          break;
        case 'weak-password':
          errorMessage = localizations.errorWeakPassword;
          break;
        case 'operation-not-allowed':
        default:
          errorMessage = localizations.errorUnknown;
      }
      Message.show(context, message: errorMessage);
    }
  }

  void _handleOnSignIn() {
    Navigator.pushNamed(context, AppRoute.signIn);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        //mainAxisAlignment: kIsWeb ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Text(
            localizations.signUpTitle,
            style: theme.textTheme.headline4,
          ),
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _BodyWidget(
                usernameController: _usernameController,
                emailController: _emailController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                onSignUp: _handleOnSignUp,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _HaveAccount(
                onPressed: _handleOnSignIn,
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
    Key? key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    this.onSignUp,
  }) : super(key: key);

  final VoidCallback? onSignUp;

  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  Validation<String?> _validateNotEmpty(BuildContext context, String labelText) {
    final localizations = AppLocalizations.of(context)!;
    return Validation(
      errorMessage: localizations.validationEmpty(labelText),
      test: (value) => value?.isEmpty ?? true,
    );
  }

  Validation<String?> _validateEqual(BuildContext context, String otherValue, String labelText) {
    final localizations = AppLocalizations.of(context)!;
    return Validation(
      errorMessage: localizations.validationNotMatching(labelText),
      test: (value) => value != otherValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final usernameInput = TextFormInput(
      labelText: localizations.username,
      icon: Icon(Icons.person, color: theme.iconTheme.color),
      controller: usernameController,
      validations: [
        _validateNotEmpty(context, localizations.username),
      ],
    );

    final emailInput = TextFormInput(
      labelText: localizations.email,
      icon: Icon(Icons.email, color: theme.iconTheme.color),
      controller: emailController,
      validations: [
        _validateNotEmpty(context, localizations.email),
      ],
    );

    final passwordInput = TextFormInput(
      labelText: localizations.password,
      icon: Icon(Icons.lock, color: theme.iconTheme.color),
      controller: passwordController,
      obscureText: true,
      validations: [
        _validateNotEmpty(context, localizations.password),
      ],
    );

    final confirmPasswordInput = TextFormInput(
      labelText: localizations.passwordConfirm,
      icon: const Icon(null),
      controller: confirmPasswordController,
      obscureText: true,
      validations: [
        _validateNotEmpty(context, localizations.passwordConfirm),
        _validateEqual(context, passwordController.text, localizations.password),
      ],
    );

    final signUpButton = _SignUpButton(onPressed: onSignUp);

    final formFields = [
      usernameInput,
      emailInput,
      passwordInput,
      confirmPasswordInput,
      signUpButton,
    ];

    return FormFields(fields: formFields);
  }
}

class _HaveAccount extends StatelessWidget {
  const _HaveAccount({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(localizations.signUpHaveAccount),
        _SignInButton(
          onPressed: onPressed,
        ),
      ],
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(localizations.signIn),
      ),
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(localizations.signUp),
      ),
    );
  }
}
