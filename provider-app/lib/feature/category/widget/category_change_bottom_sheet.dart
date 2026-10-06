import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

/// Main category tap karne par yahi popup aata hai.
/// Sirf wahi categories / sub categories dikhti hain jo admin ne allow ki hain.
/// Provider naye select kar sakta hai ya purane hataane ki request bhej sakta hai.
class CategoryChangeBottomSheet extends StatefulWidget {
  const CategoryChangeBottomSheet({super.key});

  static Future<void> show() {
    return Get.bottomSheet(
      const CategoryChangeBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
    );
  }

  @override
  State<CategoryChangeBottomSheet> createState() =>
      _CategoryChangeBottomSheetState();
}

class _CategoryChangeBottomSheetState extends State<CategoryChangeBottomSheet> {
  final Set<String> _expanded = <String>{};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CategoryAssignmentController>().loadData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _confirmRemoveAll(CategoryAssignmentController controller) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: InkColors.card,
          title: Text(
            'cancel_my_assignment'.tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: InkColors.foreground,
            ),
          ),
          content: Text(
            'cancel_assignment_confirm'.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              height: 1.4,
              color: InkColors.mutedForeground,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'no'.tr,
                style: robotoMedium.copyWith(
                  color: InkColors.mutedForeground,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'yes'.tr,
                style: robotoMedium.copyWith(color: InkColors.destructive),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final bool ok = await controller.submitCancelRequest();
      if (ok && mounted) Get.back();
    }
  }

  Future<void> _send(CategoryAssignmentController controller) async {
    if (controller.selectedIds.isEmpty && controller.assignedCount > 0) {
      await _confirmRemoveAll(controller);
      return;
    }
    final bool ok = await controller.submitReplaceRequest();
    if (ok && mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.of(context).size.height * 0.86;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: InkColors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Dimensions.radiusLarge),
        ),
      ),
      child: GetBuilder<CategoryAssignmentController>(
        builder: (controller) {
          if (controller.isLoading && controller.data == null) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final List<AssignmentCategory> categories = controller.categories;
          final bool hasPending = controller.pendingRequest != null;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: InkColors.border,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'request_category_change'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault + 1,
                          color: InkColors.foreground,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: InkColors.accent,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        '${controller.selectedCount}',
                        style: robotoBold.copyWith(
                          fontSize: 11,
                          color: InkColors.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: InkColors.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: InkColors.border),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: InkColors.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Flexible(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasPending) _pendingBanner(controller),

                      if (controller.currentSubCategoryIds.isNotEmpty) ...[
                        Text(
                          'current_assignment'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: InkColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: controller.currentSubCategoryIds
                              .map(
                                (id) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: InkColors.secondary,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(color: InkColors.border),
                                  ),
                                  child: Text(
                                    _subName(id, categories),
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: InkColors.foreground,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 14),
                      ],

                      Text(
                        'select_new_categories'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: InkColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (categories.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'no_sub_category_found'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: InkColors.mutedForeground,
                              ),
                            ),
                          ),
                        )
                      else
                        ...categories.map(
                          (category) => _categoryTile(category, controller),
                        ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeSmall,
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeDefault,
                ),
                decoration: BoxDecoration(
                  color: InkColors.card,
                  border: Border(top: BorderSide(color: InkColors.border)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomButton(
                        btnTxt: 'send_request'.tr,
                        isLoading: controller.isSubmitting,
                        onPressed: controller.isSubmitting ||
                                hasPending
                            ? null
                            : () => _send(controller),
                      ),
                      if (controller.assignedCount > 0) ...[
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: controller.isSubmitting || hasPending
                              ? null
                              : () => _confirmRemoveAll(controller),
                          child: Text(
                            'cancel_my_assignment'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: InkColors.destructive,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _categoryTile(
    AssignmentCategory category,
    CategoryAssignmentController controller,
  ) {
    final String categoryId = category.id ?? '';
    final bool expanded = _expanded.contains(categoryId);
    final int subCount = category.subCategories.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: InkColors.card,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(color: InkColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: expanded,
          onExpansionChanged: (value) {
            setState(() {
              if (value) {
                _expanded.add(categoryId);
              } else {
                _expanded.remove(categoryId);
              }
            });
          },
          tilePadding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            Dimensions.paddingSizeDefault,
            0,
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeSmall,
          ),
          iconColor: InkColors.mutedForeground,
          collapsedIconColor: InkColors.mutedForeground,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  category.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: robotoSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall + 1,
                    color: InkColors.foreground,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: InkColors.accent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '$subCount',
                  style: robotoBold.copyWith(
                    fontSize: 10,
                    color: InkColors.foreground,
                  ),
                ),
              ),
            ],
          ),
          children: subCount == 0
              ? [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'no_sub_category_found'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: InkColors.mutedForeground,
                      ),
                    ),
                  ),
                ]
              : category.subCategories
                  .map((sub) => _subRow(sub, controller))
                  .toList(),
        ),
      ),
    );
  }

  Widget _subRow(
    AssignmentSubCategory sub,
    CategoryAssignmentController controller,
  ) {
    final String id = sub.id ?? '';
    final bool selected = controller.isSelected(id);
    final bool assigned = sub.isAssigned;

    return InkWell(
      onTap: id.isEmpty ? null : () => controller.toggleSubCategory(id),
      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 19,
              color: selected
                  ? InkColors.foreground
                  : InkColors.mutedForeground,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                sub.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  height: 1.3,
                  color: InkColors.foreground,
                ),
              ),
            ),
            if (assigned)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: InkColors.accent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  'assigned_to_you'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: InkColors.foreground,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _pendingBanner(CategoryAssignmentController controller) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: InkColors.card,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(color: InkColors.destructive.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.hourglass_top_rounded,
                size: 16,
                color: InkColors.destructive,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'pending_category_request'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: InkColors.foreground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'change_category_request_pending_message'.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              height: 1.4,
              color: InkColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  String _subName(String id, List<AssignmentCategory> categories) {
    for (final AssignmentCategory category in categories) {
      for (final AssignmentSubCategory sub in category.subCategories) {
        if (sub.id == id) return sub.name ?? '';
      }
    }
    return id;
  }
}
