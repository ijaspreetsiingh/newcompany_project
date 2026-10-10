import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class BusinessSummarySection extends StatelessWidget {
  const BusinessSummarySection({super.key});

  void _openReports(int tabIndex) {
    Get.find<BusinessReportController>().businessReportTabController?.index =
        tabIndex;
    Get.to(() => const BusinessReport());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        final providerInfo =
            userProfileController.providerModel?.content?.providerInfo;
        final double rating = providerInfo?.avgRating ?? 0;
        final int reviews = providerInfo?.ratingCount ?? 0;
        final String dateLabel = DateConverter.dateStringMonthYear(
          DateTime.now(),
          format: 'd MMM',
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkSurface(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Container(
                      height: 144,
                      width: 144,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: <Color>[
                            Colors.white.withValues(alpha: 0.14),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkEyebrow(
                          'Overview · $dateLabel',
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'dashboard'.tr,
                          style: displayBold.copyWith(
                            fontSize: 26,
                            height: 1.1,
                            color: Colors.white,
                          ),
                        ),
                        if (providerInfo != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Rating ${rating.toStringAsFixed(1)} · $reviews reviews',
                            style: robotoRegular.copyWith(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Earnings this week',
                                    style: robotoRegular.copyWith(
                                      fontSize: 11,
                                      color: Colors.white.withValues(
                                        alpha: 0.60,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  GetBuilder<DashboardController>(
                                    builder: (dashboardController) => InkMoney(
                                      dashboardController
                                              .earningDataModel
                                              ?.thisWeek
                                              ?.total ??
                                          0,
                                      style: const TextStyle(
                                        fontSize: 30,
                                        height: 1.1,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => _openReports(0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.auto_awesome_outlined,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Insights',
                                      style: robotoSemiBold.copyWith(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
