import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/typography.dart';

export 'package:threed_print_cost_calculator/shared/app_colors.dart';

ThemeData theme() {
  final themeData = ThemeData(
    brightness: Brightness.dark,
    fontFamily: AppTypography.fontFamily,
    textTheme: AppTypography.textTheme,
  );

  return themeData.copyWith(
    textTheme: themeData.textTheme,
    primaryTextTheme: themeData.textTheme,
    scaffoldBackgroundColor: APP_BACKGROUND,
    appBarTheme: AppBarTheme(
      backgroundColor: APP_BACKGROUND,
      elevation: 0,
      titleTextStyle: themeData.textTheme.headlineSmall,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: NAV_BAR_BACKGROUND,
      selectedItemColor: LIGHT_BLUE,
      unselectedItemColor: Colors.white54,
    ),
    dialogTheme: const DialogThemeData(backgroundColor: DEEP_BLUE),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: DARK_BLUE,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
  );
}
