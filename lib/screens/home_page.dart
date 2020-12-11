import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../data/app_options.dart';
import '../data/db/user_entity.dart';
import '../data/firebase_service.dart';
import '../widgets/drawer_menu.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final options = AppOptions.of(context);
    final localizations = AppLocalizations.of(context);
    final _dropdownMenuItems = _buildDropDownMenuItems(AppLocalizations.supportedLocales);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.homepage),
      ),
      drawer: DrawerMenu(),
      // body: Container(
      //   padding: EdgeInsets.all(20.0),
      //   child: DropdownButton(
      //     value: options.locale.languageCode,
      //     items: _dropdownMenuItems,
      //     onChanged: (value) => AppOptions.update(
      //       context,
      //       options.copyWith(locale: Locale(value)),
      //     ),
      //   ),
      // ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.0),
            child: DropdownButton(
              value: options.locale.languageCode,
              items: _dropdownMenuItems,
              onChanged: (value) => AppOptions.update(
                context,
                options.copyWith(locale: Locale(value)),
              ),
            ),
          ),
          Container(
            child: ElevatedButton(
              child: const Text('Test'),
              onPressed: () {
                final user = UserData<UserModel>(collection: 'users');
                user.signInAnonymously();
                var stream = user.stream((snapshot) => UserModel.fromSnapshot(snapshot));
                stream.map((i) => 'Stream: $i').listen(print);
              },
            ),
          ),
          Container(
            child: ElevatedButton(
              child: const Text('Sign In'),
              onPressed: () {
                final userData = UserData<UserModel>(collection: 'users');
                userData.signIn('test@email.com', 'password123');
                userData.data((snapshot) => UserModel.fromSnapshot(snapshot)).then((value) => developer.log(value.toString()));
              },
            ),
          ),
          Container(
            child: ElevatedButton(
              child: const Text('Sign Up'),
              onPressed: () async {
                final userData = UserData<UserModel>(collection: 'users');
                userData.signUp('test@email.com', 'password123');
                userData.data((snapshot) => UserModel.fromSnapshot(snapshot)).then((value) => developer.log(value.toString()));
              },
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildDropDownMenuItems(List<Locale> listItems) {
    return listItems.map((e) => DropdownMenuItem(value: e.languageCode, child: Text(e.languageCode))).toList();
  }
}
