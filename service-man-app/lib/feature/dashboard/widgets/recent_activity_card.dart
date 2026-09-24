import 'package:demandium_serviceman/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';


class RecentActivityItem extends StatelessWidget {
  final DashboardBooking activityData;
  final RepeatBooking? repeatBooking;
  const RecentActivityItem({
    super.key, required this.activityData, this.repeatBooking,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Get.toNamed(RouteHelper.getBookingDetailsRoute(
              bookingId: repeatBooking?.id ?? activityData.id!,
              isSubBooking: repeatBooking != null,
            ));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CustomImage(
                    height: 56,
                    width: 56,
                    fit: BoxFit.cover,
                    image: Get.find<SplashController>().configModel?.content != null &&
                        activityData.detail != null &&
                        activityData.detail!.isNotEmpty &&
                        activityData.detail![0].service != null
                        ? activityData.detail![0].service!.thumbnailFullPath ?? ""
                        : "",
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "${"booking".tr} # ",
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          Text(
                            "${repeatBooking?.readableId ?? activityData.readableId}",
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                          ),
                          if (repeatBooking?.readableId != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF22C55E),
                              ),
                              child: const Icon(Icons.repeat_rounded, color: Colors.white, size: 8),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            textDirection: TextDirection.ltr,
                            DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate(
                              repeatBooking?.createdAt ?? activityData.createdAt!,
                            )),
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).hintColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Get.isDarkMode
                        ? Colors.grey.withValues(alpha: 0.2)
                        : context.customThemeColors.buttonBackgroundColorMap[
                              repeatBooking?.bookingStatus ?? activityData.bookingStatus],
                  ),
                  child: Text(
                    (repeatBooking?.bookingStatus?.tr ?? activityData.bookingStatus!.tr),
                    style: robotoMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: context.customThemeColors.buttonTextColorMap[
                        repeatBooking?.bookingStatus ?? activityData.bookingStatus],
                    ),
                  ),
                ),

                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
