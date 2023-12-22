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

const DARK_BLUE = Color.fromRGBO(26, 28, 43, 1);
const DEEP_BLUE = Color.fromRGBO(13, 13, 23, 1);
const LIGHT_BLUE = Color.fromRGBO(84, 153, 254, 1);

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
  final themeData = ThemeData(
    brightness: Brightness.dark,
    textTheme: const TextTheme(
      displayMedium: TextStyle(
        color: LIGHT_BLUE,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        color: Colors.white54,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: Colors.white54,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  return themeData.copyWith(
    textTheme: GoogleFonts.montserratTextTheme(themeData.textTheme),
    scaffoldBackgroundColor: DARK_BLUE,
    appBarTheme: AppBarTheme(
      backgroundColor: DEEP_BLUE,
      titleTextStyle: themeData.textTheme.displayMedium,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: DEEP_BLUE,
      selectedItemColor: LIGHT_BLUE,
      unselectedItemColor: Colors.white54,
    ),
    dialogTheme: const DialogTheme(backgroundColor: DEEP_BLUE),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: DARK_BLUE,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
    ),
  );
}
