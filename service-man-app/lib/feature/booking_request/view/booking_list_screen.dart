import 'package:get/get.dart';
import 'package:jassdbx_serviceman/utils/core_export.dart';


class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key}) ;

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.kBackground,
      body: GetBuilder<BookingRequestController>(
        builder: (bookingRequestController){

          final List<BookingRequestModel> bookingList = bookingRequestController.bookingList;
          final String selectedStatus = bookingRequestController.bookingStatusState.name.toLowerCase();

          final List<Widget> bookingCards = <Widget>[];
          for (final BookingRequestModel booking in bookingList) {
            final List<RepeatBooking>? repeats = booking.repeatBookingList;
            if (repeats != null && repeats.isNotEmpty) {
              for (final RepeatBooking repeatBooking in repeats) {
                if (selectedStatus == 'all' || repeatBooking.bookingStatus == selectedStatus) {
                  bookingCards.add(BookingRequestItem(
                    bookingRequestModel: booking,
                    repeatBooking: repeatBooking,
                    onDecline: () => bookingRequestController.declineBookingFromList(repeatBooking.id),
                    onAccept: () => bookingRequestController.acceptBookingFromList(repeatBooking.id),
                  ));
                }
              }
            } else {
              bookingCards.add(BookingRequestItem(
                bookingRequestModel: booking,
                onDecline: () => bookingRequestController.declineBookingFromList(booking.id),
                onAccept: () => bookingRequestController.acceptBookingFromList(booking.id),
              ));
            }
          }

          return RefreshIndicator(
            backgroundColor: Theme.of(context).colorScheme.surface,
            color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.6),
            onRefresh: () async{
              bookingRequestController.getBookingList(selectedStatus,1);
            },
            child: CustomScrollView(
              controller:bookingRequestController.scrollController,
              physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: PageHeader(
                    title: 'bookings'.tr,
                    subtitle:
                        '${bookingList.length} ${'total_word'.tr} · ${bookingCards.length} ${'match_found'.tr}',
                    right: KIconButton(
                      icon: Icons.refresh_rounded,
                      onTap: () => bookingRequestController.getBookingList(selectedStatus, 1),
                    ),
                  ),
                ),

                SliverPersistentHeader(delegate: BookingListMenu(),pinned: true,floating: false,),

                bookingRequestController.isFirst ?
                const SliverToBoxAdapter(child: BookingRequestItemShimmer()) :
                bookingCards.isEmpty ?
                SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.work_outline_rounded,
                    title: 'no_bookings_here'.tr,
                    text: 'new_bookings_appear'.tr,
                  ),
                ) :
                SliverList(
                  delegate: SliverChildListDelegate(bookingCards),
                ),

                if (bookingRequestController.isLoading && !bookingRequestController.isFirst)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 112)),
              ],
            ),
          );
        },
      )
    );
  }
}
