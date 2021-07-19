import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../data/models.dart';
import '../widgets/drawer_menu.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final userData = DataProvider.userData;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.homepage),
      ),
      drawer: DrawerMenu(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                debugPrint('(Sign In Anonymously)');
                userData.signInAnonymously();
              },
              child: const Text('Sign In Anonymously'),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                debugPrint('(Sign In)');
                userData.signIn('test@email.com', 'password123');
              },
              child: const Text('Sign In'),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                debugPrint('(Sign Up)');
                userData.signUp('test@email.com', 'password123');
              },
              child: const Text('Sign Up'),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                debugPrint('(Sign Out)');
                userData.signOut();
              },
              child: const Text('Sign Out'),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                developer.log('Current user: ${userData.currentUser}');
              },
              child: const Text('Current User'),
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
