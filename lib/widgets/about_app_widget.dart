import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutAppWidget extends StatelessWidget {
  const AboutAppWidget({super.key});

  static const logoAssetName = 'assets/images/flutter_notes_logo.png';
  static const legalNotice = 'Copyright (C) 2021  Ferran Tudela\n'
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final defaultPackageInfo = PackageInfo(
      appName: 'Unknown',
      packageName: 'Unknown',
      version: 'Unknown',
      buildNumber: 'Unknown',
      buildSignature: 'Unknown',
    );

    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      initialData: defaultPackageInfo,
      builder: (context, snapshot) {
        final data = snapshot.hasData ? snapshot.data! : defaultPackageInfo;

        final version = StringBuffer(data.version);
        if (data.buildNumber.isNotEmpty) {
          version.write(' (build: ${data.buildNumber})');
        }

        final iconTheme = IconTheme.of(context);
        return AboutListTile(
          icon: const Icon(Icons.info_outline),
          applicationName: data.appName,
          applicationVersion: version.toString(),
          applicationIcon: Image(
            image: const AssetImage(logoAssetName),
            width: iconTheme.size,
            height: iconTheme.size,
            color: null,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
          applicationLegalese: legalNotice,
          child: Text(localizations.aboutApp),
        );
      },
    );
  }
}
