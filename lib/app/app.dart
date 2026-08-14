import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:threed_print_cost_calculator/app/app_page.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/services/app_usage_service.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

@visibleForTesting
Future<void> showRateMyAppPrompt({
  required BuildContext context,
  required RateMyApp rateMyApp,
  required bool isEligible,
  required AppLogger logger,
}) async {
  final shouldOpenDialog = rateMyApp.shouldOpenDialog;

  await AppAnalytics.reviewPromptEligibilityChecked(eligible: isEligible);
  await AppAnalytics.reviewPromptEligibilityResult(
    eligible: isEligible && shouldOpenDialog,
  );

  if (!isEligible || !shouldOpenDialog) {
    return;
  }

  bool? nativeSupported;
  try {
    nativeSupported = await rateMyApp.isNativeReviewDialogSupported;
  } catch (e, st) {
    logger.warn(
      AppLogCategory.ui,
      'Rate prompt native capability check failed',
      error: e,
      stackTrace: st,
    );
  }

  if (!context.mounted) {
    return;
  }

  await AppAnalytics.reviewPromptRequestAttempted(
    nativeSupported: nativeSupported,
  );

  if (nativeSupported != true) {
    await AppAnalytics.reviewPromptCustomDialogShown();
  }

  if (!context.mounted) {
    return;
  }

  var customDialogActionTaken = false;
  try {
    await rateMyApp.showRateDialog(
      context,
      listener: (button) {
        customDialogActionTaken = true;
        unawaited(
          AppAnalytics.reviewPromptCustomDialogAction(action: button.name),
        );
        return true;
      },
      onDismissed: () {
        if (!customDialogActionTaken) {
          unawaited(AppAnalytics.reviewPromptCustomDialogDismissed());
        }
      },
    );
  } catch (e, st) {
    logger.warn(
      AppLogCategory.ui,
      'Rate dialog failed to open',
      error: e,
      stackTrace: st,
    );
  }
}

class _AppState extends ConsumerState<App> {
  @override
  void dispose() {
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
            await showRateMyAppPrompt(
              context: context,
              rateMyApp: rateMyApp,
              isEligible: isRateMyAppEligible,
              logger: logger,
            );
          },
          builder: (_) => const AppPage(),
        ),
      ),
    );
  }
}
