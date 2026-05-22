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

  UnderlineInputBorder underlineBorder(Color color) {
    return UnderlineInputBorder(borderSide: BorderSide(color: color));
  }

  return themeData.copyWith(
    inputDecorationTheme: InputDecorationTheme(
      border: underlineBorder(OFF_WHITE),
      enabledBorder: underlineBorder(OFF_WHITE.withValues(alpha: 0.7)),
      focusedBorder: underlineBorder(LIGHT_BLUE),
      disabledBorder: underlineBorder(OFF_WHITE.withValues(alpha: 0.35)),
      errorBorder: underlineBorder(themeData.colorScheme.error),
      focusedErrorBorder: underlineBorder(themeData.colorScheme.error),
      floatingLabelStyle: const TextStyle(color: LIGHT_BLUE),
      prefixIconColor: LIGHT_BLUE,
      suffixIconColor: LIGHT_BLUE,
    ),
    textTheme: themeData.textTheme,
    primaryTextTheme: themeData.textTheme,
    scaffoldBackgroundColor: APP_BACKGROUND,
    appBarTheme: AppBarTheme(
      backgroundColor: APP_BACKGROUND,
      elevation: 0,
      titleTextStyle: themeData.textTheme.headlineSmall,
      scrolledUnderElevation: 0,
      surfaceTintColor: TRANSPARENT_COLOR,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: SHELL_BACKGROUND,
      selectedItemColor: LIGHT_BLUE,
      unselectedItemColor: ICON_MUTED,
    ),
    dialogTheme: const DialogThemeData(backgroundColor: SHELL_BACKGROUND),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return LIGHT_BLUE;
          return TRANSPARENT_COLOR;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return DEEP_BLUE;
          return MUTED_BLUE_GREY;
        }),
        side: WidgetStateProperty.all(const BorderSide(color: OFF_WHITE)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: SHELL_BACKGROUND,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
  );
}
