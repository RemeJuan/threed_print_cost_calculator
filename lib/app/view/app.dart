// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:threed_print_cost_calculator/app/view/app_page.dart';
import 'package:threed_print_cost_calculator/l10n/l10n.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return RateMyAppBuilder(
      rateMyApp: RateMyApp(
        minDays: 3,
        minLaunches: 7,
        remindDays: 2,
        remindLaunches: 5,
        googlePlayIdentifier: 'com.threed_print_calculator',
        appStoreIdentifier: 'com.threed-print-calculator',
      ),
      onInitialized: (context, rateMyApp) {
        if (rateMyApp.shouldOpenDialog) {
          rateMyApp.showRateDialog(context);
        }
      },
      builder: (context) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: MaterialApp(
            builder: BotToastInit(),
            debugShowCheckedModeBanner: false,
            navigatorObservers: [BotToastNavigatorObserver()],
            theme: _theme(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppPage(),
          ),
        );
      },
    );
  }
}

ThemeData _theme() {
  final themeData = ThemeData(brightness: Brightness.dark);

  return themeData.copyWith(
    useMaterial3: true,
    textTheme: GoogleFonts.montserratTextTheme(themeData.textTheme),
    scaffoldBackgroundColor: const Color.fromRGBO(27, 39, 56, 1),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromRGBO(23, 31, 44, 1),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color.fromRGBO(23, 31, 44, 1),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
    ),
  );
}
