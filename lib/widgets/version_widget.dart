import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionWidget extends StatelessWidget {
  const VersionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final version = snapshot.data?.version;
          final containsVersion = version?.isNotEmpty ?? false;
          return Text(
            containsVersion ? 'v$version' : '',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }
}
