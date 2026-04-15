import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:threed_print_cost_calculator/app/app_page.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logger = ref.read(appLoggerProvider);
    AppAnalytics.logger = logger;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        builder: BotToastInit(),
        debugShowCheckedModeBanner: false,
        navigatorObservers: [BotToastNavigatorObserver()],
        theme: theme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RateMyAppBuilder(
          rateMyApp: RateMyApp(
            minDays: 3,
            minLaunches: 7,
            remindDays: 2,
            remindLaunches: 5,
            googlePlayIdentifier: 'com.threed_print_calculator',
            appStoreIdentifier: 'com.threed-print-calculator',
          ),
          onInitialized: (context, rateMyApp) async {
            if (rateMyApp.shouldOpenDialog) {
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
