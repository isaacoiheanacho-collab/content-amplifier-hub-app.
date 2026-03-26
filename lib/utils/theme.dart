import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFFF6B35);
  static const primaryDark = Color(0xFFE65A2B);
  static const accent = Color(0xFF0A1F44);
  static const background = Color(0xFFF5F7FB);
  static const card = Colors.white;
  static const textPrimary = Color(0xFF0A1F44);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
}

ThemeData buildAppTheme() {
  final base = ThemeData.light();
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.primary,
      secondary: AppColors.accent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.accent),
      titleTextStyle: TextStyle(
        color: AppColors.accent,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}