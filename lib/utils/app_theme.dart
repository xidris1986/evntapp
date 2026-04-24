import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _primaryColorLight = Color(0xFF1A73E8);
  static const _primaryColorDark = Color(0xFF89B4F7);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColorLight,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: _primaryColorLight,
        foregroundColor: Colors.white,
        shadowColor: Colors.black26,
        surfaceTintColor: _primaryColorLight,
      ),
      cardTheme: const CardThemeData(
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.black26,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColorLight.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColorLight, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.all(16),
        prefixIconColor: Colors.grey.shade600,
        suffixIconColor: Colors.grey.shade600,
      ),
      dividerTheme: const DividerThemeData(
        space: 32,
        thickness: 1,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColorDark,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        shadowColor: Colors.black26,
        surfaceTintColor: _primaryColorDark,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black45,
        color: Colors.grey.shade900,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.black45,
          backgroundColor: _primaryColorDark,
          foregroundColor: Colors.black87,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColorDark.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColorDark, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade900,
        contentPadding: const EdgeInsets.all(16),
        prefixIconColor: Colors.grey.shade400,
        suffixIconColor: Colors.grey.shade400,
      ),
      dividerTheme: const DividerThemeData(
        space: 32,
        thickness: 1,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }
}