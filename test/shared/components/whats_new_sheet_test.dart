import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';
import 'package:threed_print_cost_calculator/app/help_support/help_support_links.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/shared/components/whats_new_sheet.dart';
import 'package:threed_print_cost_calculator/shared/models/whats_new_announcement.dart';

import '../../helpers/lower_level_test_fakes.dart';

class _FakeAnalytics implements AnalyticsService {
  String? lastName;
  Map<String, Object>? lastParams;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    lastName = name;
    lastParams = params;
  }
}

void main() {
  late _FakeAnalytics fake;
  final urlLauncherChannel = const MethodChannel(
    'plugins.flutter.io/url_launcher',
  );
  final launchCalls = <MethodCall>[];

  const announcement = WhatsNewAnnouncement(
    id: 'wn_42',
    locales: {
      'en': WhatsNewAnnouncementLocale(
        title: 'Title',
        body: 'Body',
        cta: 'Got it',
        unlockProCta: 'Start free trial',
      ),
    },
  );

  setUp(() {
    fake = _FakeAnalytics();
    AppAnalytics.service = fake;
    launchCalls.clear();
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

  testWidgets('logs shown on insert and dismissed after got it', (
    tester,
  ) async {
    var dismissCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showWhatsNewSheet(
                    context,
                    announcement: announcement,
                    onDismiss: () async {
                      dismissCount += 1;
                    },
                    wnId: announcement.id,
                    locale: 'en',
                    isPremium: false,
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(fake.lastName, 'whats_new_shown');
    expect(fake.lastParams, {
      'wn_id': 'wn_42',
      'locale': 'en',
      'is_premium': 0,
    });

    await tester.tap(find.text('Got it'));
    await tester.pump();

    expect(dismissCount, 1);

    expect(fake.lastName, 'whats_new_dismissed');
    expect(fake.lastParams, {
      'wn_id': 'wn_42',
      'locale': 'en',
      'is_premium': 0,
    });
  });

  testWidgets('start free trial opens paywall presenter', (tester) async {
    final paywallPresenter = FakePaywallPresenter();
    var dismissCount = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          paywallPresenterProvider.overrideWithValue(paywallPresenter),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showWhatsNewSheet(
                      context,
                      announcement: announcement,
                      onDismiss: () async {
                        dismissCount += 1;
                      },
                      wnId: announcement.id,
                      locale: 'en',
                      isPremium: false,
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Start free trial'), findsOneWidget);

    await tester.tap(find.text('Start free trial'));
    await tester.pumpAndSettle();

    expect(dismissCount, 1);
    expect(paywallPresenter.calls, 1);
    expect(paywallPresenter.lastOfferingId, 'pro');
    expect(paywallPresenter.lastTriggerFeature, 'whats_new');
    expect(paywallPresenter.lastPurchaseSource, 'whats_new');
    expect(paywallPresenter.lastSource, 'whats_new');
  });

  testWidgets('recent updates link opens roadmap externally', (tester) async {
    var dismissCount = 0;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showWhatsNewSheet(
                      context,
                      announcement: announcement,
                      onDismiss: () async {
                        dismissCount += 1;
                      },
                      wnId: announcement.id,
                      locale: 'en',
                      isPremium: false,
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('See recent updates'));
    await tester.pumpAndSettle();

    expect(launchCalls, isNotEmpty);
    expect(
      launchCalls.last.arguments.toString(),
      contains(helpSupportRoadmapUrl),
    );
    expect(dismissCount, 0);
    expect(find.text('Got it'), findsOneWidget);
  });
}
