import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../data/firebase/auth_exceptions.dart';
import '../data/firebase_service.dart';
import '../data/models/user_model.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/form_message.dart';
import 'notes_list.dart';
import 'sign_up.dart';

/// Signature for reporting errors throwed from the form.
typedef FormErrorListener = void Function(Object exception, StackTrace stackTrace);

class SignFormScreen extends StatelessWidget {
  const SignFormScreen({
    Key key,
    this.title,
    this.child,
    this.onFormError,
  }) : super(key: key);

  /// The [AppBar.title] title widget.
  final Widget title;

  /// The content of this widget.
  final Widget child;

  final FormErrorListener onFormError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isWeb = kIsWeb;

    BoxConstraints constraints;
    if (isWeb) {
      final textScaleFactor = MediaQuery.textScaleFactorOf(context);
      final desktopMaxWidth = 400.0 + 100.0 * (textScaleFactor - 1);
      constraints = BoxConstraints(maxWidth: desktopMaxWidth);
    }

    final childWidget = Center(
      child: Container(
        constraints: constraints,
        child: child,
      ),
    );

    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: title,
        ),
        drawer: DrawerMenu(),
        body: SingleChildScrollView(
          child: Message(
            child: childWidget,
          ),
        ),
      ),
    );
  }
}

//////////////////////

class SignInTestScreen extends StatefulWidget {
  const SignInTestScreen({Key key}) : super(key: key);

  @override
  _SignInTestScreenState createState() => _SignInTestScreenState();
}

class _SignInTestScreenState extends State<SignInTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _userData = UserData<UserModel>(collection: 'users');

  @override
  void initState() {
    super.initState();
    // TODO: remove initState
    _emailController.text = 'test@email.co';
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

  Future<void> _handleOnSignIn() async {
    final formState = _formKey.currentState;
    if (!formState.validate()) return;

    try {
      final credential = await _userData.signIn(_emailController.text, _passwordController.text);
      developer.log('$credential');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => NotesListScreen()),
        ModalRoute.withName('/notes'),
      );
    } on AuthException catch (e) {
      print('$e');
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
        //mainAxisAlignment: isWeb ? MainAxisAlignment.center : MainAxisAlignment.start,
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final listViewChildren = [
      _EmailInput(
        icon: Icon(Icons.person, color: theme.iconTheme.color),
        emailController: emailController,
      ),
      const SizedBox(height: 16.0),
      _PasswordInput(
        icon: Icon(Icons.lock, color: theme.iconTheme.color),
        passwordController: passwordController,
      ),
      const SizedBox(height: 16.0),
      _SignInButton(
        onPressed: onSignIn,
      ),
      const SizedBox(height: 16.0),
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
      // ...signInMethods(context),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: listViewChildren,
    );
    return ListView.separated(
      shrinkWrap: true,
      itemBuilder: (context, index) => listViewChildren[index],
      itemCount: listViewChildren.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16.0),
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput({
    Key key,
    this.icon,
    this.emailController,
  }) : super(key: key);

  final Icon icon;
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return TextFormField(
      controller: emailController,
      validator: (value) {
        if (value.isEmpty) {
          return localizations.validationEmpty(localizations.email);
        }
        return null;
      },
      decoration: InputDecoration(
        // enabledBorder: InputBorder.none,
        // focusedBorder: InputBorder.none,
        icon: icon,
        labelText: localizations.email,
        // labelStyle: TextStyle(color: theme.hintColor),
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        // suffixIcon: const Icon(Icons.check_circle),
        filled: true,
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput({
    Key key,
    this.icon,
    this.passwordController,
  }) : super(key: key);

  final Icon icon;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return TextFormField(
      controller: passwordController,
      obscureText: true,
      validator: (value) {
        if (value.isEmpty) {
          return localizations.validationEmpty(localizations.password);
        }
        return null;
      },
      decoration: InputDecoration(
        // enabledBorder: InputBorder.none,
        // focusedBorder: InputBorder.none,
        icon: icon,
        labelText: localizations.password,
        // labelStyle: TextStyle(color: theme.hintColor),
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        filled: true,
      ),
    );
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
/*
Widget childWidget;
BoxConstraints constraints;
if (isWeb) {
  final textScaleFactor = MediaQuery.textScaleFactorOf(context);
  final desktopMaxWidth = 400.0 + 100.0 * (textScaleFactor - 1);
  constraints = BoxConstraints(maxWidth: desktopMaxWidth);

  childWidget = Column(
    children: [
      FormMessageBuilder(),
      Expanded(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: constraints,
              child: child,
            ),
          ),
        ),
      ),
    ],
  );
} else {
  childWidget = SingleChildScrollView(
    child: Column(
      children: [
        FormMessageBuilder(),
        Center(
          child: Container(
            constraints: constraints,
            child: child,
          ),
        ),
      ],
    ),
  );
}
*/
