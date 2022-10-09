// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:platform_info/platform_info.dart';
import 'package:threed_print_cost_calculator/calculator/calculator.dart';
import 'package:threed_print_cost_calculator/l10n/l10n.dart';
import 'package:upgrader/upgrader.dart';

part 'minimum_app_version.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors.green,
            ),
            textStyle: MaterialStateProperty.all<TextStyle>(
              const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: UpgradeAlert(
        upgrader: Upgrader(
          minAppVersion: '1.0.4',
          dialogStyle: Platform.I.operatingSystem == OperatingSystem.iOS ?
          UpgradeDialogStyle.cupertino : UpgradeDialogStyle.material,
        ),
        child: const CalculatorPage(),
      ),
    );
  }
}
