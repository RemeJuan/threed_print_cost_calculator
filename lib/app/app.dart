import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:threed_print_cost_calculator/app/app_page.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/backup_restore/automatic_backup_service.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/services/app_usage_service.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  ProviderSubscription<PremiumState>? _premiumStateSubscription;

  @override
  void initState() {
    super.initState();
    _reconcileBackups(ref.read(premiumStateProvider).isPremium);
    _premiumStateSubscription = ref.listenManual(premiumStateProvider, (
      _,
      next,
    ) {
      _reconcileBackups(next.isPremium);
    });
  }

  void _reconcileBackups(bool isPremium) {
    unawaited(
      ref.read(automaticBackupServiceProvider).reconcile(isPremium).catchError((
        Object error,
      ) {
        ref
            .read(appLoggerProvider)
            .error(
              AppLogCategory.provider,
              'Backup reconcile failed',
              error: error,
            );
      }),
    );
  }

  @override
  void dispose() {
    _premiumStateSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logger = ref.read(appLoggerProvider);
    final isRateMyAppEligible = ref.watch(rateMyAppEligibilityProvider);
    AppAnalytics.logger = logger;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          overscroll: false,
          physics: const ClampingScrollPhysics(),
        ),
        builder: BotToastInit(),
        debugShowCheckedModeBanner: false,
        navigatorKey: appNavigatorKey,
        navigatorObservers: [BotToastNavigatorObserver()],
        theme: theme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RateMyAppBuilder(
          rateMyApp: RateMyApp(
            minDays: 14,
            minLaunches: 10,
            remindDays: 14,
            remindLaunches: 10,
            googlePlayIdentifier: 'com.threed_print_calculator',
            appStoreIdentifier: '6444106268',
          ),
          onInitialized: (context, rateMyApp) async {
            if (isRateMyAppEligible && rateMyApp.shouldOpenDialog) {
              try {
                rateMyApp.showRateDialog(context);
              } catch (e) {
                logger.warn(
                  AppLogCategory.ui,
                  'Rate dialog failed to open',
                  error: e,
                );
              }
            }
          },
          builder: (_) => const AppPage(),
        ),
      ),
    );
  }
}
