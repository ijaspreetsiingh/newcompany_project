import 'package:jdds/theme/custom_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Black & white "nest." design system - updated from designnew
/// background #FFFFFF Â· foreground #141414 Â· primary #141414 Â· secondary #F6F6F6
/// border radius: 16px Â· font: DM Sans
ThemeData light = ThemeData(
  useMaterial3: false,
  primaryColor: const Color(0xFF141414),
  primaryColorLight: const Color(0xFFF6F6F6),
  primaryColorDark: const Color(0xFF000000),
  secondaryHeaderColor: const Color(0xFF7D7D7D),
  disabledColor: const Color(0xFFB8B8B8),
  scaffoldBackgroundColor: const Color(0xFFFFFFFF),
  brightness: Brightness.light,
  hintColor: const Color(0xFF7D7D7D),
  focusColor: const Color(0xFFF6F6F6),
  hoverColor: const Color(0xFFF6F6F6),
  shadowColor: const Color(0xFFE8E8E8),
  cardColor: Colors.white,
  extensions: <ThemeExtension<CustomThemeColors>>[
    CustomThemeColors.light(),
  ],

  colorScheme: const ColorScheme.light(
    primary: Color(0xFF141414),
    secondary: Color(0xFF7D7D7D),
    onSecondary: Color(0xFFFFFFFF),
    tertiary: Color(0xFF333333),
    onSecondaryContainer: Color(0xFF141414),
    error: Color(0xFFD64545),
    onPrimary: Color(0xFFFFFFFF),
  ).copyWith(surface: const Color(0xFFFFFFFF)),

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
    color: Colors.white,
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF6F6F6),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF141414)),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF141414),
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF141414),
      side: const BorderSide(color: Color(0xFFE5E5E5)),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF141414),
      textStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700),
    ),
  ),
);


