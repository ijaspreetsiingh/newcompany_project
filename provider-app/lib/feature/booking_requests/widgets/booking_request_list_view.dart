import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class BookingRequestListview extends StatelessWidget {
  final String query;
  const BookingRequestListview({super.key, this.query = ''});

  bool _matchesQuery(BookingRequestModel booking, String q){
    if(q.isEmpty) return true;
    final String serviceName = (booking.subCategory?.name ?? "").toLowerCase();
    final String code = (booking.readableId ?? "").toLowerCase();
    final String type = booking.isRepeatBooking == 1 ? "repeat" : "regular";
    return serviceName.contains(q) || code.contains(q) || type.contains(q);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingRequestController>(
      builder: (bookingRequestController) {
        final String q = query.trim().toLowerCase();
        final List<BookingRequestModel> list = (bookingRequestController.bookingRequestList ?? [])
            .where((booking) => _matchesQuery(booking, q))
            .toList();

        if(list.isEmpty){
          return RefreshIndicator(
            color: InkColors.foreground,
            backgroundColor: InkColors.card,
            onRefresh: () async {
              Get.find<BookingRequestController>().getBookingRequestList(Get.find<BookingRequestController>()
                  .bookingRequestStatusList[Get.find<BookingRequestController>().currentIndex],1,
              );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: const [
                InkEmptyState('No bookings match this filter.'),
              ],
            ),
          );
        }

        return Column(
          children:[
            Expanded(
              child: RefreshIndicator(

                color: InkColors.foreground,
                backgroundColor: InkColors.card,
                onRefresh: () async {
                  Get.find<BookingRequestController>().getBookingRequestList(Get.find<BookingRequestController>()
                      .bookingRequestStatusList[Get.find<BookingRequestController>().currentIndex],1,
                  );
                },
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics()
                  ),
                  controller: bookingRequestController.scrollController,
                  itemCount: list.length,
                  padding: EdgeInsets.only(top: 16, bottom: bookingRequestController.isLoading ? 0 :  Dimensions.paddingSizeLarge),
                  itemBuilder: (ctx,index)=>BookingRequestItem(
                      booking : list[index]
                  ),
                ),
              ),
            ),

            bookingRequestController.isLoading ?  Center(child: CircularProgressIndicator(color: InkColors.foreground),) : const SizedBox.shrink()
          ],
        );
      },
    );
  }
}
