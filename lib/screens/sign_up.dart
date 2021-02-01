import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../data/firebase/auth_exceptions.dart';
import '../data/firebase_service.dart';
import '../data/models/user_model.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/form_widget.dart';
import '../widgets/message.dart';
import 'notes_list.dart';
import 'sign_in.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _userData = UserData<UserModel>(collection: 'users');

  bool _isMessageVisible;
  String _message;

  @override
  void initState() {
    super.initState();
    // TODO: remove initState
    // _emailController.text = 'test@email.com';
    _usernameController.text = 'NewUser';
    _emailController.text = 'new_usermail.co4m';
    _passwordController.text = 'password123';
    _confirmPasswordController.text = 'password123';
    //

    _isMessageVisible = false;
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
    final formState = _formKey.currentState;
    if (!formState.validate()) return;

    final localizations = AppLocalizations.of(context);

    try {
      final credential = await _userData.signUp(_emailController.text, _passwordController.text);
      developer.log('$credential');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => NotesListScreen()),
        ModalRoute.withName('/notes'),
      );
    } on AuthException catch (e) {
      //var errorMessage;
      // switch (e.errorCode) {
      //   case AuthErrorCode.weakPassword:
      //     errorMessage = localizations.errorWeakPassword;
      //     break;
      //   case AuthErrorCode.invalidEmail:
      //     errorMessage = localizations.errorInvalidEmail;
      //     break;
      //   case AuthErrorCode.emailAlreadyInUse:
      //     errorMessage = localizations.errorEmailAlreadyInUse;
      //     break;
      //   case AuthErrorCode.unknown:
      //   default:
      //     errorMessage = localizations.errorUnknown;
      //     break;
      // }
      developer.log(e.toString());
      _showMessage(true, e.message);
    }
  }

  void _handleOnSignIn() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SignInScreen(),
    ));
  }

  void _showMessage(bool isVisible, [String message]) {
    if (_isMessageVisible != isVisible || _message != message) {
      setState(() {
        _message = message;
        _isMessageVisible = isVisible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final isWeb = kIsWeb;

    BoxConstraints constraints;
    if (isWeb) {
      final textScaleFactor = MediaQuery.textScaleFactorOf(context);
      final desktopMaxWidth = 400.0 + 100.0 * (textScaleFactor - 1);
      constraints = BoxConstraints(maxWidth: desktopMaxWidth);
    }

    Widget messageWidget;
    if (_isMessageVisible) {
      messageWidget = Card(
        margin: EdgeInsets.all((isWeb && _isMessageVisible) ? 8.0 : 0.0),
        child: MessageWidget(
          // visible: _isMessageVisible,
          leading: const Icon(Icons.warning_rounded),
          title: Text(_message ?? localizations.signInError),
          actions: [
            TextButton(
              child: Text(localizations.closeButton),
              onPressed: () => _showMessage(false),
            )
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.signUp),
      ),
      drawer: DrawerMenu(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: constraints,
                child: Column(
                  //mainAxisAlignment: isWeb ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    if (isWeb)
                      Text(
                        localizations.signUpTitle,
                        style: theme.textTheme.headline4,
                      ),
                    if (_isMessageVisible) messageWidget,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BodyWidget extends StatelessWidget {
  const _BodyWidget({
    Key key,
    @required this.usernameController,
    @required this.emailController,
    @required this.passwordController,
    @required this.confirmPasswordController,
    this.onSignUp,
  }) : super(key: key);

  final VoidCallback onSignUp;

  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  Validation<String> _validateNotEmpty(BuildContext context, String labelText) {
    final localizations = AppLocalizations.of(context);
    return Validation(
      errorMessage: localizations.validationEmpty(labelText),
      test: (value) => value.isEmpty,
    );
  }

  Validation<String> _validateEqual(BuildContext context, String otherValue, String labelText) {
    final localizations = AppLocalizations.of(context);
    return Validation(
      errorMessage: localizations.validationNotMatching(labelText),
      test: (value) => value != otherValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
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

    final divider = DividerText(
      text: Text(localizations.signInOr),
      color: theme.cardColor,
    );

    return FormFields(
      fields: [
        usernameInput,
        emailInput,
        passwordInput,
        confirmPasswordInput,
        signUpButton,
        divider,
        //...signInMethods
      ],
    );
    // return ListView.separated(
    //   shrinkWrap: true,
    //   itemBuilder: (context, index) => formList[index],
    //   itemCount: formList.length,
    //   separatorBuilder: (context, index) => const SizedBox(height: 26),
    // );
    // return ListView.separated(
    //   shrinkWrap: true,
    //   itemBuilder: (context, index) => listViewChildren[index],
    //   itemCount: listViewChildren.length,
    //   separatorBuilder: (context, index) => const SizedBox(height: 16),
    // );
  }
}

class _HaveAccount extends StatelessWidget {
  const _HaveAccount({
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
      child: ElevatedButton(
        child: Text(localizations.signUp),
        onPressed: onPressed,
      ),
    );
  }
}
/*
final listViewChildren = [
  _TextFormInput(
    labelText: localizations.username,
    icon: Icon(Icons.person, color: theme.iconTheme.color),
    controller: usernameController,
    validator: (value) => _validateNotEmpty(context, value, localizations.username),
  ),
  _TextFormInput(
    labelText: localizations.email,
    icon: Icon(Icons.email, color: theme.iconTheme.color),
    controller: emailController,
    validator: (value) => _validateNotEmpty(context, value, localizations.email),
  ),
  _TextFormInput(
    labelText: localizations.password,
    icon: Icon(Icons.lock, color: theme.iconTheme.color),
    controller: passwordController,
    validator: (value) => _validateNotEmpty(context, value, localizations.password),
    obscureText: true,
  ),
  _TextFormInput(
    labelText: localizations.passwordConfirm,
    icon: const Icon(null),
    controller: confirmPasswordController,
    validator: (value) => _validateConfirmValue(context, value, passwordController.text, localizations.passwordConfirm),
    obscureText: true,
  ),
  _SignUpButton(
    onPressed: onSignUp,
  ),
  Stack(
    alignment: Alignment.center,
    children: [
      Divider(thickness: 2.0),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(localizations.signInOr),
        color: theme.cardColor,
      ),
    ],
  ),
  //...signInMethods
];
*/
