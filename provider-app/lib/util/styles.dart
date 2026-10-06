import 'package:flutter/material.dart';

/// INK design system typography.
/// Body: Manrope · Display: Space Grotesk (matches design/src/styles.css).
const robotoLight = TextStyle(
  fontFamily: 'Manrope',
  fontWeight: FontWeight.w300,
);

const robotoRegular = TextStyle(
  fontFamily: 'Manrope',
  fontWeight: FontWeight.w400,
);

const robotoMedium = TextStyle(
  fontFamily: 'Manrope',
  fontWeight: FontWeight.w500,
);

const robotoSemiBold = TextStyle(
  fontFamily: 'Manrope',
  fontWeight: FontWeight.w600,
);

const robotoBold = TextStyle(
  fontFamily: 'Manrope',
  fontWeight: FontWeight.w700,
);

/// Display typography — headings, money, big numbers (font-display).
const displayRegular = TextStyle(
  fontFamily: 'SpaceGrotesk',
  fontWeight: FontWeight.w500,
  letterSpacing: -0.02,
);

const displayMedium = TextStyle(
  fontFamily: 'SpaceGrotesk',
  fontWeight: FontWeight.w600,
  letterSpacing: -0.02,
);

const displayBold = TextStyle(
  fontFamily: 'SpaceGrotesk',
  fontWeight: FontWeight.w700,
  letterSpacing: -0.02,
);

/// eyebrow — uppercase micro label (0.6875rem / 0.14em tracking / 700).
const eyebrowStyle = TextStyle(
  fontFamily: 'Manrope',
  fontSize: 11,
  height: 1.2,
  letterSpacing: 1.54,
  fontWeight: FontWeight.w700,
);
