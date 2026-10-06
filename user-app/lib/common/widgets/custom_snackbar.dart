import 'package:jdds/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/design_system/nest_screens_kit.dart';

void customSnackBar(String? message,
    {ToasterMessageType type = ToasterMessageType.error,
      double margin = Dimensions.paddingSizeSmall,int duration =2,
      Color? backgroundColor, Widget? CustomWidget, double borderRadius = Dimensions.radiusSmall,
      bool showDefaultSnackBar = true,
      String? icon, String? toasterTitle,
    }) {
  if(message != null && message.isNotEmpty && Get.context != null) {
    final width = MediaQuery.of(Get.context!).size.width;
    final Color toastSurface = backgroundColor ?? (Get.isDarkMode
        ? const Color(0xFF202020)
        : Colors.white);
    final BoxDecoration toastDecoration = BoxDecoration(
      color: toastSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: NestInk.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: Get.isDarkMode ? 0.24 : 0.09),
          blurRadius: 18,
          offset: const Offset(0, 7),
        ),
      ],
    );

    if(showDefaultSnackBar){

      double margin = (Get.width - Dimensions.webMaxWidth)/2;

      ScaffoldMessenger.of(Get.context!)..hideCurrentSnackBar()..showSnackBar(SnackBar(

        content:  Material(
          color: Colors.transparent,
          child: Align(
            alignment: ResponsiveHelper.isDesktop(Get.context) ? Alignment.topRight : Alignment.bottomCenter,
            child: Container(
              decoration: toastDecoration,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: CustomWidget ?? Row(  mainAxisSize: toasterTitle != null ?  MainAxisSize.max : MainAxisSize.min, children: [
                icon !=null  ? Image.asset(icon, width: 25,) : CustomToasterIcon(type: type),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Flexible(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if(toasterTitle !=null) Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(toasterTitle.tr, style: robotoMedium.copyWith(color : NestInk.primary, ), maxLines: 2, overflow: TextOverflow.ellipsis,),
                    ),
                    Text(message, style: robotoRegular.copyWith(color : NestInk.mutedText, height: toasterTitle !=null ?  1.15 : 1.25), maxLines: 3, overflow: TextOverflow.ellipsis),
                  ]),
                ),
              ]),
            ),
          ),
        ),
        padding: EdgeInsets.only(bottom: ResponsiveHelper.isDesktop(Get.context) ? Dimensions.paddingSizeLarge : 0),
        margin: ResponsiveHelper.isDesktop(Get.context!)
            ? EdgeInsets.only(left: margin + Dimensions.webMaxWidth/2, top: 95, bottom: Get.height * 0.95 ,
            right: margin,)
            : const EdgeInsets.symmetric( horizontal : Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: duration),
        backgroundColor: backgroundColor ?? Colors.transparent,
        elevation: 0,
        clipBehavior: Clip.none,

      ));

    }else{
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Colors.transparent,
        duration: Duration(seconds: duration),
        overlayBlur: 0.0,
        messageText: CustomWidget ?? Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: toastDecoration,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                icon != null  ? Image.asset(icon, width: 25,) : CustomToasterIcon(type: type),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if(toasterTitle !=null) Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(toasterTitle.tr, style: robotoMedium.copyWith(color : NestInk.primary, ), maxLines: 2, overflow: TextOverflow.ellipsis,),
                    ),
                    Text(message, style: robotoRegular.copyWith(color : NestInk.mutedText, height: toasterTitle !=null ?  1.15 : 1.25), maxLines: 3, overflow: TextOverflow.ellipsis),
                  ]),
                ),
              ]),
            ),
          ),
        ),
        maxWidth: Dimensions.webMaxWidth,
        snackStyle: SnackStyle.GROUNDED,
        margin: ResponsiveHelper.isDesktop(Get.context!)
            ? EdgeInsets.only(left: width * 0.7, bottom: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeExtraSmall)
            : const EdgeInsets.symmetric( horizontal : Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
        borderRadius: borderRadius,
        isDismissible: true,

        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
        reverseAnimationCurve: Curves.fastEaseInToSlowEaseOut,
      ));
    }
  }
}


class CustomToasterIcon extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final ToasterMessageType type;
  final Color checkColor;

  const CustomToasterIcon({
    super.key,
    required this.type,
    this.size = 34,
    this.backgroundColor,
    this.checkColor = Colors.white,
  });

  ({Color color, IconData icon}) _getDataByType(BuildContext context) {
    switch(type) {
      case ToasterMessageType.success:
        return (color: context.customThemeColors.success, icon: Icons.check);
      case ToasterMessageType.error:
        return (color: context.customThemeColors.error, icon: Icons.close);

      case ToasterMessageType.info:
        return (color: context.customThemeColors.info, icon: Icons.info_outline);
    }
  }

  @override
  Widget build(BuildContext context) {

    final data = _getDataByType(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? data.color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          data.icon,
          size: size * 0.7, // Relative sizing
          color: checkColor,
        ),
      ),
    );
  }
}

