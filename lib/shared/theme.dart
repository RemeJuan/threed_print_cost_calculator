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
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: SHELL_BACKGROUND,
      selectedItemColor: LIGHT_BLUE,
      unselectedItemColor: Colors.white54,
    ),
    dialogTheme: const DialogThemeData(backgroundColor: SHELL_BACKGROUND),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: SHELL_BACKGROUND,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
  );
}
