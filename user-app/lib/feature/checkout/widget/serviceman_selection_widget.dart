import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';

class ServicemanSelectionWidget extends StatelessWidget {
  const ServicemanSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final hintColor = theme.hintColor;
    final cardColor = theme.cardColor;
    final isDark = theme.brightness == Brightness.dark;

    return GetBuilder<CheckOutController>(builder: (checkoutController) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Select Serviceman',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Toggle Options Container
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
                ),
              ),
              child: Column(
                children: [
                  // Option 1: Auto Select
                  _buildOption(
                    context: context,
                    title: 'Auto-select Nearest',
                    subtitle: 'System will assign nearest available serviceman',
                    isSelected: checkoutController.servicemanSelectionMode == 'auto',
                    onTap: () {
                      checkoutController.setServicemanSelectionMode('auto', shouldUpdate: true);
                    },
                    icon: Icons.auto_awesome,
                  ),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
                    ),
                  ),

                  // Option 2: Manual Select
                  _buildOption(
                    context: context,
                    title: 'Choose Specific Serviceman',
                    subtitle: 'Pick from available servicemen in your area',
                    isSelected: checkoutController.servicemanSelectionMode == 'manual',
                    onTap: () async {
                      checkoutController.setServicemanSelectionMode('manual', shouldUpdate: true);
                      // Open popup directly when manual mode is selected
                      await Future.delayed(const Duration(milliseconds: 100));
                      checkoutController.openServicemanSelectionSheet();
                    },
                    icon: Icons.person_search,
                  ),
                ],
              ),
            ),

            // Show selected serviceman info if manual mode and one is selected
            if (checkoutController.servicemanSelectionMode == 'manual' &&
                checkoutController.selectedServiceman != null)
              Padding(
                padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: isDark ? 0.1 : 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            checkoutController.selectedServiceman!['profile_image'] ?? '',
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF262626) : const Color(0xFFF6F6F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.person, size: 28, color: hintColor),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              checkoutController.selectedServiceman!['name'] ?? 'Unknown',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFB800).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 12,
                                        color: Color(0xFFFFB800),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        checkoutController.selectedServiceman!['rating']?.toString() ?? '0.0',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: const Color(0xFFFFB800),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${checkoutController.selectedServiceman!['total_reviews']} reviews',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      InkWell(
                        onTap: () {
                          checkoutController.openServicemanSelectionSheet();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],
        ),
      );
    });
  }

  Widget _buildOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final hintColor = theme.hintColor;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      splashColor: primaryColor.withValues(alpha: 0.1),
      highlightColor: primaryColor.withValues(alpha: 0.05),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.15 : 0.08)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Custom Radio
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : hintColor.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                    )
                  : const SizedBox(),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            // Option Icon
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isSelected ? primaryColor : null,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
