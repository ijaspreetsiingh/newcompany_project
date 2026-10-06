import 'dart:ui';

import 'package:demandium_provider/feature/tutorial/controller/tutorial_controller.dart';
import 'package:demandium_provider/helper/help_me.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:showcaseview/showcaseview.dart';

class AllServicesScreen extends StatefulWidget {
  final bool isTutorialActive;
  const AllServicesScreen({super.key, required this.isTutorialActive});

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  final GlobalKey subscribeKey = GlobalKey();
  final GlobalKey subCategorySectionKey = GlobalKey();
  bool _showcaseScrolled = false;

  @override
  void initState() {
    ServiceCategoryController controller = Get.find();

    controller.getCategoryList(shouldUpdate: false, reloadSubcategory: true);

    if (widget.isTutorialActive) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ShowcaseView.get().startShowCase([subscribeKey]),
      );
      Get.find<TutorialController>().updateTutorial(
        key: AppConstants.serviceSubscriptionTutorialKey,
      );
    }

    super.initState();
  }

  /// Known sub-category enrollments (real API data) used to derive
  /// per-category subscription state and counts.
  List<SubscriptionModelData> _knownSubscriptions() {
    final Map<String, SubscriptionModelData> subscriptions = {};
    for (final SubscriptionModelData subscription
        in Get.find<DashboardController>().dashboardSubscriptionList) {
      if (subscription.subCategoryId != null) {
        subscriptions[subscription.subCategoryId!] = subscription;
      }
    }
    for (final SubscriptionModelData subscription
        in Get.find<SubcategorySubscriptionController>().subscriptionList) {
      if (subscription.subCategoryId != null) {
        subscriptions[subscription.subCategoryId!] = subscription;
      }
    }
    return subscriptions.values
        .where((subscription) => subscription.isSubscribed == 1)
        .toList();
  }

  String? _subscribedCategorySubtitle(ServiceCategoryController controller) {
    final List<ServiceCategoryModel>? categories = controller.serviceCategoryList;
    if (categories == null || categories.isEmpty) return null;

    final Set<String> categoryIds = categories
        .map((category) => category.id)
        .whereType<String>()
        .toSet();

    final Set<String> subscribedCategoryIds = _knownSubscriptions()
        .map((subscription) => subscription.categoryId)
        .where((id) => id != null && categoryIds.contains(id))
        .cast<String>()
        .toSet();

    return '${'subscribed_categories_count'.trArgs(['${subscribedCategoryIds.length}', '${categories.length}'])}';
  }

  _CategoryFacts _factsFor({
    required ServiceCategoryModel category,
    required int index,
    required ServiceCategoryController controller,
    required List<SubscriptionModelData> knownSubscriptions,
  }) {
    final List<SubscriptionModelData> categorySubscriptions = knownSubscriptions
        .where((subscription) => subscription.categoryId == category.id)
        .toList();

    if (index == controller.selectedCategory) {
      final List<ServiceSubCategoryModel> loaded =
          controller.serviceSubCategoryList;
      int services = 0;
      for (final ServiceSubCategoryModel subCategory in loaded) {
        services +=
            subCategory.servicesCount ??
            subCategory.services
                    ?.where((service) => service.isActive == 1)
                    .length ??
                0;
      }
      return _CategoryFacts(
        subscribed:
            loaded.any((subCategory) => subCategory.isSubscribed == 1) ||
            categorySubscriptions.isNotEmpty,
        subCategoryCount: loaded.length,
        serviceCount: services,
      );
    }

    if (categorySubscriptions.isNotEmpty) {
      int services = 0;
      for (final SubscriptionModelData subscription in categorySubscriptions) {
        services += subscription.servicesCount ?? 0;
      }
      return _CategoryFacts(
        subscribed: true,
        subCategoryCount: categorySubscriptions.length,
        serviceCount: services,
      );
    }

    return const _CategoryFacts(subscribed: false);
  }

  void _scrollToShowcaseSection() {
    if (!widget.isTutorialActive || _showcaseScrolled) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showcaseScrolled) return;
      _showcaseScrolled = true;
      final BuildContext? sectionContext = subCategorySectionKey.currentContext;
      if (sectionContext != null) {
        Scrollable.ensureVisible(
          sectionContext,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Widget _loadErrorView(ServiceCategoryController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 64,
              width: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: InkColors.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 28,
                color: InkColors.foreground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'something_went_wrong'.tr,
              textAlign: TextAlign.center,
              style: robotoBold.copyWith(
                fontSize: 15,
                height: 1.3,
                color: InkColors.foreground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'connection_to_api_server_failed'.tr,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                fontSize: 12.5,
                height: 1.45,
                color: InkColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              onPressed: () =>
                  controller.getCategoryList(shouldUpdate: false, reloadSubcategory: true),
              btnTxt: 'retry'.tr,
              icon: Icons.refresh_rounded,
              width: 170,
              height: 42,
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _stickyHeader(String? subtitle) {
    final double topInset = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: InkColors.background.withValues(alpha: 0.90),
        border:  Border(bottom: BorderSide(color: InkColors.border)),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, topInset + 16, 16, 12),
            child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: 36,
              width: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: InkColors.card,
                shape: BoxShape.circle,
                border: Border.all(color: InkColors.border),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 20,
                color: InkColors.foreground,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'available_services'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: displayBold.copyWith(
                    fontSize: 22,
                    height: 1.15,
                    color: InkColors.foreground,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      fontSize: 12,
                      height: 1.3,
                      color: InkColors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkIconButton(
            icon: Icons.chat_bubble_outline_rounded,
            onTap: () {
              if (isRedundentClick(DateTime.now())) return;
              Get.toNamed(RouteHelper.getInboxScreenRoute());
            },
          ),
          const SizedBox(width: 8),
          GetBuilder<NotificationController>(
            builder: (notificationController) {
              return InkIconButton(
                icon: Icons.notifications_outlined,
                badge: notificationController.unseenNotificationCount > 0
                    ? notificationController.unseenNotificationCount.toString()
                    : null,
                onTap: () {
                  if (isRedundentClick(DateTime.now())) return;
                  Get.toNamed(RouteHelper.getNotificationRoute());
                  notificationController.resetNotificationCount();
                },
              );
            },
          ),
        ],
      ),
          ),
        ),
      ),
    );
  }

  Widget _subCategoryHeader(ServiceCategoryController controller) {
    final ServiceCategoryModel? selectedCategory =
        (controller.serviceCategoryList != null &&
                controller.selectedCategory <
                    controller.serviceCategoryList!.length)
            ? controller.serviceCategoryList![controller.selectedCategory]
            : null;
    final String selectedCategoryName = selectedCategory?.name ?? '';

    return Padding(
      key: subCategorySectionKey,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
        children: [
          InkEyebrow('sub_category'.tr),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: InkColors.accent,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              '${controller.serviceSubCategoryList.length}',
              style: robotoBold.copyWith(
                fontSize: 11,
                height: 1.2,
                color: InkColors.foreground,
              ),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              if (isRedundentClick(DateTime.now())) return;
              CategoryChangeBottomSheet.show();
            },
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: InkColors.foreground,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 14,
                    color: InkColors.background,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'request_change'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoSemiBold.copyWith(
                      fontSize: 12,
                      height: 1.2,
                      color: InkColors.background,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
          if (selectedCategoryName.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'showing_subcategories_of'.trArgs([selectedCategoryName]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoRegular.copyWith(
                fontSize: 11.5,
                height: 1.3,
                color: InkColors.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(ServiceCategoryController controller) {
    if (widget.isTutorialActive &&
        !_showcaseScrolled &&
        controller.serviceSubCategoryList.isNotEmpty) {
      _scrollToShowcaseSection();
    }

    final List<SubscriptionModelData> knownSubscriptions = _knownSubscriptions();

    return SingleChildScrollView(
      controller: controller.scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GetBuilder<DashboardController>(
            builder: (_) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 144,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: controller.serviceCategoryList?.length ?? 0,
                  itemBuilder: (context, index) {
                    final ServiceCategoryModel category =
                        controller.serviceCategoryList![index];
                    final _CategoryFacts facts = _factsFor(
                      category: category,
                      index: index,
                      controller: controller,
                      knownSubscriptions: knownSubscriptions,
                    );

                    return CategoryItem(
                      index: index,
                      title: category.name ?? '',
                      subtitle: category.description,
                      isSelected: index == controller.selectedCategory,
                      isSubscribed: facts.subscribed,
                      subCategoryCount: facts.subCategoryCount,
                      serviceCount: facts.serviceCount,
                      onTap: () {
                        controller.changeCategory(index);
                        controller.getSubCategoryList(
                          offset: 1,
                          isFromPagination: false,
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),

          _subCategoryHeader(controller),

          SubCategoryView(
            subCategoryList: controller.serviceSubCategoryList,
            subscribeKey: subscribeKey,
          ),

          if (controller.isPaginationLoading)
             Center(
              child: Padding(
                padding: EdgeInsets.only(top: 12),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: InkColors.foreground,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkColors.background,
      body: GetBuilder<ServiceCategoryController>(
        builder: (allServiceController) {
          return Column(
            children: [
              _stickyHeader(_subscribedCategorySubtitle(allServiceController)),

              Expanded(
                child: allServiceController.serviceCategoryList == null
                    ? (allServiceController.hasCategoryLoadFailed
                        ? _loadErrorView(allServiceController)
                        : const CategorySubcategoryShimmer())
                    : allServiceController.serviceCategoryList!.isEmpty
                    ? Center(
                        child: NoDataScreen(
                          showCaseKey: subscribeKey,
                          text: "no_available_service".tr,
                          type: NoDataType.service,
                        ),
                      )
                    : _buildContent(allServiceController),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryFacts {
  final bool subscribed;
  final int? subCategoryCount;
  final int? serviceCount;

  const _CategoryFacts({
    required this.subscribed,
    this.subCategoryCount,
    this.serviceCount,
  });
}
