import 'package:demandium_serviceman/utils/core_export.dart';

/// Shared gradient header used across the main screens (Home, Bookings,
/// History, Inbox) so every tab speaks the same visual language.
class GradientScreenHeader extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? bottom;
  final IconData? watermarkIcon;

  const GradientScreenHeader({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.actions = const <Widget>[],
    this.bottom,
    this.watermarkIcon,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    const Radius curve = Radius.circular(Ios27Tokens.radiusLg + 6);

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: curve),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: curve),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(primary, const Color(0xFF1E3A8A), 0.35)!,
                primary,
                Color.lerp(primary, const Color(0xFF3B82F6), 0.55)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                right: -70,
                top: -90,
                child: _bubble(210, 0.12),
              ),
              Positioned(
                right: 90,
                top: 70,
                child: _bubble(70, 0.07),
              ),
              Positioned(
                left: -50,
                bottom: -40,
                child: _ring(170, 0.10),
              ),
              if (watermarkIcon != null)
                Positioned(
                  right: -34,
                  bottom: -52,
                  child: Icon(
                    watermarkIcon,
                    size: 190,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Dimensions.paddingSizeDefault,
                    Dimensions.paddingSizeDefault,
                    Dimensions.paddingSizeDefault,
                    22,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (leading != null) ...[
                            leading!,
                            const SizedBox(width: Dimensions.paddingSizeDefault),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeExtraLarge + 4,
                                    color: Colors.white,
                                    letterSpacing: -0.6,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (subtitle != null && subtitle!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle!,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall + 1,
                                      color: Colors.white.withValues(alpha: 0.85),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (actions.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int i = 0; i < actions.length; i++) ...[
                                  if (i != 0)
                                    const SizedBox(width: Dimensions.paddingSizeSmall),
                                  actions[i],
                                ],
                              ],
                            ),
                        ],
                      ),
                      if (bottom != null) ...[
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        bottom!,
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bubble(double size, double opacity) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }

  Widget _ring(double size, double opacity) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: opacity), width: 2),
      ),
    );
  }
}

class HeaderCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool showBadge;
  final double size;

  const HeaderCircleButton({
    super.key,
    required this.icon,
    this.onTap,
    this.showBadge = false,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Ios27Tokens.radiusPill),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.28), width: 0.8),
            ),
            child: Icon(icon, color: Colors.white, size: size),
          ),
          if (showBadge)
            Positioned(
              right: 3,
              top: 3,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: Ios27Tokens.systemRed,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2563EB), width: 1.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Glass style mini stat used inside the gradient headers.
class HeaderStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const HeaderStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeExtraSmall,
        vertical: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeExtraLarge,
              color: Colors.white,
              height: 1.05,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Colors.white.withValues(alpha: 0.82),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
