import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../data/data_provider.dart';
import '../routes.dart';
import 'about_app_widget.dart';
import 'drawer_header.dart';
import 'user_account_tile.dart';
import 'user_avatar.dart';
import 'version_widget.dart';

class DrawerMenu extends StatelessWidget {
  DrawerMenu({super.key});

  final userData = DataProvider.userData;

  Future<T?> _navigateReplacementNamed<T>(BuildContext context, String routeName) async {
    final navigator = Navigator.of(context);
    final modalRoute = ModalRoute.of(context);

    if (modalRoute?.settings.name != routeName) {
      return navigator.pushReplacementNamed(routeName);
    }

    navigator.pop();
    return null;
  }

  Widget _buildDrawerHeader(BuildContext context) {
    if (userData.isSignedIn) {
      final user = userData.currentUser!;

      final userName = user.displayName ?? '';
      final userImage = user.photoURL ?? '';
      final userEmail = user.email ?? '';
      return UserAccountsDrawerHeader(
        currentAccountPicture: UserAvatar(
          imageUrl: userImage,
          nameText: userName,
        ),
        accountName: Text(userName),
        accountEmail: Text(userEmail),
      );
    }

    final localizations = AppLocalizations.of(context)!;
    return TitleDrawerHeader(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: UserAccountTile(
        image: const Icon(
          Icons.account_circle,
        ),
        title: Text(localizations.notSignedIn),
        imageSize: const Size.fromRadius(UserAvatar.defaultRadius),
      ),
    );
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
