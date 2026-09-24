import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class BookingHistorySectionMenu extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return GetBuilder<BookingRequestController>(
      builder: (bookingRequestController) {
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
                    itemCount: bookingRequestController.bookingHistoryStatus.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return InkWell(
                        child: CategoryTabItem(
                          title: bookingRequestController.bookingHistoryStatus[index].toLowerCase().tr,
                          index: index,
                        ),
                        onTap: () {
                          bookingRequestController.updateBookingHistorySelectedIndex(index);
                          bookingRequestController.getBookingHistory(
                            bookingRequestController.bookingHistoryStatus[index],
                            1,
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
