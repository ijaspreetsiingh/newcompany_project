import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// nest. Design System Chip
/// Pill-shaped chip for filters and categories
class NestChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leading;

  const NestChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = selected
        ? (isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414))
        : Colors.transparent;
    final textColor = selected
        ? (isDark ? const Color(0xFF0D0D0D) : Colors.white)
        : (isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414));
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 6)],
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



