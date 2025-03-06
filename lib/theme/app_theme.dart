import 'package:flutter/material.dart';

class AppTheme {
  static const String englishFont = 'Poppins'; // Font for English
  static const String arabicFont = 'Tajawal'; // Font for Arabic (supports Arabic script)

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF264653), // Dark teal
    scaffoldBackgroundColor: const Color(0xFFF4F4F4), // Light gray
    fontFamily: englishFont, // Default font
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF264653),
      secondary: Color(0xFF2A9D8F), // Light green
    ),
    textTheme: _getTextTheme(englishFont, const Color(0xFF264653)), // Dark text
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2A9D8F),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF23395B), // Dark blue
    scaffoldBackgroundColor: const Color(0xFF23395B), // Match splash screen
    fontFamily: englishFont, // Default font
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF23395B),
      secondary: Color(0xFFA5D6A7), // Light green for highlights
    ),
    textTheme: _getTextTheme(englishFont, Colors.white), // Light text
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFA5D6A7), // Light green button
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
    ),
  );

  // Dynamic TextTheme based on font and color
  static TextTheme _getTextTheme(String font, Color color) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color, fontFamily: font),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color, fontFamily: font),
      bodyLarge: TextStyle(fontSize: 16, color: color, fontFamily: font),
      bodyMedium: TextStyle(fontSize: 14, color: color, fontFamily: font),
    );
  }

  // Function to dynamically switch font based on locale
  static ThemeData getLocalizedTheme(String locale, bool isDark) {
    final font = locale == 'ar' ? arabicFont : englishFont;
    final baseTheme = isDark ? darkTheme : lightTheme;

    return baseTheme.copyWith(
      textTheme: _getTextTheme(font, isDark ? Colors.white : const Color(0xFF264653)),
    );
  }
}
