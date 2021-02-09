import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../data/firebase_service.dart';
import '../data/models/user_model.dart';
import '../widgets/drawer_menu.dart';

class HomePage extends StatelessWidget {
  final userData = UserData<UserModel>(collection: 'users');
  // final _controller = StreamController<UserModel>.broadcast();

  // HomePage() {
  //   userData.stream((snapshot) => UserModel.fromSnapshot(snapshot)).pipe(_controller);
  // }
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    // StreamSubscription<UserModel> _streamSubscription;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: const Text('Sign In Anonymously'),
              onPressed: () {
                debugPrint('(Sign In Anonymously)');
                userData.signInAnonymously();
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: const Text('Sign In'),
              onPressed: () {
                debugPrint('(Sign In)');
                userData.signIn('test@email.com', 'password123');
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: const Text('Sign Up'),
              onPressed: () {
                debugPrint('(Sign Up)');
                userData.signUp('test@email.com', 'password123');
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: const Text('Sign Out'),
              onPressed: () {
                debugPrint('(Sign Out)');
                userData.signOut();
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: const Text('Current User'),
              onPressed: () {
                developer.log('Current user: ${userData.currentUser}');
              },
            ),
          ),
          // Container(
          //   padding: EdgeInsets.all(8.0),
          //   child: Row(
          //     children: [
          //       ElevatedButton(
          //         child: const Text('Subscribe Stream'),
          //         onPressed: () {
          //           debugPrint('(subscribe)');
          //           final stream = _controller.stream;
          //           _streamSubscription = stream.listen((event) {
          //             debugPrint('Stream: ${event.toString()}');
          //           });
          //         },
          //       ),
          //       ElevatedButton(
          //         child: const Text('Unsubscribe Stream'),
          //         onPressed: () {
          //           debugPrint('(unsubscribe)');
          //           _streamSubscription?.cancel();
          //         },
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
