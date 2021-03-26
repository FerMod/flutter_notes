import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes/widgets/version_widget.dart';

import '../data/firebase_service.dart';
import '../data/models/user_model.dart';
import '../screens/notes_list.dart';
import '../screens/sign_in.dart';
import '../screens/sign_up.dart';
import 'about_app_widget.dart';
import 'drawer_header.dart';
import 'user_account.dart';

class DrawerMenu extends StatelessWidget {
  DrawerMenu({Key? key}) : super(key: key);

  final userData = UserData<UserModel>(collection: 'users');

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
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: ListTile(
          leading: const Icon(
            Icons.account_circle,
            size: UserAvatar.alternativeImageIconSize,
          ),
          title: Text(localizations.signIn),
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
          onTap: () => _navigate(context, SignInScreen()),
        ),
        ListTile(
          leading: const Icon(Icons.account_circle),
          title: Text(localizations.signUp),
          onTap: () => _navigate(context, SignUpScreen()),
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
