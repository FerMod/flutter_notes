import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_notes/data/models.dart';
import 'package:flutter_notes/routes.dart';
import 'package:flutter_notes/widgets/version_widget.dart';

import 'about_app_widget.dart';
import 'drawer_header.dart';
import 'user_account.dart';

class DrawerMenu extends StatelessWidget {
  DrawerMenu({Key? key}) : super(key: key);

  final userData = DataProvider.userData;

  Future _navigateReplacementNamed(BuildContext context, String routeName) {
    final navigator = Navigator.of(context);
    final modalRoute = ModalRoute.of(context);
    if (modalRoute?.settings.name != routeName) {
      return navigator.pushReplacementNamed(routeName);
    }
    navigator.pop();
    return Future.value();
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
        padding: const EdgeInsets.symmetric(vertical: 16.0),
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
    final userData = DataProvider.userData;
    if (userData.isSignedIn) {
      return [
        ListTile(
          leading: const Icon(Icons.sticky_note_2),
          title: Text(localizations.note(2)),
          onTap: () => _navigateReplacementNamed(context, AppRoute.notes),
        ),
      ];
    } else {
      return [
        ListTile(
          leading: const Icon(Icons.login),
          title: Text(localizations.signIn),
          onTap: () => _navigateReplacementNamed(context, AppRoute.signIn),
        ),
        ListTile(
          leading: const Icon(Icons.account_circle),
          title: Text(localizations.signUp),
          onTap: () => _navigateReplacementNamed(context, AppRoute.signUp),
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
