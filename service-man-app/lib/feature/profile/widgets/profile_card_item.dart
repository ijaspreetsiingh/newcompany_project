import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class ProfileCardItem extends StatelessWidget {
  final String leadingIcon;
  final bool? isDarkItem;
  final String title;
  final IconData? trailingIcon;

  const ProfileCardItem({
    super.key,this.trailingIcon=Icons.arrow_forward_ios,
    required this.title,
    required this.leadingIcon,
    this.isDarkItem=false
  }) ;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha:Get.isDarkMode?0.5:1),
        borderRadius: BorderRadius.circular(Ios27Tokens.radiusMd),
        border: Border.all(color: Ios27Tokens.rim(context), width: 0.5),
        boxShadow: Get.isDarkMode?null: Ios27Tokens.cardShadow(context),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                  height: Dimensions.paddingSizeLarge,
                  width:Dimensions.paddingSizeExtraLarge,
                  child: Image.asset(leadingIcon)
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Text(title,style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
            ],
          ),

          isDarkItem==false?Icon(
            trailingIcon,size: Dimensions.paddingSizeDefault,
            color: Theme.of(context).primaryColorLight,
          ): GetBuilder<ThemeController>(
            builder: (themeController){
              return GestureDetector(
                onTap: ()=> themeController.toggleTheme(),
                  child: Container(height: 25, width: 45,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(Ios27Tokens.radiusPill),
                    color: Get.isDarkMode ? Ios27Tokens.systemGreen : Colors.grey.withValues(alpha:0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: !themeController.darkTheme ? MainAxisAlignment.start : MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(2),
                        height: 22,
                        width: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: light.cardColor,),
                        child: Icon(themeController.darkTheme ?
                        Icons.dark_mode_outlined : Icons.light_mode_outlined,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
