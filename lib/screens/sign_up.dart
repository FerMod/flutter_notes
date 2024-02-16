import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../data/data_provider.dart';
import '../data/firebase/auth_error_code.dart';
import '../routes.dart';
import '../src/utils/device_type.dart';
import '../widgets/banner_message.dart';
import '../widgets/form_widget.dart';
import 'sign_form.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SignFormScreen(
      title: Text(localizations.signUp),
      builder: (context) => const _SignUpForm(),
    );
  }
}

class _SignUpForm extends StatefulWidget {
  const _SignUpForm({super.key});

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

  Future<void> _handleOnSignUp() async {
    _usernameController.value = _usernameController.value.copyWith(
      text: _usernameController.text.trim(),
    );
    _emailController.value = _emailController.value.copyWith(
      text: _emailController.text.trim(),
    );
    if (!_formKey.currentState!.validate()) return;

    try {
      final credential = await _userData.signUp(
        _emailController.text,
        _passwordController.text,
        displayName: _usernameController.text,
      );
      developer.log('$credential');
      if (!mounted) return;
      final navigator = Navigator.of(context);
      navigator.popUntil((route) => route.isFirst);
      await navigator.pushReplacementNamed(AppRoute.notes);
    } on FirebaseAuthException catch (e) {
      if (!mounted) rethrow;
      BannerMessage.show(context, message: _errorMessage(e.code));
    }
  }

  String _errorMessage(String errorCode) {
    final localizations = AppLocalizations.of(context)!;
    switch (errorCode) {
      case AuthErrorCode.emailAlreadyInUse:
        return localizations.errorEmailAlreadyInUse;
      case AuthErrorCode.invalidEmail:
        return localizations.errorInvalidEmail;
      case AuthErrorCode.weakPassword:
        return localizations.errorWeakPassword;
      case AuthErrorCode.operationNotAllowed:
        return localizations.errorOperationNotAllowed;
      default:
        return localizations.errorUnknown;
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
            style: theme.textTheme.headlineMedium,
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
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    this.onSignUp,
  });

  final VoidCallback? onSignUp;

  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  Validation<String?> _validateNotEmpty(BuildContext context, String labelText) {
    final localizations = AppLocalizations.of(context)!;
    return Validation(
      errorMessage: localizations.validationEmpty(labelText),
      assertion: (value) => value?.isNotEmpty ?? false,
    );
  }

  Validation<String?> _validateEmailFormat(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final regExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$");
    return Validation(
      errorMessage: localizations.errorInvalidEmail,
      assertion: (value) => value != null && regExp.hasMatch(value),
    );
  }

  @Deprecated('Replaced by _validateStrongPassword')
  Validation<String?> _validateMinLength(BuildContext context, int minLength) {
    final localizations = AppLocalizations.of(context)!;
    return Validation(
      errorMessage: localizations.validationMinLength(localizations.password, minLength),
      assertion: (value) => value != null && value.length >= minLength,
    );
  }

  Validation<String?> _validateStrongPassword(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final regExp = RegExp(r'^(?:(?=.*\d)(?=.*[a-z])(?=.*[a-zA-Z]).{8,}|.{15,})$');
    return Validation(
      errorMessage: localizations.validationWeakPassword,
      assertion: (value) => value != null && regExp.hasMatch(value),
    );
  }

  Validation<String?> _validateEqual(BuildContext context, TextEditingController controller, String labelText) {
    final localizations = AppLocalizations.of(context)!;
    return Validation(
      errorMessage: localizations.validationNotMatching(labelText),
      assertion: (value) => value == controller.text,
    );
  }

  void _handleFieldSubmitted(String value) {
    if (DeviceType.isDesktopOrWeb) {
      onSignUp?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return FormFields(
      children: [
        TextFormInput(
          labelText: localizations.username,
          icon: Icon(Icons.person, color: theme.iconTheme.color),
          controller: usernameController,
          onFieldSubmitted: _handleFieldSubmitted,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          fieldValidator: FieldValidator([
            _validateNotEmpty(context, localizations.username),
          ]),
        ),
        TextFormInput(
          labelText: localizations.email,
          icon: Icon(Icons.email, color: theme.iconTheme.color),
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          onFieldSubmitted: _handleFieldSubmitted,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          fieldValidator: FieldValidator([
            _validateNotEmpty(context, localizations.email),
            _validateEmailFormat(context),
          ]),
        ),
        TextFormInput(
          labelText: localizations.password,
          icon: Icon(Icons.lock, color: theme.iconTheme.color),
          controller: passwordController,
          obscureText: true,
          onFieldSubmitted: _handleFieldSubmitted,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          fieldValidator: FieldValidator([
            _validateNotEmpty(context, localizations.password),
            _validateStrongPassword(context),
          ]),
        ),
        TextFormInput(
          labelText: localizations.passwordConfirm,
          icon: const Icon(null),
          controller: confirmPasswordController,
          obscureText: true,
          onFieldSubmitted: _handleFieldSubmitted,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          fieldValidator: FieldValidator([
            _validateNotEmpty(context, localizations.passwordConfirm),
            _validateEqual(context, passwordController, localizations.password),
          ]),
        ),
        _SignUpButton(onPressed: onSignUp),
      ],
    );
  }
}

class _HaveAccount extends StatelessWidget {
  const _HaveAccount({
    super.key,
    required this.onPressed,
  });

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
    super.key,
    required this.onPressed,
  });

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
    super.key,
    required this.onPressed,
  });

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
