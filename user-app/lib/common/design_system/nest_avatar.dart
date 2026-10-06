import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// nest. Design System Avatar
/// Circular avatar with inttials or image
class NestAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? inttials;
  final double size;
  final bool large;
  final bool small;

  const NestAvatar({
    super.key,
    this.imageUrl,
    this.inttials,
    this.size = 44,
    this.large = false,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarSize = large ? 86 : (small ? 36 : size);
    final double fontSize = large ? 20 : (small ? 12 : 12);
    final bgColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final textColor = isDark ? const Color(0xFF0D0D0D) : Colors.white;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: avatarSize / 2,
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      radius: avatarSize / 2,
      backgroundColor: bgColor,
      child: inttials != null
          ? Text(
              inttials!,
              style: GoogleFonts.manrope(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            )
          : null,
    );
  }
}


