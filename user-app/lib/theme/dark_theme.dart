import 'package:jdds/theme/custom_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Black & white "nest." design system - dark mode updated from designnew
/// background #0D0D0D Â· card #171717 Â· primary #F1F1F1 (white-on-black)
/// border radius: 16px Â· font: DM Sans
ThemeData dark = ThemeData(
  useMaterial3: false,
  primaryColor: const Color(0xFFF1F1F1),
  primaryColorLight: const Color(0xFF262626),
  primaryColorDark: const Color(0xFF0D0D0D),
  secondaryHeaderColor: const Color(0xFFB3B3B3),
  disabledColor: const Color(0xFF6B6B6B),
  scaffoldBackgroundColor: const Color(0xFF0D0D0D),
  brightness: Brightness.dark,
  hintColor: const Color(0xFFB3B3B3),
  focusColor: const Color(0xFF262626),
  hoverColor: const Color(0xFF262626),
  shadowColor: const Color(0xFF262626),
  cardColor: const Color(0xFF171717),
  extensions: <ThemeExtension<CustomThemeColors>>[
    CustomThemeColors.dark(),
  ],

  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFF1F1F1),
    secondary: Color(0xFFB3B3B3),
    onSecondary: Color(0xFF0D0D0D),
    tertiary: Color(0xFFE5E5E5),
    onSecondaryContainer: Color(0xFFF1F1F1),
    error: Color(0xFFE07A7A),
    onPrimary: Color(0xFF0D0D0D),
  ).copyWith(surface: const Color(0xFF0D0D0D)),

  // Updated design system with Google Fonts
  textTheme: TextTheme(
    displayLarge: GoogleFonts.manrope(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.5),
    displayMedium: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
    displaySmall: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800),
    headlineLarge: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700),
    headlineMedium: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700),
    headlineSmall: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700),
    titleLarge: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700),
    titleMedium: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600),
    titleSmall: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
    bodyLarge: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w400),
    bodyMedium: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w400),
    bodySmall: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w400),
    labelLarge: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700),
    labelMedium: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700),
    labelSmall: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700),
  ),

  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: const Color(0xFF171717),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF262626),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF333333)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF333333)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFF1F1F1)),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF1F1F1),
      foregroundColor: const Color(0xFF0D0D0D),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFFF1F1F1),
      side: const BorderSide(color: Color(0xFF333333)),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFFF1F1F1),
      textStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700),
    ),
  ),
);


