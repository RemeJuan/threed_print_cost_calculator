import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const DARK_BLUE = Color.fromRGBO(26, 28, 43, 1);
const DEEP_BLUE = Color.fromRGBO(13, 13, 23, 1);
const LIGHT_BLUE = Color.fromRGBO(84, 153, 254, 1);

ThemeData theme() {
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
    dialogTheme: const DialogThemeData(backgroundColor: DEEP_BLUE),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: DARK_BLUE,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
  );
}
