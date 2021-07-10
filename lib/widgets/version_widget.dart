import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionWidget extends StatelessWidget {
  const VersionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data?.version.isEmpty ?? true) {
            return const SizedBox.shrink();
          }

          final theme = Theme.of(context);
          return Text(
            'v${data!.version}',
            style: theme.textTheme.caption,
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }
}
