import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';
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

  const announcement = WhatsNewAnnouncement(
    id: 'wn_42',
    locales: {
      'en': WhatsNewAnnouncementLocale(
        title: 'Title',
        body: 'Body',
        cta: 'Got it',
        unlockProCta: 'Unlock Pro',
      ),
    },
  );

  setUp(() {
    fake = _FakeAnalytics();
    AppAnalytics.service = fake;
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

  testWidgets('unlock pro opens paywall presenter', (tester) async {
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

    await tester.tap(find.text('Unlock Pro'));
    await tester.pumpAndSettle();

    expect(dismissCount, 1);
    expect(paywallPresenter.calls, 1);
    expect(paywallPresenter.lastOfferingId, 'pro');
    expect(paywallPresenter.lastTriggerFeature, 'whats_new');
    expect(paywallPresenter.lastPurchaseSource, 'whats_new');
    expect(paywallPresenter.lastSource, 'whats_new');
  });
}
