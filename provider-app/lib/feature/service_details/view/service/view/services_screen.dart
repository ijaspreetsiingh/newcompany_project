import 'package:demandium_provider/feature/service_details/model/service_faq_model.dart';
import 'package:demandium_provider/feature/service_details/widget/empty_faq_widget.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class ServicesScreen extends StatefulWidget {
  final int index;
  final ServiceSubCategoryModel? subcategoryModel;
  final SubscriptionModelData? subscriptionModelData;
  final String fromPage;

  const ServicesScreen({
    super.key,
    this.subcategoryModel,
    this.subscriptionModelData,
    required this.index,
    required this.fromPage,
  });

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<ServiceFAQData>? _faqList;

  @override
  void initState() {
    super.initState();
    ServiceCategoryController serviceCategoryController = Get.find();
    serviceCategoryController.getServiceListBasedOnSubcategory(
      subCategoryId:
          widget.subcategoryModel?.id ??
          widget.subscriptionModelData?.subCategoryId ??
          "",
    );
    serviceCategoryController.clearSearchController(shouldUpdate: false);

    _loadFaq();
  }

  /// FAQ is served by the existing per-service questions API — load it for the
  /// first service of this sub-category so the FAQ block only shows real data.
  void _loadFaq() {
    final ServiceSubCategoryModel? subCategory =
        widget.subcategoryModel ?? widget.subscriptionModelData?.subCategory;
    final String? serviceId =
        (subCategory?.services != null && subCategory!.services!.isNotEmpty)
        ? subCategory.services!.first.id
        : null;

    if (serviceId == null) return;

    final ServiceDetailsController detailsController = Get.find<
      ServiceDetailsController
    >();
    final ServiceFaqModel? before = detailsController.serviceFaqModel;

    detailsController.getServiceFAQData(serviceId).then((_) {
      if (!mounted) return;
      final ServiceFaqModel? after = detailsController.serviceFaqModel;
      if (!identical(before, after)) {
        setState(() {
          _faqList = after?.content?.data;
        });
      }
    });
  }

  bool get _isSubscribed =>
      widget.subcategoryModel?.isSubscribed == 1 ||
      widget.subscriptionModelData?.isSubscribed == 1;

  String get _title =>
      widget.subcategoryModel?.name ??
      widget.subscriptionModelData?.subCategory?.name ??
      "";

  String get _subCategoryId =>
      widget.subcategoryModel?.id ??
      widget.subscriptionModelData?.subCategoryId ??
      "";

  void _handleAvailabilityToggle() {
    Get.find<BusinessSubscriptionController>()
        .openTrialEndBottomSheet()
        .then((isTrial) {
          if (isTrial) {
            showCustomBottomSheet(
              child: SubscribeUnsubscribeBottomSheet(
                isSubscribe: !_isSubscribed,
                subCategoryModel: widget.subcategoryModel,
                subscriptionModelData: widget.subscriptionModelData,
                index: widget.index,
                fromPage: widget.fromPage,
              ),
            );
          }
        });
  }

  Widget _faqSliver() {
    if (_faqList == null || _faqList!.isEmpty) {
      return const EmptyFAQWidget();
    }

    return SliverToBoxAdapter(
      child: InkCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int index = 0; index < _faqList!.length; index++) ...[
              if (index > 0)
                 Divider(height: 1, thickness: 1, color: InkColors.border),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _faqList![index].question ?? "",
                      style: robotoSemiBold.copyWith(
                        fontSize: 13,
                        height: 1.35,
                        color: InkColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _faqList![index].answer ?? "",
                      style: robotoRegular.copyWith(
                        fontSize: 12,
                        height: 1.45,
                        color: InkColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceCategoryController>(
      builder: (allServiceController) {
        final bool isSearching =
            allServiceController.searchServiceList == null &&
            !allServiceController.isSearchComplete;
        final List<ServiceModel> displayList =
            (allServiceController.searchServiceList != null &&
                allServiceController.isSearchComplete)
            ? allServiceController.searchServiceList!
            : allServiceController.serviceList ?? <ServiceModel>[];

        return Scaffold(
          backgroundColor: InkColors.background,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkTopBar(
                title: _title,
                subtitle: allServiceController.serviceList == null
                    ? null
                    : '${allServiceController.serviceList!.length} ${'services'.tr}',
                onBack: () => Get.back(),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: ServiceSearchWidget(subcategoryId: _subCategoryId),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkSection(title: 'Services'.tr, child: SizedBox.shrink()),

                    Expanded(
                      child: isSearching
                          ? const SearchedServiceListShimmer()
                          : allServiceController.serviceList == null
                          ? const ServiceListShimmer()
                          : CustomScrollView(
                              physics: const BouncingScrollPhysics(),
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  sliver: SliverToBoxAdapter(
                                    child: ServiceListView(
                                      serviceList: displayList,
                                      isSubscribed: _isSubscribed,
                                      onToggleAvailability:
                                          _handleAvailabilityToggle,
                                    ),
                                  ),
                                ),

                                SliverToBoxAdapter(
                                  child: InkSection(
                                    title: 'FAQ'.tr,
                                    child: SizedBox.shrink(),
                                  ),
                                ),

                                _faqSliver(),

                                const SliverToBoxAdapter(
                                  child: SizedBox(height: 32),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
