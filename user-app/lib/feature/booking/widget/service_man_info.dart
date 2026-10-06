import 'package:jdds/common/models/user_model.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
class ServiceManInfo extends StatelessWidget {
  final User user;
  const ServiceManInfo({super.key,required this.user, }) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
        color: Theme.of(context).cardColor,
        boxShadow: Get.find<ThemeController>().darkTheme ? null : searchBoxShadow,
      ),
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge, horizontal: Dimensions.paddingSizeDefault),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              height: 30, width: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              ),
              child: Icon(Icons.engineering_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text('partner'.tr, style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color:Get.isDarkMode? Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .6): Theme.of(context).colorScheme.primary)),
          ]),
          Gaps.verticalGapOf(Dimensions.paddingSizeDefault),

          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeExtraLarge)),
              child: SizedBox(
                width: Dimensions.imageSize,
                height: Dimensions.imageSize,
                child:  CustomImage(image: user.profileImageFullPath ?? ""),

              ),
            ),
          ),
          Gaps.verticalGapOf(Dimensions.paddingSizeDefault),
          Text("${user.firstName ?? ""} ${user.lastName ?? ""}",style:robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge,)),
          Gaps.verticalGapOf(Dimensions.paddingSizeExtraSmall),
          Text(user.phone ?? "",style:robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor,)),
        ],
      ),
    );
  }
}


