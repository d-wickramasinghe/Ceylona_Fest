import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const primary = Color(0xFFC8932A);
  static const primaryDark = Color(0xFF1F1B16);
  static const background = Color(0xFFFAF6EF);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE8DFC8);
  static const secondaryText = Color(0xFF6B6358);
  static const success = Color(0xFF2E8B57);
  static const warning = Color(0xFFD9A441);
  static const error = Color(0xFFC0392B);
  static const info = Color(0xFF3B6EA5);
}

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700),
      displayMedium: GoogleFonts.poppins(fontWeight: FontWeight.w700),
      displaySmall: GoogleFonts.poppins(fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w700),
      headlineSmall: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      labelLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600),
    );

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.primaryDark,
        surface: AppColors.surface,
        onSurface: AppColors.primaryDark,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme.apply(
        bodyColor: AppColors.primaryDark,
        displayColor: AppColors.primaryDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.secondaryText),
        border: _inputBorder(),
        enabledBorder: _inputBorder(),
        focusedBorder: _inputBorder(width: 2, color: AppColors.primary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryDark,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary,
        elevation: 2,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }

  static OutlineInputBorder _inputBorder({
    Color color = AppColors.border,
    double width = 1,
  }) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
}
