import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class CreateChannelDialog extends StatefulWidget {


  const CreateChannelDialog({super.key,});
  @override
  State<CreateChannelDialog> createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<CreateChannelDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimensions.webMaxWidth,
      padding: const EdgeInsets.only(
          left: Dimensions.paddingSizeDefault,
          bottom: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: context.kCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusLg)),
        border: Border(top: BorderSide(color: context.kBorder, width: 1)),
      ),
      child: GetBuilder<BookingDetailsController>(builder: (bookingDetailsController){

        var bookingDetails = bookingDetailsController.bookingDetails?.bookingContent?.bookingDetailsContent;

        Provider ? provider = bookingDetails?.provider ?? bookingDetails?.subBooking?.provider;
        DetailsCustomerModel ? customer = bookingDetails?.customer ?? bookingDetails?.subBooking?.customer;

        String titleText = "";

        if(provider !=null && customer !=null){
          titleText = "make_conversation_with_customer_and_provider";
        } else if(provider !=null){
          titleText = "make_conversation_with_provider";
        }
        else if(customer !=null){
          titleText = "make_conversation_with_customer";
        }
        return GetBuilder<ConversationController>(
            builder: (conversationController) {
              return SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InkWell(
                          onTap: () => Get.back(),
                          child: const Padding(
                            padding: EdgeInsets.only(top: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                            child: Icon(Icons.close),
                          )),
                      Padding(
                        padding: EdgeInsets.only(right: Dimensions.paddingSizeDefault, top: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault,
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(titleText.tr, style: robotoBold.copyWith(
                                fontSize: 18,
                                color: context.kForeground,
                              ),),
                              const SizedBox(height: Dimensions.paddingSizeLarge,),

                              GetBuilder<BookingDetailsController>(builder: (bookingDetailsController){
                                return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      KButton(
                                        label: 'zone_admin'.tr,
                                        outline: true,
                                        expanded: false,
                                        onTap:(){
                                          Get.back();
                                          String providerId = provider?.userId ?? "";
                                          String refId = bookingDetails?.id?? "";
                                          String name = provider?.companyName??"";
                                          String phone = provider?.companyPhone??"";
                                          String image = provider?.logoFullPath ??"";
                                          Get.find<ConversationController>().createChannel(providerId, refId,name: name,image: image,phone: phone.tr,userType: "provider");
                                        },
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeLarge),

                                      customer!=null?
                                      KButton(
                                        label: 'customer'.tr,
                                        outline: true,
                                        expanded: false,
                                        onTap:(){
                                          Get.back();
                                          String customerId = customer.id ?? "";
                                          String refId = bookingDetails?.id ?? "";
                                          String name = "${customer.firstName ?? ""}"" ${customer.lastName ?? ""}";
                                          String image = customer.profileImageFullPath ?? "";
                                          String phone = customer.phone??"";
                                          Get.find<ConversationController>().createChannel(customerId, refId,name: name,image: image,phone: phone.tr,userType: "customer");
                                        },
                                      ):const SizedBox(),

                                    ]);
                              }),
                              const SizedBox(height: Dimensions.paddingSizeLarge),
                              const SizedBox(height: Dimensions.paddingSizeLarge),
                            ]),
                      ),
                    ],
                ),
              );
            },
        );
      }),
    );
  }
}
