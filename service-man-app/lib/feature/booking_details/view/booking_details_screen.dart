import 'package:demandium_serviceman/feature/booking_details/widget/booking_details_widget.dart';
import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';


class BookingDetailsScreen extends StatefulWidget{
  final String bookingId;
  final String? fromPage;
  final bool isSubBooking ;
  const BookingDetailsScreen({super.key,required this.bookingId, this.fromPage, required this.isSubBooking,}) ;

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}
class _BookingDetailsScreenState extends State<BookingDetailsScreen> with SingleTickerProviderStateMixin {

  TabController? controller;

  @override
  void initState() {
    super.initState();
    var bookingDetailsController = Get.find<BookingDetailsController>();
    controller = TabController(vsync: this, length: 2);
    bookingDetailsController.resetBookingDetailsValue();
    bookingDetailsController.getBookingDetails(bookingID :widget.bookingId, isSubBooking: widget.isSubBooking);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _selectTab(BookingDetailsController bookingDetailsController, int index) {
    controller?.animateTo(index);
    if (index == 0) {
      bookingDetailsController.updateServicePageCurrentState(
        BookingDetailsTabControllerState.bookingDetails,
      );
    } else {
      bookingDetailsController.updateServicePageCurrentState(
        BookingDetailsTabControllerState.status,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      builder: (bookingDetailsController){

        final bookingDetails = bookingDetailsController.bookingDetails?.bookingContent?.bookingDetailsContent;
        final String readableId = bookingDetails?.readableId ?? '';
        final bool hasReadableId = readableId.isNotEmpty && readableId != 'null';

        final int isGuest = bookingDetails?.isGuest ?? 0;
        final bool isPartial = (bookingDetails != null && bookingDetails.partialPayments != null && bookingDetails.partialPayments!.isNotEmpty);
        final String bookingStatus = bookingDetails?.bookingStatus ?? "";
        final bool subBookingPaid = widget.isSubBooking && bookingDetails?.isPaid == 1;

        final bool isEditBooking = (Get.find<SplashController>().configModel?.content?.serviceManCanEditBooking == 1
            && bookingDetailsController.bookingDetails?.bookingContent?.providerServicemanCanEditBooking == 1)
            && (!subBookingPaid && !isPartial && (bookingStatus == "accepted" || bookingStatus == "ongoing")
                && ((isGuest == 1 && bookingDetails?.paymentMethod != "cash_after_service") ? false : true));

        return CustomPopScopeWidget(
          child: Scaffold(
            backgroundColor: context.kBackground,
            body: SafeArea(
              bottom: false,
              child: Column(children: [

                PageHeader(
                  title: 'booking_details_title'.tr,
                  subtitle: hasReadableId ? '#$readableId' : '',
                  onBack: (){
                    if(widget.fromPage == 'fromNotification'){
                      Get.offAllNamed(RouteHelper.getInitialRoute());
                    }else{
                      Get.back();
                    }
                  },
                  right: KIconButton(
                    icon: Icons.edit_outlined,
                    color: isEditBooking ? context.kForeground : context.kMutedForeground,
                    onTap: isEditBooking ? (){
                      Get.to(()=> BookingEditScreen(isSubBooking: widget.isSubBooking,));
                    } : null,
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: context.kBorder, width: 1)),
                  ),
                  child: AnimatedBuilder(
                    animation: controller!,
                    builder: (context, _) => Row(children: [
                      _tabButton(context, 0, 'details'.tr, bookingDetailsController),
                      _tabButton(context, 1, 'status'.tr, bookingDetailsController),
                    ]),
                  ),
                ),

                Expanded(
                  child: TabBarView(controller: controller, children:  [
                    BookingDetailsWidget(isSubBooking: widget.isSubBooking,),
                    const BookingStatus(),
                  ]),
                ),
              ]),
            ),

            floatingActionButton: bookingDetailsController.isShowChattingButton(bookingDetails) ? Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                height: 56, width: 56,
                decoration: BoxDecoration(
                  color: context.kPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: ()=> Get.bottomSheet( const CreateChannelDialog()),
                    customBorder: const CircleBorder(),
                    child: Icon(Icons.chat_bubble_rounded, size: 24, color: context.kPrimaryForeground),
                  ),
                ),
              ),
            ) : null,

          ),
        );
      },
    );
  }

  Widget _tabButton(BuildContext context, int index, String label, BookingDetailsController bookingDetailsController) {
    final bool isActive = controller?.index == index;
    return Expanded(
      child: InkWell(
        onTap: () => _selectTab(bookingDetailsController, index),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? context.kForeground : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: robotoMedium.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? context.kForeground : context.kMutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}
