import 'package:flutter/material.dart';

class ThemeManager {
  static const Color primaryBlue = Color.fromARGB(255, 68, 118, 164);
  static const Color primaryYellow = Color(0xFFE4973F);
  static const Color errorRed = Colors.red;
  static const Color successGreen = Colors.green;

  static const Color backgroundGrey = Color(0xFFD5D5D5);

  static const Color darkBackground = Color(0xFF081022);

  static const Color darkCard = Color(0xFF202A3C);

  static const TextTheme _lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
    bodySmall: TextStyle(fontSize: 12, color: Colors.grey),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );

  static const TextTheme _darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.white, height: 1.4),
    bodySmall: TextStyle(fontSize: 12, color: Colors.grey),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      popupMenuTheme: PopupMenuThemeData(color: Colors.white),
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundGrey,
      cardColor: Colors.white,
      navigationBarTheme: NavigationBarThemeData(backgroundColor: Colors.white),
      textTheme: _lightTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: _lightTextTheme.labelLarge,
        ),
      ),

      dividerColor: const Color(0xFFEEEEEE),
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        primary: primaryBlue,
        secondary: primaryYellow,
        surfaceContainerHighest: const Color(0xFFFAFAFA),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      popupMenuTheme: PopupMenuThemeData(color: Color(0xFF303E5C)),
      brightness: Brightness.dark,
      primaryColor: Color.fromARGB(255, 106, 162, 220),
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkCard,
      navigationBarTheme: NavigationBarThemeData(backgroundColor: darkCard),
      textTheme: _darkTextTheme,

      appBarTheme: const AppBarTheme(
        backgroundColor: darkCard,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: _darkTextTheme.labelLarge,
        ),
      ),

      dividerColor: const Color(0xFF333333),
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        primary: primaryBlue,
        secondary: primaryYellow,
        surface: darkBackground,
        surfaceContainerHighest: darkCard,
      ),
    );
  }
}
