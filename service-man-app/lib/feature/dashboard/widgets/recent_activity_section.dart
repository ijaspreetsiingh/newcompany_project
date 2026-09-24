
import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (dashboardController) {
      List<DashboardBooking> bookingList = dashboardController.bookings;
      int itemCount = 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "recent_bookings".tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              if (bookingList.isNotEmpty)
                GestureDetector(
                  onTap: () => BottomNavScreen.onChangesIndex(2),
                  child: Row(
                    children: [
                      Text(
                        "view_all".tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, size: 16, color: Theme.of(context).primaryColor),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          bookingList.isEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'your_recent_booking_will_appear_here'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: bookingList.length,
                  itemBuilder: (context, index) {
                    bool isRepeatBooking = bookingList[index].repeatBookingList != null &&
                        bookingList[index].repeatBookingList!.isNotEmpty;

                    if (!isRepeatBooking) {
                      itemCount++;
                    }

                    if (isRepeatBooking && itemCount < 6) {
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bookingList[index].repeatBookingList!.length,
                        itemBuilder: (context, secondIndex) {
                          itemCount++;
                          return itemCount < 6
                              ? RecentActivityItem(
                                  activityData: bookingList[index],
                                  repeatBooking: bookingList[index].repeatBookingList![secondIndex],
                                )
                              : const SizedBox();
                        },
                      );
                    } else if (itemCount < 6) {
                      return RecentActivityItem(activityData: bookingList[index]);
                    }
                    return const SizedBox();
                  },
                ),
        ],
      );
    });
  }
}
