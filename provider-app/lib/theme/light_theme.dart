import 'package:flutter/material.dart';

import 'custom_theme_colors.dart';

/// Option B — Royal Blue palette
/// Primary: #2563EB · Primary Dark: #1D4ED8 · Gradient Deep: #1E40AF
/// Gradient End: #3B82F6 · Scaffold: #F7F8FA · Card: #FFFFFF
class AppThemeColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color gradientDeep = Color(0xFF1E40AF);
  static const Color gradientEnd = Color(0xFF3B82F6);
  static const Color primaryLight = Color(0xFFDBEAFE);
  static const Color scaffold = Color(0xFFF7F8FA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
  static const Color secondary = Color(0xFF0EA5E9);
}

ThemeData light = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: AppThemeColors.primary,
  primaryColorLight: AppThemeColors.primaryLight,
  primaryColorDark: AppThemeColors.primaryDark,
  scaffoldBackgroundColor: AppThemeColors.scaffold,
  cardColor: AppThemeColors.card,

  shadowColor: const Color(0xFFE4E7EC),
  canvasColor: AppThemeColors.card,

  secondaryHeaderColor: const Color(0xFF758493),
  disabledColor: const Color(0xFFB9C0CC),
  brightness: Brightness.light,
  hintColor: const Color(0xFF9AA1AC),
  focusColor: const Color(0xFFEFF6FF),
  hoverColor: AppThemeColors.primary,
  extensions: <ThemeExtension<CustomThemeColors>>[CustomThemeColors.light()],
  colorScheme: const ColorScheme.light(
    primary: AppThemeColors.primary,
    secondary: AppThemeColors.secondary,
    onSecondary: Color(0xFFFFFFFF),
    tertiary: AppThemeColors.primaryDark,
    onSecondaryContainer: AppThemeColors.success,
    onPrimary: Color(0xFFFFFFFF),
    error: AppThemeColors.danger,
  ).copyWith(surface: AppThemeColors.scaffold),

  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: AppThemeColors.primary,
    selectionHandleColor: AppThemeColors.primary,
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppThemeColors.primary),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppThemeColors.primary,
      foregroundColor: Colors.white,
      disabledForegroundColor: Colors.white70,
      disabledBackgroundColor: const Color(0xFFB9C0CC),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppThemeColors.primary,
      side: const BorderSide(color: Color(0x4D2563EB), width: 1.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF3F5F8),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: const TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      color: Color(0xFF9AA1AC),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: const Color(0xFFE9EAEC), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: AppThemeColors.primary.withValues(alpha: 0.8),
        width: 1.3,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppThemeColors.danger, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppThemeColors.danger, width: 1.3),
    ),
  ),

  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: false,
    surfaceTintColor: Colors.transparent,
    backgroundColor: AppThemeColors.scaffold,
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppThemeColors.primary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: const Color(0xFF1E293B),
    contentTextStyle: const TextStyle(
      fontFamily: 'Roboto',
      color: Colors.white,
      fontSize: 14,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  timePickerTheme: const TimePickerThemeData(
    hourMinuteTextColor: Color(0xFF10324a),
  ),
  datePickerTheme: const DatePickerThemeData(),

  dividerTheme: const DividerThemeData(
    thickness: 0.5,
    color: Color(0x1A9AA1AC),
  ),
);
