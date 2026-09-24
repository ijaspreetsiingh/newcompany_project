import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class BookingListMenu extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    Get.find<BookingRequestController>();

    return GetBuilder<BookingRequestController>(
      builder: (bookingListController) {
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ListView.builder(
                    itemCount: BooingListStatus.values.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return GetBuilder<BookingRequestController>(
                        builder: (bookingListController) {
                          return InkWell(
                            child: BookingMenuItem(
                              title: BooingListStatus.values.elementAt(index).name.toLowerCase().tr,
                              index: index,
                            ),
                            onTap: () => bookingListController.updateBookingStatusState(
                              BooingListStatus.values.elementAt(index),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  double get maxExtent => 52;

  @override
  double get minExtent => 52;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
