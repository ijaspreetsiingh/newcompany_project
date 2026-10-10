import 'package:get/get.dart';
import 'package:jassdbx_serviceman/utils/core_export.dart';


class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key}) ;
  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {

  int _countStatus(List<BookingRequestModel> bookingList, String status) {
    int count = 0;
    for (final BookingRequestModel booking in bookingList) {
      final subBookings = booking.repeatBookingList;
      if (subBookings != null && subBookings.isNotEmpty) {
        for (final sub in subBookings) {
          if (sub.bookingStatus == status) {
            count++;
          }
        }
      } else if (booking.bookingStatus == status) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.kBackground,
      body: GetBuilder<BookingRequestController>(
        builder: (bookingRequestController){

          final List<BookingRequestModel> bookingList = bookingRequestController.bookingHistoryList;
          final String selectedTab = bookingRequestController.bookingHistoryStatus[bookingRequestController.bookingHistorySelectedIndex].toLowerCase();

          final List<Widget> bookingCards = <Widget>[];
          for (final BookingRequestModel booking in bookingList) {
            final List<RepeatBooking>? repeats = booking.repeatBookingList;
            if (repeats != null && repeats.isNotEmpty) {
              for (final RepeatBooking repeatBooking in repeats) {
                if (selectedTab == repeatBooking.bookingStatus || selectedTab == "all") {
                  bookingCards.add(BookingRequestItem(
                    bookingRequestModel: booking,
                    repeatBooking: repeatBooking,
                  ));
                }
              }
            } else {
              bookingCards.add(BookingRequestItem(bookingRequestModel: booking));
            }
          }

          return RefreshIndicator(
            backgroundColor: Theme.of(context).colorScheme.surface,
            color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.6),
            onRefresh: () async{
              bookingRequestController.getBookingHistory(
                bookingRequestController.bookingHistoryStatus[bookingRequestController.bookingHistorySelectedIndex],1
              );
            },
            child: CustomScrollView(
              controller: bookingRequestController.bookingHistoryScrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics()
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: PageHeader(
                    title: 'booking_history_title'.tr,
                    subtitle: '${bookingList.length} ${'bookings'.tr}',
                    onBack: () {
                      if (Navigator.canPop(context)) {
                        Get.back();
                      } else {
                        BottomNavScreen.onChangesIndex(0);
                      }
                    },
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(children: [
                      Expanded(
                        child: StatCard(
                          label: 'all'.tr,
                          value: '${bookingList.length}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          label: 'completed'.tr,
                          value: '${_countStatus(bookingList, 'completed')}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          label: 'canceled'.tr,
                          value: '${_countStatus(bookingList, 'canceled')}',
                        ),
                      ),
                    ]),
                  ),
                ),

                SliverPersistentHeader(delegate: BookingHistorySectionMenu(),pinned: true,floating: false,),

                bookingRequestController.isFirst ?
                const SliverToBoxAdapter(child: BookingRequestItemShimmer()) :
                bookingCards.isEmpty ?
                SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.history_rounded,
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

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}
