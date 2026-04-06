import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:threed_print_cost_calculator/app/support_dialog.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';

import '../../helpers/helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
    PackageInfo.setMockInitialValues(
      appName: 'App',
      packageName: 'pkg',
      version: '1.2.3',
      buildNumber: '42',
      buildSignature: 'sig',
    );
  });

  testWidgets('renders support details and app version', (tester) async {
    final db = await tester.pumpApp(const SupportDialog(userID: 'support-123'));
    addTearDown(() => db.close());
    await tester.pumpAndSettle();

    expect(find.text(S.current.needHelpTitle), findsOneWidget);
    expect(find.text(S.current.supportIdLabel), findsOneWidget);
    expect(find.text(S.current.clickToCopy), findsOneWidget);
    expect(find.text(S.current.privacyPolicyLink), findsOneWidget);
    expect(find.text(S.current.termsOfUseLink), findsOneWidget);
    expect(find.text(S.current.closeButton), findsOneWidget);
    expect(find.text(S.current.versionLabel('1.2.3')), findsOneWidget);
  });
}
