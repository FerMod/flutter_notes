import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../data/firebase_service.dart';
import '../data/models/user_model.dart';
import '../screens/notes_list.dart';
import '../screens/sign_in.dart';
import '../screens/sign_up.dart';
import 'drawer_header.dart';
import 'user_account.dart';
import 'user_account_dropdown.dart';

class DrawerMenu extends StatelessWidget {
  DrawerMenu({Key? key}) : super(key: key);

  final userData = UserData<UserModel>(collection: 'users');

  Widget _buildHeader() {
    final user = userData.currentUser;

    Widget headerWidget;

    if (user != null) {
      Widget? currentAccountPicture;
      if (user.photoURL != null) {
        currentAccountPicture = Image.network(user.photoURL!);
      }

      Widget accountName;
      if (user.displayName != null) {
        accountName = Text(user.displayName!);
      }

      Widget accountEmail;
      if (user.email != null) {
        accountEmail = Text(user.email!);
      }

      final otherAccountsPictures = <Widget?>[
        currentAccountPicture,
        currentAccountPicture,
      ];
      // headerWidget = UserAccountsDrawerHeader(
      //   currentAccountPicture: currentAccountPicture,
      //   accountName: accountName,
      //   accountEmail: accountEmail,
      //   onDetailsPressed: () {},
      //   //otherAccountsPictures: otherAccountsPictures,
      // );

      // headerWidget = UserAccountDropdown(
      //   accountPicture: CircleAvatar(
      //     child: const Icon(Icons.account_circle),
      //   ),
      //   accountName: accountName,
      //   accountEmail: accountEmail,
      //   showArrow: true,
      //   onTap: () {},
      // );

      // headerWidget = ListTile(
      //   leading: CircleAvatar(
      //     child: Image.network(user.email) ,
      //   ),
      //   title: accountName,
      //   subtitle: accountEmail,
      //   onTap: () {},
      // );
      headerWidget = UserAccountListTile(
        imageUrl: user.photoURL!,
        nameText: user.displayName,
        emailText: user.email,
      );

      headerWidget = UserAccountDropdown(
        accountPicture: CircleAvatar(
          child: const Icon(Icons.account_circle),
        ),
        accountName: Text('Test'),
        accountEmail: Text('Email'),
        showArrow: true,
        onTap: () {},
      );
    } else {
      headerWidget = TitleDrawerHeader(
        child: ListTile(
          leading: Icon(Icons.account_circle),
          title: Text('Sign in'),
          onTap: () {},
        ),
      );
    }

    return headerWidget;
  }

  Future _navigate(BuildContext context, Widget widget) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  Future _navigateReplace(BuildContext context, Widget widget) {
    return Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final user = userData.currentUser;

    Widget headerWidget;
    if (user != null) {
      headerWidget = UserAccountsDrawerHeader(
        currentAccountPicture: UserAvatar(
          nameText: user.displayName,
          imageUrl: user.photoURL!,
        ),
        accountName: Text(user.displayName!),
        accountEmail: Text(user.email!),
      );
    } else {
      headerWidget = TitleDrawerHeader(
        child: ListTile(
          leading: Icon(Icons.account_circle),
          title: Text(localizations!.signIn),
          onTap: () => _navigate(context, SignInScreen()),
        ),
      );
    }

    return headerWidget;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // TitleDrawerHeader(
          //   child: Text(
          //     localizations.drawerTitle,
          //     style: theme.textTheme.headline5,
          //   ),
          // ),
          _buildDrawerHeader(context),
          // ListTile(
          //   leading: Icon(Icons.home),
          //   title: Text(localizations.homepage),
          //   onTap: () => _navigateReplace(context, HomePage()),
          // ),
          ListTile(
            leading: Icon(Icons.sticky_note_2),
            title: Text(localizations.note(2)),
            onTap: () => _navigateReplace(context, NotesListScreen()),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.login),
            title: Text(localizations.signIn),
            onTap: () => _navigate(context, SignInScreen()),
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text(localizations.signUp),
            onTap: () => _navigate(context, SignUpScreen()),
          ),
        ],
      ),
    );
    
    /*
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // TitleDrawerHeader(
          //   child: Text(
          //     localizations.drawerTitle,
          //     style: theme.textTheme.headline5,
          //   ),
          // ),
          _buildDrawerHeader(context),
          ListTile(
            leading: Icon(Icons.sticky_note_2),
            title: Text(localizations.note(2)),
            onTap: () => _navigateReplace(context, NotesListScreen()),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.login),
            title: Text(localizations.signOut),
            onTap: () {
              userData.signOut();
              // TODO: Improve route navigation
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoute.notes,
                ModalRoute.withName('/'),
              );
            },
          ),
        ],
      ),
    );
    */
  }
}
