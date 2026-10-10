import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class CategoryChangeRequestScreen extends StatefulWidget {
  const CategoryChangeRequestScreen({super.key});

  @override
  State<CategoryChangeRequestScreen> createState() =>
      _CategoryChangeRequestScreenState();
}

class _CategoryChangeRequestScreenState
    extends State<CategoryChangeRequestScreen> {
  final Set<String> _expanded = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CategoryAssignmentController>().loadData();
    });
  }

  String _subName(String id, List<AssignmentCategory> categories) {
    for (final AssignmentCategory category in categories) {
      for (final AssignmentSubCategory sub in category.subCategories) {
        if (sub.id == id) return sub.name ?? '';
      }
    }
    return id;
  }

  Future<void> _confirmCancel(CategoryAssignmentController controller) async {
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

    if (confirmed == true) {
      await controller.submitCancelRequest();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkColors.background,
      appBar: CustomAppBar(title: 'request_category_change'.tr),
      body: GetBuilder<CategoryAssignmentController>(
        builder: (controller) {
          if (controller.isLoading && controller.data == null) {
            return const Center(
              child: SizedBox(
                height: 32,
                width: 32,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final List<AssignmentCategory> categories = controller.categories;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.pendingRequest != null)
                  _pendingBanner(controller),

                Text(
                  'change_category_request_message'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    height: 1.4,
                    color: InkColors.mutedForeground,
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeDefault),

                _sectionTitle('current_assignment'.tr, '${controller.assignedCount}'),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.currentSubCategoryIds.isEmpty
                      ? [
                          Text(
                            'no_category_assigned'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: InkColors.mutedForeground,
                            ),
                          ),
                        ]
                      : controller.currentSubCategoryIds
                          .map(
                            (id) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
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

                const SizedBox(height: Dimensions.paddingSizeDefault),

                _sectionTitle(
                  'select_new_categories'.tr,
                  '${controller.selectedCount}',
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                if (categories.isEmpty)
                  InkEmptyState('no_sub_category_found'.tr)
                else
                  Column(
                    children: categories.map((category) {
                      final bool expanded = _expanded.contains(category.id);
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeExtraSmall,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: InkColors.card,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSmall,
                            ),
                            border: Border.all(color: InkColors.border),
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    final String id = category.id ?? '';
                                    if (expanded) {
                                      _expanded.remove(id);
                                    } else {
                                      _expanded.add(id);
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault,
                                    vertical: Dimensions.paddingSizeDefault,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          category.name ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: robotoSemiBold.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color: InkColors.foreground,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${category.subCategories.length} ${'sub_category'.tr}',
                                        style: robotoRegular.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall,
                                          color: InkColors.mutedForeground,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        expanded
                                            ? Icons.expand_less_rounded
                                            : Icons.expand_more_rounded,
                                        size: 20,
                                        color: InkColors.mutedForeground,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (expanded)
                                Column(
                                  children: category.subCategories.map((sub) {
                                    final String id = sub.id ?? '';
                                    final bool selected =
                                        controller.isSelected(id);
                                    return InkWell(
                                      onTap: id.isEmpty
                                          ? null
                                          : () => controller
                                              .toggleSubCategory(id),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          Dimensions.paddingSizeDefault,
                                          0,
                                          Dimensions.paddingSizeDefault,
                                          0,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              selected
                                                  ? Icons
                                                      .check_circle_rounded
                                                  : Icons
                                                      .radio_button_unchecked_rounded,
                                              size: 18,
                                              color: selected
                                                  ? InkColors.foreground
                                                  : InkColors.mutedForeground,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical:
                                                      Dimensions
                                                          .paddingSizeSmall,
                                                ),
                                                child: Text(
                                                  sub.name ?? '',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: InkColors.foreground,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (sub.isAssigned)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  left: 6,
                                                ),
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: InkColors.accent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    50,
                                                  ),
                                                ),
                                                child: Text(
                                                  'assigned_to_you'.tr,
                                                  style: robotoMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeExtraSmall,
                                                    color:
                                                        InkColors.foreground,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: Dimensions.paddingSizeDefault),

                Text(
                  'note_optional'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: InkColors.foreground,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                CustomTextFormField(
                  controller: controller.noteController,
                  hintText: 'note_hint'.tr,
                  capitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  inputType: TextInputType.multiline,
                  inputAction: TextInputAction.newline,
                ),

                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                CustomButton(
                  btnTxt: 'send_request'.tr,
                  isLoading: controller.isSubmitting,
                  onPressed: controller.isSubmitting
                      ? null
                      : () => controller.submitReplaceRequest(),
                ),

                if (controller.assignedCount > 0) ...[
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  CustomButton(
                    btnTxt: 'cancel_my_assignment'.tr,
                    transparent: true,
                    showBorder: true,
                    textColor: InkColors.destructive,
                    onPressed: controller.isSubmitting
                        ? null
                        : () => _confirmCancel(controller),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title, String count) {
    return Row(
      children: [
        Text(
          title,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: InkColors.foreground,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: InkColors.accent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            count,
            style: robotoBold.copyWith(
              fontSize: 11,
              color: InkColors.foreground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _pendingBanner(CategoryAssignmentController controller) {
    final PendingCategoryRequest request = controller.pendingRequest!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
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
              Text(
                'pending_category_request'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: InkColors.foreground,
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
          if (request.requestedSubCategoryIds.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: request.requestedSubCategoryIds
                  .map(
                    (id) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: InkColors.secondary,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        _subName(id, controller.categories),
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: InkColors.foreground,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
