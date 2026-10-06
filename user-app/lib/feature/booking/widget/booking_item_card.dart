import 'package:jdds/common/models/popup_menu_model.dart';
import 'package:jdds/feature/booking/widget/booking_status_widget.dart';
import 'package:jdds/helper/booking_helper.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingItemCard extends StatelessWidget {
  final BookingModel bookingModel;
  final int index;
  const BookingItemCard({super.key, required this.bookingModel, required this.index}) ;

  @override
  Widget build(BuildContext context) {
    String bookingStatus = bookingModel.bookingStatus!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);
    final bgColor = isDark ? const Color(0xFF171717) : Colors.white;
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);

    return InkWell(
      onTap: () {
        if(bookingModel.isRepeatBooking == 1){
          Get.toNamed(RouteHelper.getRepeatBookingDetailsScreen(bookingId:bookingModel.id!));
        }else{
          Get.toNamed(RouteHelper.getBookingDetailsScreen(bookingID:bookingModel.id!));
        }
      },

      child: GetBuilder<ServiceBookingController>(builder: (serviceBookingController){
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(
                  children: [
                    Text('${'booking'.tr}# ${bookingModel.readableId}', 
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      )),
                    if(bookingModel.isRepeatBooking == 1)Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor),
                      padding: const EdgeInsets.all(2),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: const Icon(Icons.repeat, color: Colors.white, size: 10),
                    )
                  ],
                ),

                PopupMenuButton<PopupMenuModel>(
                  shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    side: BorderSide(color: borderColor),
                  ),
                  surfaceTintColor: bgColor,
                  position: PopupMenuPosition.under, elevation: 8,
                  shadowColor: mutedColor.withValues(alpha: 0.3),
                  itemBuilder: (BuildContext context) {
                    return serviceBookingController.getPopupMenuList(
                      status: bookingStatus,
                      isRepeatBooking: bookingModel.isRepeatBooking == 1,
                      isCustomizeBooking: bookingModel.isCustomizeBooking ?? false,
                    ).map((PopupMenuModel option) {
                      return PopupMenuItem<PopupMenuModel>(
                        value: option,
                        height: 35,
                        onTap: () async {

                          if(option.title == "booking_details"){
                            if(bookingModel.isRepeatBooking == 1){
                              Get.toNamed(RouteHelper.getRepeatBookingDetailsScreen( bookingId :bookingModel.id!));
                            }else{
                              Get.toNamed(RouteHelper.getBookingDetailsScreen(bookingID :bookingModel.id!,));
                            }
                          }
                          if(option.title == "rebook"){
                            serviceBookingController.updateRebookIndex(index);
                           await serviceBookingController.checkCartSubcategory(bookingModel.id!, bookingModel.subCategoryId!);
                          }

                          else if(option.title == "download_invoice"){
                            String uri = "";
                            String languageCode = Get.find<LocalizationController>().locale.languageCode;
                            if(bookingModel.isRepeatBooking == 1){
                              uri = "${AppConstants.baseUrl}${AppConstants.repeatBookingInvoiceUrl}${bookingModel.id}/$languageCode";
                            }else{
                              uri = "${AppConstants.baseUrl}${AppConstants.regularBookingInvoiceUrl}${bookingModel.id}/$languageCode";
                            }
                            if (kDebugMode) {
                              print("Uri : $uri");
                            }
                            await _launchUrl(Uri.parse(uri));
                          } else if(option.title == "cancel"){
                            Get.dialog(
                              ConfirmationDialog(
                                icon: Images.warning,
                                title:  bookingModel.isRepeatBooking == 1 ? 'are_you_sure_to_cancel_this_full_booking'.tr : 'are_you_sure_to_cancel_your_order'.tr,
                                description: bookingModel.isRepeatBooking == 1 ? 'once_cancel_full_booking'.tr : 'your_order_will_be_cancel'.tr,
                                noButtonText: "yes_cancel".tr,
                                noButtonColor: Theme.of(context).colorScheme.primary,
                                noTextColor: Colors.white,
                                yesButtonText: "not_now".tr,
                                yesButtonColor: Theme.of(context).colorScheme.error,
                                yesTextColor: Colors.white,
                                buttonFontSize: Dimensions.fontSizeSmall + 1,
                                onYesPressed: () {
                                  Get.back();
                                },
                                onNoPressed: () async {
                                  Get.back();
                                  Get.dialog(const CustomLoader(), barrierDismissible: false);
                                  await Get.find<BookingDetailsController>().bookingCancel(
                                    bookingId: bookingModel.id ?? "", fromListScreen: true,
                                  );
                                  Get.back();
                                },
                              ),
                              useSafeArea: false,
                            );
                          }

                        },
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Icon(option.icon, size: 18, color: primaryColor),
                            const SizedBox(width: 8),
                            Text(option.title.tr, style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: primaryColor
                            )),
                          ],
                        ),
                      );
                    }).toList();
                  },
                  child: Icon(Icons.more_vert_sharp, color: mutedColor),
                ),
              ]),
              const SizedBox(height: 12),

              Row( children: [
                Text('${'booking_date'.tr} : ', style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: mutedColor,
                )),
                Text(DateConverter.dateMonthYearTimeTwentyFourFormat(DateConverter.isoUtcStringToLocalDate(bookingModel.createdAt.toString())),
                  textDirection: TextDirection.ltr,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: primaryColor,
                  ),
                ),
              ]),
              const SizedBox(height: 4),

              Row( children: [
                Text('${'service_date'.tr} : ', style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: mutedColor,
                )),
                if(BookingHelper.getRepeatBookingCurrentSchedule(bookingModel) !=null) 
                  Text(DateConverter.dateMonthYearTimeTwentyFourFormat(DateTime.tryParse(BookingHelper.getRepeatBookingCurrentSchedule(bookingModel)!)!),
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: primaryColor,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
              ]),
              const SizedBox(height: 12),

              Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                BookingStatusButtonWidget(bookingStatus: bookingModel.bookingStatus,),

                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(PriceConverter.convertPrice(bookingModel.totalBookingAmount!.toDouble()),
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                ),
              ]),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}



