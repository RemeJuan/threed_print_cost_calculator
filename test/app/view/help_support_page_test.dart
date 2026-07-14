import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_email_sender_platform_interface/flutter_email_sender_platform_interface.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:threed_print_cost_calculator/app/help_support/help_support_links.dart';
import 'package:threed_print_cost_calculator/app/help_support/help_support_page.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../../helpers/helpers.dart';
import '../../helpers/lower_level_test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final urlLauncherChannel = const MethodChannel(
    'plugins.flutter.io/url_launcher',
  );
  final launchCalls = <MethodCall>[];
  final emailCalls = <Email>[];
  final analyticsCalls = <Map<String, Object>>[];

  setUpAll(() async {
    await setupTest();
    PackageInfo.setMockInitialValues(
      appName: 'App',
      packageName: 'pkg',
      version: '1.2.3',
      buildNumber: '42',
      buildSignature: 'sig',
    );
    FlutterEmailSenderPlatform.instance = _FakeFlutterEmailSenderPlatform(
      onSend: emailCalls.add,
    );
    AppAnalytics.service = _FakeAnalyticsService(
      onLogEvent: (name, params) {
        analyticsCalls.add({'name': name, ...?params});
      },
    );
  });

  setUp(() {
    launchCalls.clear();
    emailCalls.clear();
    analyticsCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(urlLauncherChannel, (call) async {
          launchCalls.add(call);
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(urlLauncherChannel, null);
  });

  testWidgets('renders localized help content with dynamic support info', (
    tester,
  ) async {
    final db = await tester.pumpApp(const HelpSupportPage(), [
      premiumStateProvider.overrideWith(
        () => _FakePremiumStateNotifier(
          const PremiumState(
            isPremium: true,
            isLoading: false,
            userId: 'support-123',
          ),
        ),
      ),
    ]);
    addTearDown(() => db.close());

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find
          .byKey(const ValueKey<String>('helpSupport.page'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
    }

    expect(
      find.byKey(const ValueKey<String>('helpSupport.page')),
      findsOneWidget,
    );

    await tester.pumpAndSettle();

    expect(
      find.text(lookupAppLocalizations(const Locale('en')).needHelpTitle),
      findsOneWidget,
    );
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.helpSupportSupportTitle), findsOneWidget);
    expect(find.text(l10n.helpSupportFaqTitle), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('helpSupport.support.website')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('helpSupport.support.email')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('helpSupport.support.id')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('helpSupport.support.roadmap')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('helpSupport.support.id')),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText().contains('support-123'),
        ),
      ),
      findsOneWidget,
    );
    expect(find.text(l10n.helpSupportRoadmapLabel), findsOneWidget);
    expect(find.text(l10n.helpSupportRoadmapValue), findsOneWidget);
    expect(find.text(l10n.helpSupportAppVersionRow('1.2.3')), findsOneWidget);
    expect(find.text(l10n.helpSupportContactSupportButton), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('support.version.tapTarget')),
      findsOneWidget,
    );
    expect(find.text(helpSupportRoadmapUrl), findsNothing);
    expect(find.text(l10n.helpSupportLinksTitle), findsNothing);
    expect(find.text('https://printcostcalc.app'), findsNothing);
    expect(find.text('https://x.com/PrintCostCalc'), findsNothing);
    expect(
      find.text('https://www.instagram.com/3dprintcostcalculator'),
      findsNothing,
    );
    expect(find.text('https://mastodon.social/@printcostcalc'), findsNothing);
    expect(find.text('https://www.threads.com/@printcostcalc'), findsNothing);
    expect(
      find.text(
        'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
      ),
      findsNothing,
    );

    final weightQuestion = find.text(l10n.helpSupportFaqWeightQuestion);
    await tester.drag(
      find.byKey(const ValueKey<String>('helpSupport.page')),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
    await tester.tap(weightQuestion);
    await tester.pumpAndSettle();
    expect(find.text(l10n.helpSupportFaqWeightAnswer), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('helpSupport.faq.premium')),
      200,
    );
    expect(
      find.byKey(const ValueKey<String>('helpSupport.faq.premium')),
      findsOneWidget,
    );
    expect(find.text(l10n.helpSupportFaqPremiumQuestion), findsOneWidget);

    await tester.scrollUntilVisible(find.text(l10n.helpSupportAboutTitle), 300);
    expect(find.text(l10n.helpSupportAboutTitle), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('helpSupport.footer.website')),
      300,
    );
    expect(
      find.byKey(const ValueKey<String>('helpSupport.footer.website')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('helpSupport.footer.x')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('helpSupport.footer.instagram')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('helpSupport.footer.mastodon')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('helpSupport.footer.threads')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('helpSupport.footer.privacy')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('helpSupport.footer.terms')),
      findsOneWidget,
    );
    expect(find.text(l10n.helpSupportPrivacyPolicyLabel), findsOneWidget);
    expect(find.text(l10n.helpSupportTermsOfUseLabel), findsOneWidget);
  });

  testWidgets(
    'initial premium FAQ target shows upgrade CTA and comparison link',
    (tester) async {
      final paywallPresenter = FakePaywallPresenter();
      final db = await tester.pumpApp(
        const HelpSupportPage(
          initialFaqEntryId: HelpSupportPage.premiumFaqEntryId,
        ),
        [
          premiumStateProvider.overrideWith(
            () => _FakePremiumStateNotifier(
              const PremiumState(isPremium: false, isLoading: false),
            ),
          ),
          paywallPresenterProvider.overrideWithValue(paywallPresenter),
        ],
      );
      addTearDown(() => db.close());
      await tester.pumpAndSettle();

      final l10n = lookupAppLocalizations(const Locale('en'));

      expect(find.text(l10n.helpSupportFaqPremiumQuestion), findsOneWidget);
      expect(find.text(l10n.helpSupportFaqPremiumAnswer), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('helpSupport.faq.premium.action')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('helpSupport.faq.premium.action')),
      );
      await tester.pumpAndSettle();

      expect(analyticsCalls, hasLength(1));
      expect(analyticsCalls.single['name'], 'premium_feature_tapped');
      expect(analyticsCalls.single['feature'], 'faq_premium_card');
      expect(analyticsCalls.single['is_pro'], 0);
      expect(analyticsCalls.single['source'], 'faq');
      expect(paywallPresenter.calls, 1);
      expect(paywallPresenter.lastOfferingId, 'pro');
      expect(paywallPresenter.lastTriggerFeature, 'faq_premium_card');
      expect(paywallPresenter.lastPurchaseSource, 'faq');
      expect(paywallPresenter.lastSource, 'faq');

      await tester.tap(
        find.byKey(const ValueKey<String>('helpSupport.faq.premium.link')),
      );
      await tester.pumpAndSettle();

      expect(launchCalls, isNotEmpty);
      expect(
        launchCalls.last.arguments.toString(),
        contains(helpSupportPlansUrl),
      );
    },
  );

  testWidgets('premium users do not see FAQ upgrade CTA', (tester) async {
    final db = await tester.pumpApp(
      const HelpSupportPage(
        initialFaqEntryId: HelpSupportPage.premiumFaqEntryId,
      ),
      [
        premiumStateProvider.overrideWith(
          () => _FakePremiumStateNotifier(
            const PremiumState(isPremium: true, isLoading: false),
          ),
        ),
      ],
    );
    addTearDown(() => db.close());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('helpSupport.faq.premium.action')),
      findsNothing,
    );
  });

  testWidgets('contact support sends email with app version and support id', (
    tester,
  ) async {
    final db = await tester.pumpApp(const HelpSupportPage(), [
      premiumStateProvider.overrideWith(
        () => _FakePremiumStateNotifier(
          const PremiumState(
            isPremium: true,
            isLoading: false,
            userId: 'id-42',
          ),
        ),
      ),
    ]);
    addTearDown(() => db.close());
    await tester.pumpAndSettle();

    final contactButton = find.byKey(
      const ValueKey<String>('helpSupport.contact.button'),
    );
    await tester.ensureVisible(contactButton);
    await tester.tap(contactButton);
    await tester.pumpAndSettle();

    expect(emailCalls, hasLength(1));
    expect(emailCalls.single.recipients, ['3d@printcostcalc.app']);
    expect(emailCalls.single.subject, '3D Print Cost Calculator Support');
    expect(emailCalls.single.body, contains('Support ID: id-42'));
    expect(emailCalls.single.body, contains('App version: 1.2.3'));
  });
}

class _FakeFlutterEmailSenderPlatform extends FlutterEmailSenderPlatform {
  _FakeFlutterEmailSenderPlatform({required this.onSend});

  final void Function(Email email) onSend;

  @override
  Future<void> send(Email email) async {
    onSend(email);
  }

  @override
  Future<EmailCapabilities> getCapabilities() async {
    return const EmailCapabilities.none();
  }
}

class _FakeAnalyticsService implements AnalyticsService {
  _FakeAnalyticsService({required this.onLogEvent});

  final void Function(String name, Map<String, Object>? params) onLogEvent;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    onLogEvent(name, params);
  }
}

class _FakePremiumStateNotifier extends PremiumStateNotifier {
  _FakePremiumStateNotifier(this._state);

  final PremiumState _state;

  @override
  PremiumState build() => _state;
}
