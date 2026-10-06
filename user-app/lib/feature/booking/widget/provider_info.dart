import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class ProviderInfo extends StatelessWidget {
  final ProviderData ? provider;
  const ProviderInfo({super.key, required this.provider}) ;

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
      child: Column( children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            height: 30, width: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            ),
            child: Icon(Icons.business_center_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Text('zone_admin'.tr, style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
          )),
        ]),
        Gaps.verticalGapOf(Dimensions.paddingSizeDefault),

        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: SizedBox(
              width: Dimensions.imageSize,
              height: Dimensions.imageSize,
              child: CustomImage(image: provider?.logoFullPath ?? "", placeholder: Images.userPlaceHolder),
            ),
          ),
        ),
        Gaps.verticalGapOf(Dimensions.paddingSizeDefault),
        if(provider?.companyName !=null) Text(provider?.companyName ??"",style:robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge,)),
        Gaps.verticalGapOf(Dimensions.paddingSizeExtraSmall),
        Text(provider == null ? "no_provider_assigned".tr : provider?.companyPhone ?? "",
          style:robotoRegular.copyWith(
            fontSize: provider == null ? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault,
            color: Theme.of(context).hintColor,
          ),
        ),
        Gaps.verticalGapOf(Dimensions.paddingSizeSmall),
      ]),
    );
  }
}


