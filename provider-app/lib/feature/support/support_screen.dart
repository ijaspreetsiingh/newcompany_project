import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class SupportScreen extends StatelessWidget {

  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          InkTopBar(
            title: 'help_&_support'.tr,
            onBack: () => Get.back(),
            right: const InkIconButton(icon: Icons.more_horiz),
          ),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,  children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(minHeight: Get.height * 0.4),
                          child: Center(
                            child: Column( children: [
                              const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),
                              Align( alignment: Alignment.center,
                                child: Container(
                                  height: 72,
                                  width: 72,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: InkColors.secondary,
                                    border: Border.all(color: InkColors.border),
                                    borderRadius: BorderRadius.circular(19),
                                  ),
                                  child:  Icon(Icons.support_agent_rounded, size: 32, color: InkColors.foreground),
                                ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'contact_for_support'.tr,
                                      style: displayBold.copyWith(
                                        fontSize: 22,
                                        height: 1.2,
                                        color: InkColors.foreground,
                                      ),
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeDefault),
                                    Text(
                                      'were_here_to_help'.tr,
                                      style: robotoRegular.copyWith(
                                        fontSize: 13,
                                        color: InkColors.mutedForeground,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                        ),
                        SizedBox(height: Dimensions.paddingSizeLarge),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column( children: [
                            ContactWithEmailOrPhone(
                              title: 'call_our_customer'.tr,
                              subTitle: 'talk_with_our_customer'.tr,
                              message: Get.find<SplashController>().configModel.content?.businessPhone ?? '',
                              isPhone: true,
                            ),
                            const SizedBox(height: 12),
                            ContactWithEmailOrPhone(
                              title: 'send_us_email_through'.tr,
                              subTitle: 'typically_the_support'.tr,
                              message: Get.find<SplashController>().configModel.content?.businessEmail ?? '',
                              isPhone: false,
                            ),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}


class ContactWithEmailOrPhone extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final String? message;
  final bool? isPhone;
  ContactWithEmailOrPhone({super.key, required this.title, required this.subTitle, required this.message, required this.isPhone});

  @override
  Widget build(BuildContext context) {
    return InkCard(
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Container(
          height: 34,
          width: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: InkColors.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(isPhone ?? false ? Icons.call_rounded : Icons.mail_rounded, size: 17, color: InkColors.foreground),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title!, style: robotoSemiBold.copyWith(fontSize: 14, height: 1.3, color: InkColors.foreground)),
            const SizedBox(height: 4),

            Text(subTitle!, style: robotoRegular.copyWith(fontSize: 12, height: 1.5, color: InkColors.mutedForeground), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(message ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoBold.copyWith(fontSize: 14, color: InkColors.foreground)
                  ),
                ),

                const SizedBox(width: 8),

                InkIconButton(
                  icon: isPhone! ? Icons.call_rounded : Icons.mail_rounded,
                  filled: true,
                  onTap: () async {
                    try {
                      final bool ok = await launchUrl(isPhone! ? launchUri : email, mode: LaunchMode.externalApplication);
                      if (!ok) {
                        showCustomSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
                      }
                    } catch (_) {
                      showCustomSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
                    }
                  },
                ),
              ],
            )

          ]),
        )
      ]),
    );
  }

  final Uri launchUri =  Uri(
    scheme: 'tel',
    path: Get.find<SplashController>().configModel.content!.businessPhone.toString(),
  );
  final Uri email =  Uri(
    scheme: 'mailto',
    path: Get.find<SplashController>().configModel.content!.businessEmail,
  );
}
