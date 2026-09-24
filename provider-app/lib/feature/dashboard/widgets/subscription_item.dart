import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class SubscriptionCardItem extends StatelessWidget {
  final int index;
  final SubscriptionModelData subscriptionModelData;
  const SubscriptionCardItem({super.key, required this.subscriptionModelData, required this.index});

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;

    return Container(
      width: ResponsiveHelper.isDesktop(context)? Get.width*.2:ResponsiveHelper.isTab(context)?Get.width*.4:Get.width*.7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        color: primary.withValues(alpha: 0.06),
        border: Border.all(color: primary.withValues(alpha: 0.12)),
      ),
      margin:  EdgeInsets.only(top: 4,bottom:4,right: Dimensions.paddingSizeSmall, left: index == 0 ? Dimensions.paddingSizeDefault : 0),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomImage(height: 92, width: 92,
                image: '${subscriptionModelData.subCategory!=null?subscriptionModelData.subCategory!.imageFullPath:""}',
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: Dimensions.paddingSizeSmall,),

            Expanded(
              child: SizedBox(

                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [


                    Text(subscriptionModelData.subCategory!=null?subscriptionModelData.subCategory!.name!:"",
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.9),
                      ),
                      overflow: TextOverflow.ellipsis,),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall,),


                    Text('${subscriptionModelData.servicesCount.toString()} ${'services'.tr}',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).hintColor),),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall,),


                    Row(children: [
                      Icon(Icons.check_circle_rounded, size: 13, color: context.customThemeColors.success),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text('${subscriptionModelData.completedBookingCount.toString()} ${'bookings_completed'.tr}',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall + 1,
                            color: context.customThemeColors.success,
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: primary.withValues(alpha: 0.5)),
            const SizedBox(width: Dimensions.paddingSizeSmall,),
          ],),

          Positioned.fill(child: CustomInkWell(onTap: (){
            Get.to(ServicesScreen(
              subscriptionModelData : subscriptionModelData,
              fromPage: 'dashboard',
              index: index,
            ));
          },))
        ],
      ),
    );
  }
}
