import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class AdvertisementSection extends StatelessWidget {
  const AdvertisementSection({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;

    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeDefault,
            0,
          ),
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primary.withValues(alpha: 0.10),
                  Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
              border: Border.all(color: primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(
                    Dimensions.paddingSizeSmall - 2,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                  ),
                  child: Image.asset(
                    Images.dashboardAdsIcon,
                    height: 34,
                    width: 34,
                  ),
                ),

                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'want_to_get_highlighted'.tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Text(
                        'create_ads_to_reach_more_customers'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      Get.find<BusinessSubscriptionController>()
                          .openTrialEndBottomSheet()
                          .then((isTrial) {
                            if (isTrial) {
                              if (Get.find<UserProfileController>()
                                  .checkAvailableFeatureInSubscriptionPlan(
                                    featureType: 'advertisement',
                                  )) {
                                Get.find<AdvertisementController>()
                                    .resetAllValues();
                                Get.to(
                                  () => const CreateAdvertisementScreen(
                                    isEditScreen: false,
                                  ),
                                );
                              }
                            }
                          });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeSmall - 1,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primary,
                            Color.lerp(primary, const Color(0xFF1E40AF), 0.45)!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.30),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        'create_ads'.tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
