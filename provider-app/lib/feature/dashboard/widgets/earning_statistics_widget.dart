import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EarningStatisticsWidget extends StatelessWidget {
  const EarningStatisticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        final earningData = dashboardController.earningDataModel;

        return Skeletonizer(
          enabled: earningData == null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(
                  Dimensions.radiusExtraLarge,
                ),
                boxShadow: context.customThemeColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeDefault,
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 22,
                          width: 5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Color.lerp(
                                  Theme.of(context).primaryColor,
                                  const Color(0xFF1E40AF),
                                  0.5,
                                )!,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Text(
                          'earning_statistics'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge!.color!
                                .withValues(alpha: 0.9),
                          ),
                        ),
                        const Spacer(),

                        InkWell(
                          onTap: () {
                            Get.find<BusinessReportController>()
                                    .businessReportTabController
                                    ?.index =
                                1;
                            Get.to(() => const BusinessReport());
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              'view_all'.tr,
                              style: robotoSemiBold.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _EarningCard(
                            period: 'this_week'.tr,
                            amount: earningData?.thisWeek?.total ?? 0.0,
                            change: earningData?.thisWeek?.change ?? 0.0,
                            periodLabel: 'from_last_week'.tr,
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          _EarningCard(
                            period: 'this_month'.tr,
                            amount: earningData?.thisMonth?.total ?? 0.0,
                            change: earningData?.thisMonth?.change ?? 0.0,
                            periodLabel: 'from_last_month'.tr,
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          _EarningCard(
                            period: 'this_year'.tr,
                            amount: earningData?.thisYear?.total ?? 0.0,
                            change: earningData?.thisYear?.change ?? 0.0,
                            periodLabel: 'from_last_year'.tr,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EarningCard extends StatelessWidget {
  final String period;
  final double amount;
  final double change;
  final String periodLabel;

  const _EarningCard({
    required this.period,
    required this.amount,
    required this.change,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changeIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    final Color primary = Theme.of(context).primaryColor;

    return Container(
      width: 175,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall + 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withValues(alpha: 0.06),
            primary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 14,
                  color: primary,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall + 1),
              Expanded(
                child: Text(
                  period,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.color!.withValues(alpha: 0.7),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text(
            PriceConverter.convertPrice(amount, isShowLongPrice: true),
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).primaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(
                  Dimensions.paddingSizeExtraSmall - 1,
                ),
                decoration: BoxDecoration(
                  color: changeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(changeIcon, size: 11, color: changeColor),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              Expanded(
                child: Text(
                  '${isPositive ? '+' : ''}$change% $periodLabel',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall + 1,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.color!.withValues(alpha: 0.55),
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
