import 'package:flutter/material.dart';

import 'custom_theme_colors.dart';

/// "Ink" — black & white theme.
/// Ink: #111111 · Paper: #FFFFFF · Scaffold: #F6F6F6 · Hairline: #E9E9EB
class AppThemeColors {
  static const Color primary = Color(0xFF111111);
  static const Color primaryDark = Color(0xFF000000);
  static const Color gradientDeep = Color(0xFF1C1C1C);
  static const Color gradientEnd = Color(0xFF2E2E2E);
  static const Color primaryLight = Color(0xFFEDEDED);
  static const Color scaffold = Color(0xFFF6F6F6);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111111);
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color secondary = Color(0xFF6B6B6B);
}

ThemeData light = ThemeData(
  fontFamily: 'Manrope',
  primaryColor: AppThemeColors.primary,
  primaryColorLight: AppThemeColors.primaryLight,
  primaryColorDark: AppThemeColors.primaryDark,
  scaffoldBackgroundColor: AppThemeColors.scaffold,
  cardColor: AppThemeColors.card,

  shadowColor: const Color(0xFFE5E5E5),
  canvasColor: AppThemeColors.card,

  secondaryHeaderColor: const Color(0xFF6B6B6B),
  disabledColor: const Color(0xFFB9C0CC),
  brightness: Brightness.light,
  hintColor: const Color(0xFF8E8E93),
  focusColor: const Color(0xFFEFEFEF),
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
        fontFamily: 'Manrope',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppThemeColors.primary,
      side: const BorderSide(color: Color(0x33111111), width: 1.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF3F3F4),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: const TextStyle(
      fontFamily: 'Manrope',
      fontSize: 14,
      color: Color(0xFF9CA0A8),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE9E9EB), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF111111), width: 1.3),
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
    backgroundColor: const Color(0xFF111111),
    contentTextStyle: const TextStyle(
      fontFamily: 'Manrope',
      color: Colors.white,
      fontSize: 14,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  timePickerTheme: const TimePickerThemeData(
    hourMinuteTextColor: Color(0xFF111111),
  ),
  datePickerTheme: const DatePickerThemeData(),

  dividerTheme: const DividerThemeData(
    thickness: 0.5,
    color: Color(0x14111111),
  ),
);
