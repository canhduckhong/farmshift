import 'package:flutter/material.dart';

class AppTheme {
  // Primary color from the frontend project
  static const Color primaryColor = Color(0xFF0EA5E9); // primary-500
  static const Color primaryLightColor = Color(0xFF7DD3FC); // primary-300
  static const Color primaryDarkColor = Color(0xFF0369A1); // primary-700
  static const Color primaryVeryLightColor = Color(0xFFE0F2FE); // primary-100
  
  // Background color
  static const Color backgroundColor = Color(0xFFF9FAFB); // gray-50
  
  // Text colors
  static const Color textDarkColor = Color(0xFF1F2937); // gray-800
  static const Color textMediumColor = Color(0xFF6B7280); // gray-500
  static const Color textLightColor = Color(0xFF9CA3AF); // gray-400
  
  // Other UI colors
  static const Color surfaceColor = Colors.white;
  static const Color borderColor = Color(0xFFE5E7EB); // gray-200
  
  // Create the theme
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryLightColor,
        background: backgroundColor,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSecondary: textDarkColor,
        onBackground: textDarkColor,
        onSurface: textDarkColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: surfaceColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDarkColor,
        ),
        displayMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDarkColor,
        ),
        displaySmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textDarkColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textDarkColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textDarkColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textMediumColor,
        ),
      ),
      fontFamily: 'Roboto',
      useMaterial3: true,
    );
  }
}
