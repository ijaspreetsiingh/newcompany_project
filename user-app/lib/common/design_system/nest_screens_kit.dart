import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdds/helper/route_helper.dart';

/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
/// nest. screen kit â€” exact port of designnew/src/styles.css tokens
/// Har menu / sub-page isi kit se banta hai (same-to-same design).
/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class NestInk {
  NestInk._();

  /// --foreground  : ink black (light) / near-white (dark)
  static Color get primary =>
      Get.isDarkMode ? const Color(0xFFF1F1F1) : const Color(0xFF141414);

  /// --background  : white (light) / near-black (dark)
  static Color get background =>
      Get.isDarkMode ? const Color(0xFF0D0D0D) : Colors.white;

  /// --card
  static Color get card =>
      Get.isDarkMode ? const Color(0xFF171717) : Colors.white;

  /// --muted-foreground
  static Color get mutedText =>
      Get.isDarkMode ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);

  /// --border
  static Color get border =>
      Get.isDarkMode ? const Color(0xFF333333) : const Color(0xFFE5E5E5);

  /// --muted (soft grey wells)
  static Color get soft =>
      Get.isDarkMode ? const Color(0xFF262626) : const Color(0xFFF6F6F6);

  /// --muted page tint (chat / skeleton bg)
  static Color get softPage =>
      Get.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF3F3F3);

  /// --destructive
  static Color get danger =>
      Get.isDarkMode ? const Color(0xFFF87171) : const Color(0xFFDC2626);

  /// display typeface (Manrope)
  static TextStyle display({
    double size = 13,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: weight,
        color: color ?? primary,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// body typeface (DM Sans)
  static TextStyle body({
    double size = 11,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: weight,
        color: color ?? primary,
        height: height,
        letterSpacing: letterSpacing,
      );
}

/// circular grey icon well â€” `.menu-icon` (38px, muted bg)
class NestIconWell extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final double size;
  final Color? background;
  final Color? foreground;
  final double radius;

  const NestIconWell({
    super.key,
    this.icon,
    this.child,
    this.size = 38,
    this.background,
    this.foreground,
    this.radius = 999,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: background ?? NestInk.soft,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: child ??
          Icon(
            icon,
            size: size * 0.47,
            color: foreground ?? NestInk.primary,
          ),
    );
  }
}

/// circular bordered icon button â€” `.icon-btn` (42px)
class NestRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;
  final double size;
  final double iconSize;
  final Widget? child;

  const NestRoundButton({
    super.key,
    required this.icon,
    this.onTap,
    this.filled = false,
    this.size = 42,
    this.iconSize = 19,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? NestInk.primary : NestInk.background,
        border: Border.all(color: filled ? NestInk.primary : NestInk.border),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: child ??
              Icon(
                icon,
                size: iconSize,
                color: filled ? NestInk.background : NestInk.primary,
              ),
        ),
      ),
    );
  }
}

/// page header â€” `.page-header` : 42 back Â· centered title Â· 42 action
class NestHeaderBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? action;
  final bool showBack;

  const NestHeaderBar({
    super.key,
    required this.title,
    this.onBack,
    this.action,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 22),
      child: Row(
        children: [
          showBack
              ? NestRoundButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  iconSize: 17,
                  onTap: onBack ??
                      () {
                        if (Navigator.canPop(context)) {
                          Get.back();
                        } else {
                          Get.offAllNamed(RouteHelper.getinitialRoute());
                        }
                      },
                )
              : const SizedBox(width: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NestInk.display(size: 18, weight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 42,
            height: 42,
            child: Align(
              alignment: Alignment.centerRight,
              child: action ?? const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// big page title â€” `.simple-title` (h1 31px)
class NestBigTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const NestBigTitle({super.key, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: NestInk.display(
                  size: 31,
                  weight: FontWeight.w800,
                  height: 1.08,
                  letterSpacing: -0.4,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: NestInk.body(size: 11, color: NestInk.mutedText)),
              ],
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

/// section title â€” `.section-title` (h2 19px + optional "See all â€º")
class NestSectionRow extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry margin;

  const NestSectionRow({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.margin = const EdgeInsets.only(top: 30, bottom: 14),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: NestInk.display(size: 19, weight: FontWeight.w700),
            ),
          ),
          if (action != null)
            InkWell(
              onTap: onAction,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    action!,
                    style: NestInk.body(size: 12, color: NestInk.mutedText),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: NestInk.mutedText,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// grouped menu card â€” `.menu-card` (bordered, divided rows)
class NestMenuCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  const NestMenuCard({super.key, required this.children, this.margin});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: NestInk.card,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: NestInk.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Container(height: 1, width: double.infinity, color: NestInk.border),
          ],
        ],
      ),
    );
  }
}

/// menu row â€” `.menu-card button` (icon well Â· label Â· badge Â· chevron)
class NestMenuRow extends StatelessWidget {
  final IconData? icon;
  final Widget? leading;
  final String title;
  final String? badge;
  final VoidCallback? onTap;
  final bool showChevron;
  final Color? titleColor;
  final Widget? trailing;
  final double minHeight;

  const NestMenuRow({
    super.key,
    this.icon,
    this.leading,
    required this.title,
    this.badge,
    this.onTap,
    this.showChevron = true,
    this.titleColor,
    this.trailing,
    this.minHeight = 57,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        child: Row(
          children: [
            leading ?? NestIconWell(icon: icon, size: 38),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: NestInk.display(
                  size: 12,
                  weight: FontWeight.w700,
                  color: titleColor ?? NestInk.primary,
                ),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                height: 19,
                width: 19,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: NestInk.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge!,
                  style: NestInk.display(
                    size: 8,
                    weight: FontWeight.w800,
                    color: NestInk.background,
                  ),
                ),
              ),
            ],
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
            if (showChevron) ...[
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right_rounded,
                size: 17,
                color: NestInk.mutedText,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// pill switch â€” `.switch` / `.switch.on` (42 Ã— 24)
class NestPillSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const NestPillSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 24,
        width: 42,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: value ? NestInk.primary : NestInk.border,
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            height: 18,
            width: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? NestInk.background : NestInk.card,
            ),
          ),
        ),
      ),
    );
  }
}

/// toggle row â€” `.toggle-row`
class NestToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const NestToggleRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 69),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      child: Row(
        children: [
          NestIconWell(icon: icon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: NestInk.display(size: 12, weight: FontWeight.w700)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style:
                          NestInk.body(size: 9, color: NestInk.mutedText)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          NestPillSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// form field â€” `.form-field` (label 10 + input radius 13 / min 52)
class NestField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hint;
  final TextInputType keyboardType;
  final bool readOnly;
  final int maxLines;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const NestField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.maxLines = 1,
    this.suffix,
    this.onChanged,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: NestInk.body(
                  size: 10,
                  weight: FontWeight.w700,
                  color: NestInk.primary)),
          const SizedBox(height: 7),
          TextFormField(
            controller: controller,
            initialValue: controller == null ? initialValue : null,
            keyboardType: keyboardType,
            readOnly: readOnly,
            maxLines: maxLines,
            onChanged: onChanged,
            validator: validator,
            textInputAction: textInputAction,
            onFieldSubmitted: onSubmitted,
            style: NestInk.body(size: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: NestInk.body(size: 13, color: NestInk.mutedText),
              suffixIcon: suffix,
              suffixIconConstraints:
                  const BoxConstraints(minHeight: 20, minWidth: 20),
              filled: true,
              fillColor: NestInk.background,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: maxLines > 1 ? 14 : 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: NestInk.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: NestInk.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: NestInk.primary, width: 1.2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: NestInk.danger),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: NestInk.danger),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// pill button â€” `.button` variants (h 52 Â· radius 999)
class NestPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final NestPillVariant variant;
  final Widget? leading;
  final Widget? trailing;
  final double height;
  final bool expand;

  const NestPillButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = NestPillVariant.primary,
    this.leading,
    this.trailing,
    this.height = 52,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = variant == NestPillVariant.primary;
    final bool isDanger = variant == NestPillVariant.danger;

    final Color bg = isPrimary
        ? NestInk.primary
        : isDanger
            ? NestInk.danger.withValues(alpha: 0.10)
            : Colors.transparent;
    final Color fg = isPrimary
        ? NestInk.background
        : isDanger
            ? NestInk.danger
            : variant == NestPillVariant.ghost
                ? NestInk.mutedText
                : NestInk.primary;

    return SizedBox(
      width: expand ? double.infinity : null,
      height: height,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: height,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 19),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: variant == NestPillVariant.outline
                  ? Border.all(color: NestInk.border)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NestInk.display(size: 13, weight: FontWeight.w700, color: fg),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum NestPillVariant { primary, outline, ghost, danger }

/// underline tab row â€” `.tab-row`
class NestTabs extends StatelessWidget {
  final List<String> items;
  final int active;
  final ValueChanged<int> onChanged;

  const NestTabs({
    super.key,
    required this.items,
    required this.active,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: NestInk.border))),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: i == active ? NestInk.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    items[i],
                    style: NestInk.display(
                      size: 11,
                      weight: FontWeight.w700,
                      color: i == active ? NestInk.primary : NestInk.mutedText,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// grey lead paragraph â€” `.page-lead`
class NestLead extends StatelessWidget {
  final String text;
  const NestLead({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: NestInk.body(size: 11, color: NestInk.mutedText));
  }
}

/// centered footer â€” `.screen footer`
class NestPageFooter extends StatelessWidget {
  final String text;
  const NestPageFooter({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Center(
        child: Text(text, style: NestInk.body(size: 10, color: NestInk.mutedText)),
      ),
    );
  }
}

/// bordered action button (full width, radius 15) â€” `.logout` / `.delete-account`
class NestOutlineAction extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool danger;
  final double radius;
  final double height;

  const NestOutlineAction({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.danger = false,
    this.radius = 15,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = danger ? NestInk.danger : NestInk.primary;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: danger ? NestInk.danger.withValues(alpha: 0.28) : NestInk.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: fg),
                  const SizedBox(width: 8),
                ],
                Text(label, style: NestInk.display(size: 12, weight: FontWeight.w700, color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// plain screen body with `.screen` padding (22 / 20 / 112)
class NestScreenBody extends StatelessWidget {
  final Widget child;
  final bool scroll;
  final Color? background;
  final ScrollController? controller;

  const NestScreenBody({
    super.key,
    required this.child,
    this.scroll = true,
    this.background,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final Widget padded = Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
      child: child,
    );
    return Container(
      color: background ?? NestInk.background,
      width: double.infinity,
      child: scroll
          ? SingleChildScrollView(
              controller: controller,
              padding: EdgeInsets.zero,
              child: padded,
            )
          : padded,
    );
  }
}



