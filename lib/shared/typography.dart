import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';

class AppTypography {
  AppTypography._();

  static const fontFamily = 'Inter';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      color: OFF_WHITE,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      height: 1.1,
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      color: LIGHT_BLUE,
      fontSize: 22,
      fontWeight: FontWeight.bold,
      height: 1.1,
    ),
    displaySmall: TextStyle(
      fontFamily: fontFamily,
      color: OFF_WHITE,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.15,
    ),
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      color: OFF_WHITE,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.15,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      color: OFF_WHITE,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.15,
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      color: OFF_WHITE,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.15,
    ),
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      color: OFF_WHITE,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      color: OFF_WHITE,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.2,
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      color: LIGHT_BLUE,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      color: OFF_WHITE,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.35,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      color: OFF_WHITE,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.35,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      color: MUTED_BLUE_GREY,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.35,
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      color: OFF_WHITE,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.2,
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      color: OFF_WHITE,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.2,
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      color: MUTED_BLUE_GREY,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.2,
    ),
  );
}
