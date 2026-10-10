import 'package:jassdbx_provider/util/core_export.dart';
import 'package:jassdbx_provider/feature/booking_details/widget/ink_booking_sections.dart';
import 'package:jassdbx_provider/feature/custom_post/model/post_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class CustomerBookingAcceptView extends StatelessWidget {
  final PostData postData;
  const CustomerBookingAcceptView({super.key, required this.postData});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PostController>(builder: (postController){

      final bool isNewRequest = postController.tabController?.index == 0;
      final String customerName =
          "${postData.customer?.firstName ?? ""} ${postData.customer?.lastName ?? ""}".trim();
      final String posted = postData.createdAt != null
          ? DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate(postData.createdAt!))
          : "";
      final String note = postData.serviceDescription ?? "";
      final String distance = postData.distance ?? "";
      final double? minBid = postData.service?.minBiddingPrice;
      final bool canSeeOffers =
          Get.find<SplashController>().configModel.content?.bidOfferVisibilityForProvider == 1;

      void seeOtherOffers() {
        postController.getProviderOfferList(1, postData.id!, reload: true);
        showModalBottomSheet(
          isScrollControlled: false,
          backgroundColor: Colors.transparent,
          context: Get.context!,
          builder: (context) => const OtherProviderOfferScreen(),
        );
      }

      final Widget card = InkCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        postData.service?.name ?? "",
                        style: robotoBold.copyWith(
                          fontSize: 14.5,
                          height: 1.35,
                          color: InkColors.foreground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        customerName.isEmpty
                            ? posted
                            : posted.isEmpty ? customerName : "$customerName · $posted",
                        style: robotoRegular.copyWith(
                          fontSize: 11.5,
                          height: 1.3,
                          color: InkColors.mutedForeground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (minBid != null && minBid > 0) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: InkColors.border),
                    ),
                    child: Text(
                      PriceConverter.convertPrice(minBid, isShowLongPrice: true),
                      style: robotoBold.copyWith(fontSize: 10, height: 1.3, color: InkColors.foreground),
                    ),
                  ),
                ],
              ],
            ),

            if (note.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                note,
                style: robotoRegular.copyWith(
                  fontSize: 12.5,
                  height: 1.4,
                  color: InkColors.mutedForeground,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (distance.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 12),
                decoration:  BoxDecoration(
                  border: Border(top: BorderSide(color: InkColors.border)),
                ),
                child: Row(
                  children: [
                     Icon(Icons.location_on_outlined, size: 14, color: InkColors.mutedForeground),
                    const SizedBox(width: 6),
                    Text(
                      distance,
                      style: robotoRegular.copyWith(
                        fontSize: 11.5,
                        height: 1.3,
                        color: InkColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkPillButton(
                    label: isNewRequest ? "Give offer" : "Edit offer",
                    filled: true,
                    onTap: () => Get.to(() => CustomerPostDetailsScreen(postData: postData)),
                  ),
                ),
                if (canSeeOffers) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkPillButton(
                      label: "See other offers",
                      onTap: seeOtherOffers,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Slidable(
          key: ValueKey(postData.id),
          closeOnScroll: false,
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            dismissible: null,
            extentRatio: 0.4,
            children: [

              CustomSlidableAction(
                padding: const EdgeInsets.symmetric(vertical: 15),
                flex: 1,
                onPressed: (context)  {
                  showDialog(context: context, builder: (_){
                    return ConfirmationDialog(icon: Images.ignore,
                      title: isNewRequest ? 'ignore'.tr : 'withdraw'.tr,
                      description: isNewRequest
                          ? 'do_you_want_to_ignore_this_post'.tr
                          : 'do_you_want_to_withdraw_you_bid'.tr,
                      onYesPressed: () async{
                        Get.back();
                        showCustomDialog(child: const CustomLoader());
                        if (isNewRequest) {
                          await Get.find<PostController>().rejectCustomerPost(postData.id!);
                          Get.back();
                        } else {
                          await Get.find<PostController>().withdrawBidRequest(postData.id!);
                        }
                      },);
                  });
                },
                backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha:0.12),
                foregroundColor: Colors.white,
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(Dimensions.radiusSmall),
                    bottomRight:  Radius.circular(Dimensions.radiusSmall)),
                child: Image.asset(Images.ignore,height: 27,width: 27,),
              ),
            ],
          ),

          child: card,
        ),
      );
    });
  }
}
