import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes/data/models.dart';
import 'package:flutter_notes/widgets/version_widget.dart';

import '../screens/notes_list.dart';
import '../screens/sign_in.dart';
import '../screens/sign_up.dart';
import 'about_app_widget.dart';
import 'drawer_header.dart';
import 'user_account.dart';

class DrawerMenu extends StatelessWidget {
  DrawerMenu({Key? key}) : super(key: key);

  final userData = DataProvider.userData;

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
    final localizations = AppLocalizations.of(context)!;
    final userData = DataProvider.userData;

    Widget headerWidget;
    if (userData.isSignedIn) {
      final user = userData.currentUser!;

      headerWidget = UserAccountsDrawerHeader(
        currentAccountPicture: UserAvatar(
          imageUrl: user.photoURL,
          nameText: user.displayName,
        ),
        accountName: Text(user.displayName ?? ''),
        accountEmail: Text(user.email ?? ''),
      );
    } else {
      headerWidget = TitleDrawerHeader(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: ListTile(
          leading: const Icon(
            Icons.account_circle,
            size: UserAvatar.alternativeImageIconSize,
          ),
          title: Text(localizations.notSignedIn),
        ),
      );
    }

    return headerWidget;
  }

  List<Widget> _buildDrawerChildren(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = userData.currentUser;

    if (user != null) {
      return [
        ListTile(
          leading: const Icon(Icons.sticky_note_2),
          title: Text(localizations.note(2)),
          onTap: () => _navigateReplace(context, NotesListScreen()),
        ),
      ];
    } else {
      return [
        ListTile(
          leading: const Icon(Icons.login),
          title: Text(localizations.signIn),
          onTap: () => _navigateReplace(context, SignInScreen()),
        ),
        ListTile(
          leading: const Icon(Icons.account_circle),
          title: Text(localizations.signUp),
          onTap: () => _navigateReplace(context, SignUpScreen()),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          ..._buildDrawerChildren(context),
          const Divider(),
          const AboutAppWidget(),
          const VersionWidget(),
        ],
      ),
    );
  }
}
