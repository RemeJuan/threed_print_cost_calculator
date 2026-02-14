import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:threed_print_cost_calculator/app/app_page.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        builder: BotToastInit(),
        debugShowCheckedModeBanner: false,
        navigatorObservers: [BotToastNavigatorObserver()],
        theme: theme(),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
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
                debugPrint(e.toString());
              }
            }
          },
          builder: (_) => const AppPage(),
        ),
      ),
    );
  }
}
