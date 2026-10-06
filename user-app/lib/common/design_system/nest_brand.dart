import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Home brand mark and initials.
class NestBrand extends StatelessWidget {
  final double? fontSize;

  const NestBrand({super.key, this.fontSize});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final textColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              'JS',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? const Color(0xFF0D0D0D) : Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          'Jass',
          style: GoogleFonts.manrope(
            fontSize: fontSize ?? 22,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

