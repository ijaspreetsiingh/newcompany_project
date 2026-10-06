import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class ServiceListView extends StatelessWidget {
  final List<ServiceModel> serviceList;
  final bool isSubscribed;
  final VoidCallback? onToggleAvailability;

  const ServiceListView({
    super.key,
    required this.serviceList,
    this.isSubscribed = false,
    this.onToggleAvailability,
  });

  num? _lowestPrice(ServiceModel service) {
    if (service.variations != null && service.variations!.isNotEmpty) {
      num? lowest;
      for (final variation in service.variations!) {
        if (variation.price != null &&
            (lowest == null || variation.price! < lowest)) {
          lowest = variation.price;
        }
      }
      if (lowest != null) return lowest;
    }

    if (service.variationsReactFormat != null &&
        service.variationsReactFormat!.isNotEmpty) {
      for (final variation in service.variationsReactFormat!) {
        if (variation.variationPrice != null) return variation.variationPrice;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (serviceList.isEmpty) {
      return InkEmptyState('no_service_available'.tr);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final ServiceModel service in serviceList)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _serviceCard(service),
          ),
      ],
    );
  }

  Widget _serviceCard(ServiceModel service) {
    final num? price = _lowestPrice(service);
    final bool hasRating =
        (service.avgRating ?? 0) > 0 && (service.ratingCount ?? 0) > 0;
    final String name = (service.name ?? '').trim();
    final String monogram = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return InkCard(
      padding: const EdgeInsets.all(16),
      onTap: service.id == null
          ? null
          : () => Get.to(
              ServiceDetailsScreen(
                serviceId: service.id!,
                discount: PriceConverter.discountCalculation(service),
              ),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 54,
            width: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: InkColors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              monogram,
              style: displayBold.copyWith(
                fontSize: 18,
                color: InkColors.foreground,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: robotoBold.copyWith(
                    fontSize: 14,
                    height: 1.3,
                    color: InkColors.foreground,
                  ),
                ),
                if (hasRating) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                       Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: InkColors.foreground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        service.avgRating!.toStringAsFixed(1),
                        style: robotoSemiBold.copyWith(
                          fontSize: 11.5,
                          height: 1.3,
                          color: InkColors.foreground,
                        ),
                      ),
                      Text(
                        ' (${service.ratingCount})',
                        style: robotoRegular.copyWith(
                          fontSize: 11.5,
                          height: 1.3,
                          color: InkColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ],
                if (price != null) ...[
                  const SizedBox(height: 6),
                  InkMoney(
                    price,
                    style: robotoBold.copyWith(
                      fontSize: 15,
                      height: 1.2,
                      color: InkColors.foreground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _AvailabilitySwitch(
            value: isSubscribed,
            onTap: onToggleAvailability,
          ),
        ],
      ),
    );
  }
}

/// Custom ink pill switch — availability / membership toggle.
class _AvailabilitySwitch extends StatelessWidget {
  final bool value;
  final VoidCallback? onTap;

  const _AvailabilitySwitch({required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 24,
        width: 44,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? InkColors.foreground : InkColors.border,
          borderRadius: BorderRadius.circular(50),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            height: 20,
            width: 20,
            decoration:  BoxDecoration(
              color: InkColors.card,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
