import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
