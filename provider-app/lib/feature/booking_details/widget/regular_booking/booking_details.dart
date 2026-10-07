import 'package:demandium_provider/feature/booking_details/widget/booking_service_location.dart';
import 'package:demandium_provider/feature/booking_details/widget/ink_booking_sections.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class BookingDetailsWidget extends StatelessWidget {
  final String? bookingId;
  final String? subBookingId;
  final bool isSubBooking;
  final TabController? tabController;
  const BookingDetailsWidget({super.key,  this.bookingId, required this.isSubBooking, this.tabController, this.subBookingId,});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      initState: (_)=>  Get.find<BookingDetailsController>().showHideExpandView(0, shouldUpdate: false),
      builder: (bookingDetailsController) {
        final bookingDetailsContent = isSubBooking ? bookingDetailsController.subBookingDetails : bookingDetailsController.bookingDetails;

        if(bookingDetailsContent == null && bookingDetailsContent?.content == null){
          return const Center(child: BookingDetailsShimmer());
        } else if( bookingDetailsContent != null && bookingDetailsContent.content == null){
          return SizedBox(height: Get.height * 0.7, child:  BookingEmptyScreen (bookingId: bookingId ?? "",));
        }else{
          final BookingDetailsContent bookingDetails = isSubBooking
              ? bookingDetailsController.subBookingDetails!.content!
              : bookingDetailsController.bookingDetails!.content!;

          return Scaffold(
            backgroundColor: InkColors.background,
            body: Column( children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    if(isSubBooking){
                      await  Get.find<BookingDetailsController>().getBookingSubDetails(subBookingId ?? "", reload: false);
                    }else{
                      await  Get.find<BookingDetailsController>().getBookingDetails(bookingId?? "", reload: false);
                    }
                  },
                  child: SingleChildScrollView(physics: const ClampingScrollPhysics(), child: Column(children: [

                    const SizedBox(height: 24),

                    InkBookingCustomerCard(bookingDetails: bookingDetails, isSubBooking: isSubBooking),

                    const SizedBox(height: 24),

                    InkScheduleAddressSection(bookingDetails: bookingDetails),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: BookingServiceLocation(
                        bookingDetails: bookingDetails, isSubBooking: isSubBooking,
                        bookingEditType: isSubBooking ? BookingEditType.subBooking : BookingEditType.regular,
                      ),
                    ),

                    InkSection(
                      title: "Progress",
                      margin: const EdgeInsets.only(bottom: 24),
                      child: InkProgressTimeline(bookingDetails: bookingDetails),
                    ),

                    InkSection(
                      title: "Service items",
                      margin: const EdgeInsets.only(bottom: 24),
                      child: InkServiceItemsCard(bookingDetails: bookingDetails),
                    ),

                    BookingSummeryView(bookingDetails: bookingDetails),

                    PaymentInfoView(bookingDetails: bookingDetails),

                    InkAssignServicemanSection(
                      bookingDetails: bookingDetails,
                      bookingId: bookingDetails.id ?? "",
                      isSubBooking: isSubBooking,
                    ),

                    ServiceCompletedPhotoEvidence(bookingDetails: bookingDetails, isSubBooking: isSubBooking,),

                    InkBookingActionBar(
                      bookingDetails: bookingDetails,
                      bookingId: bookingDetails.id!,
                      isSubBooking: isSubBooking,
                    ),

                    const SizedBox(height: Dimensions.paddingSizeDefault,)
                  ],),
                  ),
                ),
              ),
            ]),

            floatingActionButton: bookingDetailsController.isShowChattingButton(bookingDetails, tabController) ?
            Padding(padding:  EdgeInsets.only(bottom: GetPlatform.isAndroid ? 70 : 35),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: 48, width: 48,
                    child: FloatingActionButton(
                      shape: const CircleBorder(),

                      heroTag: "1",
                      elevation: 0.0,
                      backgroundColor: Colors.green,
                      onPressed: () {
                        final String phone = bookingDetails.serviceAddress?.contactPersonNumber ??
                            bookingDetails.subBooking?.serviceAddress?.contactPersonNumber ?? "";
                        final String? customerId = bookingDetails.customerId;
                        if (customerId != null && customerId.isNotEmpty) {
                          Get.find<CallController>().startCall(
                            calleeId: customerId,
                            callType: 'voice',
                            bookingId: bookingDetails.id,
                            name: "${bookingDetails.customer?.firstName ?? ''} ${bookingDetails.customer?.lastName ?? ''}".trim(),
                            phone: phone,
                          );
                        } else if (phone.isNotEmpty) {
                          launchUrl(Uri(scheme: 'tel', path: phone), mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Icon(Icons.call,color: Colors.white, size: 20,),
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

                  SizedBox(height: 48, width: 48,
                    child: FloatingActionButton(
                      shape: const CircleBorder(),
                      heroTag: "2",
                      elevation: 0.0,
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        if(Get.find<UserProfileController>().checkAvailableFeatureInSubscriptionPlan(featureType: "chat")){
                          showCustomBottomSheet(child:  CreateChannelDialog(isSubBooking: isSubBooking,));
                        }
                      },
                      child: Icon(Icons.message_rounded,color: Theme.of(context).colorScheme.onPrimary,size: 18,),
                    ),
                  ),
                ],
              ),
            ) : null,
          );
        }
      },
    );
  }
}

class BookingEmptyScreen extends StatelessWidget {
  final String? bookingId;
  const BookingEmptyScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [
      Image.asset(Images.noResults, height: Get.height * 0.1, color: InkColors.mutedForeground,),
      const SizedBox(height: Dimensions.paddingSizeLarge,),
      Text("information_not_found".tr, style: robotoRegular.copyWith(color: InkColors.foreground),),
      const SizedBox(height: Dimensions.paddingSizeLarge,),

      CustomButton(
        height: 35, width: 120, radius: Dimensions.radiusExtraLarge,
        btnTxt: "go_back".tr, onPressed: () {
          Get.find<BookingRequestController>().removeBookingItemFromList(bookingId ?? "", shouldUpdate: true , bookingStatus: "");
        Get.back();
      },)

    ],),);
  }
}
