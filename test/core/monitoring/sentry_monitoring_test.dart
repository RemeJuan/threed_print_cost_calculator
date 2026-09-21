import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:threed_print_cost_calculator/core/monitoring/sentry_monitoring.dart';

void main() {
  group('resolveSentryReleaseIdentity', () {
    test('uses runtime version and build number', () async {
      PackageInfo.setMockInitialValues(
        appName: 'app',
        packageName: 'package',
        version: '3.3.4',
        buildNumber: '256',
        buildSignature: '',
      );

      final identity = await resolveSentryReleaseIdentity();

      expect(identity.release, 'threed_print_cost_calculator@3.3.4+256');
      expect(identity.dist, '256');
    });

    test('uses safe fallback when runtime metadata is empty', () async {
      PackageInfo.setMockInitialValues(
        appName: '',
        packageName: '',
        version: '',
        buildNumber: '',
        buildSignature: '',
      );

      final identity = await resolveSentryReleaseIdentity();

      expect(identity.release, 'threed_print_cost_calculator@dev');
      expect(identity.dist, 'dev');
    });

    test('uses safe fallback when metadata lookup fails', () async {
      final identity = await resolveSentryReleaseIdentity(
        loadPackageInfo: () async => throw StateError('unavailable'),
      );

      expect(identity.release, 'threed_print_cost_calculator@dev');
      expect(identity.dist, 'dev');
    });

    test('full compile overrides skip metadata lookup', () async {
      final identity = await resolveSentryReleaseIdentity(
        buildName: '3.4.0',
        buildNumber: '9',
        loadPackageInfo: () async => throw StateError('must not load'),
      );

      expect(identity.release, 'threed_print_cost_calculator@3.4.0+9');
      expect(identity.dist, '9');
    });

    test('partial compile override merges with runtime metadata', () async {
      final identity = await resolveSentryReleaseIdentity(
        buildNumber: '9',
        loadPackageInfo: () async => PackageInfo(
          appName: 'app',
          packageName: 'package',
          version: '3.3.4',
          buildNumber: '256',
          buildSignature: '',
        ),
      );

      expect(identity.release, 'threed_print_cost_calculator@3.3.4+9');
      expect(identity.dist, '9');
    });

    test(
      'configures release identity and preserves startup privacy options',
      () {
        final options = SentryFlutterOptions();

        configureSentryOptions(
          options,
          identity: const SentryReleaseIdentity('custom@3.4.0+9', '9'),
        );

        expect(options.release, 'custom@3.4.0+9');
        expect(options.dist, '9');
        expect(options.sendDefaultPii, isFalse);
        expect(options.dsn, isNotEmpty);
        expect(options.beforeSend, isNotNull);
      },
    );
  });
}
