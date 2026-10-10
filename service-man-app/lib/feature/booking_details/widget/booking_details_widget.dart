import 'package:get/get.dart';
import 'package:jassdbx_serviceman/utils/core_export.dart';



class BookingDetailsWidget extends StatefulWidget{
  final String? bookingId;
  final bool isSubBooking;
  const BookingDetailsWidget({super.key, this.bookingId, required this.isSubBooking}) ;

  @override
  State<BookingDetailsWidget> createState() => _BookingDetailsWidgetState();
}

class _BookingDetailsWidgetState extends State<BookingDetailsWidget> {

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      builder: (bookingDetailsController){

        final bookingDetailsModel = bookingDetailsController.bookingDetails;
        final bookingDetails = bookingDetailsController.bookingDetails?.bookingContent?.bookingDetailsContent;

        bool showDeliveryConfirmImage = bookingDetailsController.showPhotoEvidenceField;

        if (bookingDetailsModel == null && bookingDetailsModel?.bookingContent == null) {
          return const BookingDetailsShimmer();
        }
        if (bookingDetailsModel != null && bookingDetailsModel.bookingContent == null) {
          return SizedBox(height: Get.height * 0.7, child:  BookingEmptyScreen (bookingId: widget.bookingId ?? ""));
        }
        if (bookingDetails == null) {
          return const BookingDetailsShimmer();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: SingleChildScrollView(
              controller: bookingDetailsController.scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    BookingInformationView(bookingDetails: bookingDetails, isSubBooking: widget.isSubBooking,),

                    const SizedBox(height: 16),

                    KButton(
                      label: "invoice".tr,
                      icon: Icons.receipt_long_outlined,
                      outline: true,
                      onTap: () async {
                        Get.dialog(const CustomLoader(), barrierDismissible: false);
                        String languageCode = Get.find<LocalizationController>().locale.languageCode;
                        String uri = "${AppConstants.baseUrl}${widget.isSubBooking ? AppConstants.singleRepeatBookingInvoiceUrl : AppConstants.regularBookingInvoiceUrl}${bookingDetails.id}/$languageCode";
                        if (kDebugMode) {
                          print("Uri : $uri");
                        }
                        await _launchUrl(Uri.parse(uri));
                        Get.back();
                      },
                    ),

                    const SizedBox(height: 16),

                    BookingSummeryView(bookingDetails: bookingDetails),

                    const SizedBox(height: 16),

                    BookingDetailsProviderInfo(bookingDetails: bookingDetails),

                    if (bookingDetails.photoEvidenceFullPath != null &&  bookingDetails.photoEvidenceFullPath!.isNotEmpty) ...[
                      const SizedBox(height: 16,),
                      CaptionTitle('completed_service_picture'.tr),

                      const SizedBox(height: 12),

                      Container(
                        height: 94,
                        decoration: BoxDecoration(
                          color: context.kMuted,
                          borderRadius: BorderRadius.circular(kRadiusMd),
                        ),
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: ListView.builder(
                          controller: bookingDetailsController.completedServiceImagesScrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount:  bookingDetails.photoEvidenceFullPath?.length,
                          itemBuilder: (context, index) {
                            return Hero(
                              tag: bookingDetails.photoEvidenceFullPath?[index] ?? "",
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(kRadiusSm),
                                  child: GestureDetector(
                                    onTap: (){
                                      Get.to(ImageDetailScreen(
                                        imageList: bookingDetails.photoEvidenceFullPath ?? [],
                                        index: index,
                                        appbarTitle: 'completed_service_picture'.tr,

                                      ),
                                      );
                                    },
                                    child: CustomImage(
                                      image: bookingDetails.photoEvidenceFullPath?[index]??"",
                                      height: 70, width: 120,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    if (Get.find<SplashController>().configModel?.content?.bookingImageVerification == 1 && showDeliveryConfirmImage && bookingDetails.bookingStatus != 'completed') ...[
                      const SizedBox(height: 16,),
                      CaptionTitle('completed_service_picture'.tr),

                      const SizedBox(height: 12),

                      Container(
                        height: 94,
                        decoration: BoxDecoration(
                          color: context.kMuted,
                          borderRadius: BorderRadius.circular(kRadiusMd),
                        ),
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: bookingDetailsController.pickedPhotoEvidence.length+1,
                          itemBuilder: (context, index) {
                            XFile? file = index == bookingDetailsController.pickedPhotoEvidence.length ? null : bookingDetailsController.pickedPhotoEvidence[index];
                            if(index < 5 && index == bookingDetailsController.pickedPhotoEvidence.length) {
                              return InkWell(
                                onTap: () {
                                  Get.bottomSheet(CameraButtonSheet(bookingId: bookingDetails.id ?? "", isSubBooking: widget.isSubBooking,));
                                },
                                child: Container(
                                  height: 60, width: 70, alignment: Alignment.center, decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(kRadiusMd),
                                  color: context.kCard,
                                  border: Border.all(color: context.kBorder, width: 1),
                                ),
                                  child:  Icon(Icons.add_a_photo_outlined, color: context.kForeground, size: 24),
                                ),
                              );
                            }
                            return file != null ? Container(
                              margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(kRadiusSm),
                              ),
                              child: Stack(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(kRadiusSm),
                                  child: GetPlatform.isWeb ? Image.network(
                                    file.path, width: 120, height: 70, fit: BoxFit.cover,
                                  ) : Image.file(
                                    File(file.path), width: 120, height: 70, fit: BoxFit.cover,
                                  ),
                                ),
                              ]),
                            ) : const SizedBox();
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height:25),
                  ],
                ),
              ),
            ),),
            bookingDetails.bookingStatus == "accepted" ||  bookingDetails.bookingStatus == "ongoing" ?
            SafeArea(child: StatusChangeDropdownButton(bookingId: bookingDetails.id??"",bookingDetails: bookingDetails ,isSubBooking: widget.isSubBooking,)): const SizedBox(),
          ],
        );
      },
    );
  }


  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}

class MapUtils {
  MapUtils._();

  static Future<void> openMap(double destinationLatitude, double destinationLongitude, double userLatitude, double userLongitude) async {
    String googleUrl = 'https://www.google.com/maps/dir/?api=1&origin=$userLatitude,$userLongitude'
        '&destination=$destinationLatitude,$destinationLongitude&mode=d';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }
}

class BookingEmptyScreen extends StatelessWidget {
  final String? bookingId;
  const BookingEmptyScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [
      Image.asset(Images.noResults, height: Get.height * 0.1, color: Theme.of(context).primaryColor,),
      const SizedBox(height: Dimensions.paddingSizeLarge,),
      Text("information_not_found".tr, style: robotoRegular,),
      const SizedBox(height: Dimensions.paddingSizeLarge,),

      KButton(
        label: "go_back".tr,
        outline: true,
        height: 40,
        expanded: false,
        onTap: () {
          Get.back();
        },)

    ],),);
  }
}
