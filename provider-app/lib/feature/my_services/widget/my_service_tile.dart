import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class MyServiceTile extends StatelessWidget {
  final MyServiceItem service;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MyServiceTile({
    super.key,
    required this.service,
    this.canManage = true,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: robotoBold.copyWith(
          fontSize: 10,
          height: 1.4,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color pendingColor = const Color(0xFFE1972B);
    final Color editedColor = const Color(0xFF279D6B);

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: InkColors.card,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: InkColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ServiceCover(image: service.coverImage),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: robotoSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        height: 1.3,
                        color: InkColors.foreground,
                      ),
                    ),
                    if (service.shortDescription != null &&
                        service.shortDescription!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        service.shortDescription!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(
                          fontSize: 11.5,
                          height: 1.35,
                          color: InkColors.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              if (!canManage)
                Container(
                  height: 30,
                  width: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: InkColors.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: InkColors.border),
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 14,
                    color: InkColors.mutedForeground,
                  ),
                )
              else
                Column(
                  children: [
                    InkWell(
                      onTap: onEdit,
                      child: Container(
                        height: 30,
                        width: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: InkColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: InkColors.border),
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 15,
                          color: InkColors.foreground,
                        ),
                      ),
                    ),
                    if (service.isOwned) ...[
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: onDelete,
                        child: Container(
                          height: 30,
                          width: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: InkColors.card,
                            shape: BoxShape.circle,
                            border: Border.all(color: InkColors.border),
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 15,
                            color: InkColors.destructive,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(
            children: [
              Expanded(
                child: Text(
                  service.variants.isEmpty
                      ? '-'
                      : 'from ${service.priceFrom.toStringAsFixed(0)}',
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    height: 1.2,
                    color: InkColors.foreground,
                  ),
                ),
              ),
              if (service.isPending) ...[
                _badge('pending_approval'.tr, pendingColor),
                const SizedBox(width: 6),
              ],
              if (service.isEdited) _badge('edited'.tr, editedColor),
            ],
          ),
          if (service.isEdited && service.baseVariants != null) ...[
            const SizedBox(height: 4),
            Text(
              'original ${service.baseVariants!.isEmpty ? '-' : service.baseVariants!.first.price.toStringAsFixed(0)}',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                height: 1.3,
                color: InkColors.mutedForeground,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
