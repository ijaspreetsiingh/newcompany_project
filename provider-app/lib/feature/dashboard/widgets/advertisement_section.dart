import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class AdvertisementSection extends StatefulWidget {
  const AdvertisementSection({super.key});

  @override
  State<AdvertisementSection> createState() => _AdvertisementSectionState();
}

class _AdvertisementSectionState extends State<AdvertisementSection> {
  bool _fetched = false;

  @override
  void initState() {
    super.initState();
    final AdvertisementController advertisementController =
        Get.find<AdvertisementController>();
    if (advertisementController.advertisementDataList != null) {
      _fetched = true;
      return;
    }
    advertisementController.getAdvertisementList('all', 1).then((_) {
      if (mounted) setState(() => _fetched = true);
    });
  }

  void _createAdvertisement() {
    Get.find<BusinessSubscriptionController>()
        .openTrialEndBottomSheet()
        .then((bool isTrial) {
          if (!isTrial) return;
          if (Get.find<UserProfileController>().checkAvailableFeatureInSubscriptionPlan(
            featureType: 'advertisement',
          )) {
            Get.find<AdvertisementController>().resetAllValues();
            Get.to(() => const CreateAdvertisementScreen(isEditScreen: false));
          }
        });
  }

  String _dateLabel(String? date) {
    final DateTime? parsed = DateTime.tryParse(date ?? '');
    if (parsed == null) return '';
    return DateConverter.dateStringMonthYear(parsed, format: 'd MMM');
  }

  @override
  Widget build(BuildContext context) {
    return InkSection(
      title: 'Advertisements'.tr,
      action: 'Create'.tr,
      onAction: _createAdvertisement,
      child: GetBuilder<AdvertisementController>(
        builder: (advertisementController) {
          final List<AdvertisementData>? ads =
              advertisementController.advertisementDataList;

          if (ads == null && !_fetched) return const _AdsShimmer();

          if (ads == null || ads.isEmpty) {
            return InkEmptyState('create_ads_to_reach_more_customers'.tr);
          }

          return SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ads.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(width: 12),
              itemBuilder: (BuildContext context, int index) {
                final AdvertisementData ad = ads[index];
                final String status = ad.status ?? '';
                final String startDate = _dateLabel(ad.startDate);
                final String endDate = _dateLabel(ad.endDate);
                final String dateRange = [
                  if (startDate.isNotEmpty) startDate,
                  if (endDate.isNotEmpty) endDate,
                ].join(' – ');

                return SizedBox(
                  height: 132,
                  width: 230,
                  child: InkCard(
                    onTap: () => Get.toNamed(
                      RouteHelper.getAdvertisementDetailsScreen(
                        advertisementId: ad.id,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (status.isNotEmpty)
                          InkEyebrow(
                            status,
                            color: InkColors.mutedForeground,
                          ),
                        const SizedBox(height: 8),
                        Text(
                          ad.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: robotoBold.copyWith(
                            fontSize: 14,
                            height: 1.35,
                            color: InkColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (dateRange.isNotEmpty)
                          Text(
                            dateRange,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(
                              fontSize: 11,
                              color: InkColors.mutedForeground,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AdsShimmer extends StatelessWidget {
  const _AdsShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 3),
      interval: const Duration(milliseconds: 1500),
      colorOpacity: 0,
      enabled: true,
      direction: const ShimmerDirection.fromLTRB(),
      child: SizedBox(
        height: 132,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(width: 12),
          itemBuilder: (BuildContext context, int index) => Container(
            height: 132,
            width: 230,
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              borderRadius: BorderRadius.circular(19),
            ),
          ),
        ),
      ),
    );
  }
}
