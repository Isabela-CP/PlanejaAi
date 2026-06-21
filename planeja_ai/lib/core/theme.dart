import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cores mais tranquilas
  static const Color _primaryLight = Color(0xFFD4A017); // Amarelo/Ouro mais suave
  static const Color _primaryDark = Color(0xFFF2C230); // Amarelo original
  
  static const Color _bgLight = Color(0xFFF5F0E6); // Bege/Cinza quente bem suave
  static const Color _surfaceLight = Color(0xFFFFFDF9); // Off-white aconchegante
  
  static const Color _bgDark = Color(0xFF202124); // Cinza escuro Google
  static const Color _surfaceDark = Color(0xFF292A2D); // Cinza um pouco mais claro para cards/menu

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primaryLight,
        secondary: Color(0xFFF2E085),
        tertiary: Color(0xFF8C3807),
        surface: _surfaceLight,
        background: _bgLight,
        error: Color(0xFFEF4444),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: const Color(0xFF333333),
        displayColor: const Color(0xFF1A1A1A),
      ),
      scaffoldBackgroundColor: _bgLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF333333)),
        titleTextStyle: TextStyle(color: Color(0xFF1A1A1A), fontSize: 20, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _primaryLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF333333),
        ),
      ),
      cardTheme: const CardThemeData(
        color: _surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _primaryLight, width: 2)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primaryDark,
        secondary: Color(0xFFF2E085),
        tertiary: Color(0xFF8C3807),
        surface: _surfaceDark,
        background: _bgDark,
        error: Color(0xFFCF6679),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: const Color(0xFFE8EAED),
        displayColor: Colors.white,
      ),
      scaffoldBackgroundColor: _bgDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFFE8EAED)),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _primaryDark,
          foregroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryDark,
        ),
      ),
      cardTheme: const CardThemeData(
        color: _surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: Color(0xFF3C4043), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _bgDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3C4043))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3C4043))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _primaryDark, width: 2)),
      ),
    );
  }
}
