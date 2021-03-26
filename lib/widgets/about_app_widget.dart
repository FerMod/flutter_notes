// ignore: unused_import
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
