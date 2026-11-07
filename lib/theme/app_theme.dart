import 'package:flutter/material.dart';

class AppTheme {
  // Versity Dark Palette (Ultra Dark Background + Electric Cyan/Blue Accent)
  static const Color vantaBlack = Color(0xFF0C0C0F);        // Deepest dark background
  static const Color vantaSurfaceDark = Color(0xFF16161C);  // Dark container card
  static const Color vantaCardDark = Color(0xFF1E1E26);     // Dark card level 2
  static const Color vantaBorder = Color(0xFF2B2B36);       // Crisp dark border stroke
  
  // Accents (User preference: Electric Blue / Cyan instead of Yellow)
  static const Color vantaBlue = Color(0xFF00B4D8);         // Electric Cyan Blue Accent
  static const Color vantaBlueDark = Color(0xFF007791);     // Darker Blue for pressed
  static const Color vantaWhite = Color(0xFFFFFFFF);        // Floating Card Pure White
  
  // Text Colors
  static const Color vantaTextDark = Color(0xFF0D0D11);     // Text inside white cards
  static const Color vantaTextLight = Color(0xFFFFFFFF);    // Primary text on dark
  static const Color vantaTextMuted = Color(0xFF8E8E9F);    // Subtitles & muted labels
  static const Color vantaSubtleBorder = Color(0xFFE2E8F0); // Light divider inside white card

  // Indicators
  static const Color successGreen = Color(0xFF22C55E);
  static const Color dangerRed = Color(0xFFEF4444);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: vantaBlack,
      primaryColor: vantaBlue,
      colorScheme: const ColorScheme.dark(
        primary: vantaBlue,
        secondary: vantaWhite,
        surface: vantaSurfaceDark,
        error: dangerRed,
        onSurface: vantaTextLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: vantaTextLight,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(color: vantaTextLight),
      ),
      cardTheme: CardThemeData(
        color: vantaSurfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: vantaBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: vantaBorder,
        thickness: 1,
      ),
    );
  }
}
