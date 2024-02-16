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

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SignFormScreen(
      title: Text(localizations.signIn),
      builder: (context) => const _SignInForm(),
    );
  }
}

class _SignInForm extends StatefulWidget {
  const _SignInForm({super.key});

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      // TODO: remove initState
      _emailController.text = 'test@email.com';
      _passwordController.text = 'password123';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleOnSignIn() async {
    _emailController.value = _emailController.value.copyWith(
      text: _emailController.text.trim(),
    );
    if (!_formKey.currentState!.validate()) return;

    final userData = DataProvider.userData;

    try {
      final credential = await userData.signIn(_emailController.text, _passwordController.text);
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
      case AuthErrorCode.userDisabled:
        return localizations.errorUserDisabled;
      case AuthErrorCode.invalidEmail:
      case AuthErrorCode.userNotFound:
      case AuthErrorCode.wrongPassword:
        return localizations.errorSignIn;
      case AuthErrorCode.operationNotAllowed:
        return localizations.errorOperationNotAllowed;
      default:
        return localizations.errorUnknown;
    }
  }

  void _handleOnSignUp() {
    Navigator.pushNamed(context, AppRoute.signUp);
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
            localizations.signIn,
            style: theme.textTheme.headlineMedium,
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
              child: _NoAccount(
                onPressed: _handleOnSignUp,
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
    required this.emailController,
    required this.passwordController,
    this.onSignIn,
  });

  final VoidCallback? onSignIn;

  final TextEditingController emailController;
  final TextEditingController passwordController;

  Validation<String?> _validateNotEmpty(BuildContext context, String labelText) {
    final localizations = AppLocalizations.of(context)!;
    return Validation(
      errorMessage: localizations.validationEmpty(labelText),
      assertion: (value) => value?.isNotEmpty ?? false,
    );
  }

  List<Widget> signInMethods(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return [
      // SignInButton(
      //   Buttons.Google,
      //   text: localizations.signInWith('Google'),
      //   onPressed: () => developer.log('Sign in Google'),
      // ),
      // SignInButton(
      //   Buttons.Facebook,
      //   text: localizations.signInWith('Facebook'),
      //   onPressed: () => developer.log('Sign in Facebook'),
      // ),
      // SignInButton(
      //   Buttons.Twitter,
      //   text: localizations.signInWith('Twitter'),
      //   onPressed: () => developer.log('Sign in Twitter'),
      // ),
      // SignInButton(
      //   Buttons.GitHub,
      //   text: localizations.signInWith('GitHub'),
      //   onPressed: () => developer.log('Sign in GitHub'),
      // ),
      // SignInButton(
      //   Buttons.Yahoo,
      //   text: localizations.signInWith('Yahoo'),
      //   onPressed: () => developer.log('Sign in Method1'),
      // ),
      // SignInButton(
      //   Buttons.Microsoft,
      //   text: localizations.signInWith('Microsoft'),
      //   onPressed: () => developer.log('Sign in Microsoft'),
      // ),
      // SignInButton(
      //   Buttons.Apple,
      //   text: localizations.signInWith('Apple'),
      //   onPressed: () => developer.log('Sign in Apple'),
      // ),
    ];
  }

  void _handleFieldSubmitted(String value) {
    if (!DeviceType.isDesktopOrWeb) return;
    onSignIn?.call();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return FormFields(
      children: [
        TextFormInput(
          labelText: localizations.email,
          icon: Icon(Icons.person, color: theme.iconTheme.color),
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          onFieldSubmitted: _handleFieldSubmitted,
          fieldValidator: FieldValidator([
            _validateNotEmpty(context, localizations.email),
          ]),
        ),
        TextFormInput(
          labelText: localizations.password,
          icon: Icon(Icons.lock, color: theme.iconTheme.color),
          obscureText: true,
          controller: passwordController,
          onFieldSubmitted: _handleFieldSubmitted,
          fieldValidator: FieldValidator([
            _validateNotEmpty(context, localizations.password),
          ]),
        ),
        _SignInButton(onPressed: onSignIn),
        DividerText(child: Text(localizations.signInOr)),
        // divider,
        // ...signInMethods(context),
      ],
    );
  }
}

class _NoAccount extends StatelessWidget {
  const _NoAccount({
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

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(localizations.signUp),
      ),
    );
  }
}
