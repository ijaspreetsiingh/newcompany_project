import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';


class BottomCard extends StatelessWidget {

  const BottomCard({super.key, required this.name, required this.phone, required this.image, this.address});

  final String name;
  final String phone;
  final String image;
  final String? address;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CustomImage(
              height: 50,
              width: 50,
              image: image,
              placeholder: Images.userPlaceHolder,
            )
        ),

        const SizedBox(height: Dimensions.paddingSizeSmall,),
        Text(name, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: context.kForeground),textAlign: TextAlign.center,),

        const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
        Text(phone, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
            color: context.kMutedForeground)),

        if(address != null) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall,),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
            child: RichText(
                text: TextSpan(text: '${'service_address'.tr} :',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault,
                    color: context.kForeground,
                  ),
                  children: [
                    TextSpan(
                      text: ' $address',
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: context.kMutedForeground,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center),
          ),
        ],
      ],
    );
  }
}
