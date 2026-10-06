import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:jdds/common/widgets/staggered_list_animation.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';

class AddressScreen extends StatefulWidget {
  final String? fromPage;
  const AddressScreen({super.key, this.fromPage}) ;

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}


class _AddressScreenState extends State<AddressScreen> {

  @override
  void initState() {
    super.initState();
    Get.find<LocationController>().getAddressList(fromCheckout: widget.fromPage=="checkout"?true:false);
  }


  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        appBar: CustomAppBar(title: 'my_address'.tr),
        drawer: ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,

        endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer():null,

        body: GetBuilder<LocationController>(
            builder: (locationController) {
              List<AddressModel>? addressList = locationController.addressList;
              List<AddressModel>? zoneBasedAddress = [];
              if(addressList != null && addressList.isNotEmpty ){
                zoneBasedAddress =  addressList.where((element) =>
                element.zoneId == Get.find<LocationController>().getUserAddress()?.zoneId).toList();
              }
              if(widget.fromPage == "checkout"){
                addressList = zoneBasedAddress;
              }

              AddressModel? addressModel;
              addressModel = locationController.getUserAddress();


              if(locationController.addressList!=null){
                return FooterBaseView(
                    isCenter: (addressList == null || addressList.isEmpty),
                    child: WebShadowWrap(
                      child: Column(
                        children: [
                          ResponsiveHelper.isDesktop(context) ?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomButton(
                                width: 200,
                                buttonText: 'add_new_address'.tr,
                                onPressed: () => Get.toNamed(RouteHelper.getAddAddressRoute(widget.fromPage == 'checkout' ? true : false)),
                              ),
                            ],
                          ): const SizedBox(),
                          const SizedBox(height: Dimensions.paddingSizeDefault,),

                          addressList!.isNotEmpty ?
                          RefreshIndicator(
                            onRefresh: () async {
                              await locationController.getAddressList();
                            },
                            child: SizedBox(
                              width: Dimensions.webMaxWidth,
                              child: (addressList.isNotEmpty)?
                              StaggeredListAnimationWrapper(
                                key: ValueKey(addressList.length),
                                duration: const Duration(milliseconds: 600),
                                child: Column(
                                  children: [
                                    for(int index=0; index<addressList.length; index++)
                                      StaggeredListAnimationItem(
                                        index: index,
                                        child: AddressWidget(
                                          selectedUserAddressId: addressModel?.id,
                                          address: addressList![index],
                                          fromAddress: true,
                                          fromCheckout: widget.fromPage == 'checkout' ? true : false,

                                          onTap: () async {
                                            if(widget.fromPage == 'checkout'){
                                              if(isRedundentClick(DateTime.now())){
                                                return;
                                              }
                                              Get.dialog(const CustomLoader(),barrierDismissible: false);
                                              await locationController.setAddressIndex(addressList![index]).then((isSuccess){
                                                Get.back();
                                                if(!isSuccess){
                                                  customSnackBar('this_service_not_available'.tr);
                                                }
                                              });
                                              Get.back();
                                            }
                                          },

                                          onEditPressed: () {
                                            Get.toNamed(
                                                RouteHelper.getEditAddressRoute(addressList![index], false));
                                          },
                                          onRemovePressed: () {
                                            if (Get.isSnackbarOpen) {
                                              Get.back();
                                            }
                                            Get.dialog(ConfirmationDialog(
                                              icon: Images.warning,
                                              description: 'are_you_sure_want_to_delete_address'.tr,
                                              onYesPressed: () {
                                                Navigator.of(context).pop();

                                                Get.dialog(
                                                  const CustomLoader(), barrierDismissible: false,
                                                );
                                                locationController.deleteUserAddressByID(addressList![index],
                                                ).then((response) {
                                                  Get.back();
                                                  customSnackBar(response.message!.tr.capitalizeFirst,type : ToasterMessageType.success);
                                                });
                                              },
                                            ));
                                          },
                                        ),
                                      ),
                                    const SizedBox(height: Dimensions.paddingSizeSmall),
                                    NestOutlineAction(
                                      label: 'add_new_address'.tr,
                                      icon: Icons.add_rounded,
                                      onTap: () => Get.toNamed(RouteHelper.getAddAddressRoute(widget.fromPage == 'checkout' ? true : false)),
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeDefault),
                                  ],
                                ),
                              ): const SizedBox(),
                            ),
                          ) :
                          SizedBox(height: Get.height*0.6,child: Center(child: NoDataScreen(text: 'no_address_found'.tr,type: NoDataType.address,))),
                        ],
                      ),
                    ));
              }else{
                return const Center(child: CircularProgressIndicator(),);
              }
            }),
      ),
    );
  }
}
