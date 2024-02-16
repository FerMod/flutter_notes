import 'package:flutter/material.dart';
import 'package:flutter_notes/widgets/version_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  group('VersionWidget', () {
    final packageInfo = PackageInfo(
      appName: 'TestApp',
      packageName: 'com.test.app',
      version: '1.2.3',
      buildNumber: '4',
      buildSignature: 'a94a8fe5ccb19ba61c4c0873d391e987982fbbd3',
    );

    final emptyPackageInfo = PackageInfo(
      appName: '',
      packageName: '',
      version: '',
      buildNumber: '',
      buildSignature: '',
    );

    void mockPackageInfo(PackageInfo packageInfo) {
      PackageInfo.setMockInitialValues(
        appName: packageInfo.appName,
        packageName: packageInfo.packageName,
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        buildSignature: packageInfo.buildSignature,
      );
    }

    testWidgets('displays version correctly', (tester) async {
      mockPackageInfo(packageInfo);

      const versionWidget = MaterialApp(
        home: VersionWidget(),
      );
      await tester.pumpWidget(versionWidget);
      await tester.pumpAndSettle();

      final finder = find.text('v${packageInfo.version}');
      expect(finder, findsOneWidget);
    });

    testWidgets('displays empty when no version exists', (tester) async {
      mockPackageInfo(emptyPackageInfo);

      const versionWidget = MaterialApp(
        home: VersionWidget(),
      );
      await tester.pumpWidget(versionWidget);
      await tester.pumpAndSettle();

      final finderFilled = find.text('v${emptyPackageInfo.version}');
      expect(finderFilled, findsNothing);
    });

    testWidgets('updates version after future completes', (tester) async {
      mockPackageInfo(packageInfo);

      const versionWidget = MaterialApp(
        home: VersionWidget(),
      );
      await tester.pumpWidget(versionWidget);

      final finderFilled = find.text('v${packageInfo.version}');
      expect(finderFilled, findsNothing);

      await tester.pumpAndSettle();
      expect(finderFilled, findsOneWidget);
    });
  });
}
