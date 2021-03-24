// ignore: unused_import
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../data/firebase_service.dart';
import '../data/models/user_model.dart';
import '../screens/notes_list.dart';
import '../screens/sign_in.dart';
import '../screens/sign_up.dart';
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
          VersionWidget(),
        ],
      ),
    );
  }
}

class VersionWidget extends StatelessWidget {
  const VersionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          final version = data != null ? 'v${data.version}' : '';
          return Text(
            version,
            style: theme.textTheme.caption,
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }
}

class AboutAppWidget extends StatelessWidget {
  const AboutAppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final defaultPackageInfo = PackageInfo(
      appName: 'Unknown',
      packageName: 'Unknown',
      version: 'Unknown',
      buildNumber: 'Unknown',
    );

    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      initialData: defaultPackageInfo,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          developer.log('PackageInfo Snapshot Error: ${snapshot.error}');
        }
        developer.log('PackageInfo ConnectionState: ${snapshot.connectionState}');

        final data = snapshot.hasData ? snapshot.data! : defaultPackageInfo;
        final legalNotice = 'Copyright (C) 2021  Ferran Tudela\n'
            '\n'
            'This program is free software: you can redistribute it and/or modify '
            'it under the terms of the GNU General Public License as published by '
            'the Free Software Foundation, either version 3 of the License, or '
            '(at your option) any later version.\n'
            '\n'
            'This program is distributed in the hope that it will be useful, '
            'but WITHOUT ANY WARRANTY; without even the implied warranty of '
            'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the '
            'GNU General Public License for more details.\n'
            '\n'
            'You should have received a copy of the GNU General Public License '
            'along with this program.  If not, see <https://www.gnu.org/licenses/>.';

        return AboutListTile(
          icon: const Icon(Icons.info_outline),
          applicationName: data.appName,
          applicationVersion: '${data.version} (build: ${data.buildNumber})',
          //applicationIcon: ImageIcon(),
          applicationLegalese: legalNotice,
          child: Text(localizations.aboutApp),
        );
      },
    );
  }
}
