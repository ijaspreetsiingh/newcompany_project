
import 'package:jassdbx_provider/common/widgets/custom_shimmer_widget.dart';
import 'package:jassdbx_provider/feature/payement_information/controller/payment_info_controller.dart';
import 'package:jassdbx_provider/feature/payement_information/widgets/payment_info_card.dart';
import 'package:jassdbx_provider/feature/tutorial/controller/tutorial_controller.dart';
import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class PaymentInformationScreen extends StatefulWidget {
  const PaymentInformationScreen({super.key});

  @override
  State<PaymentInformationScreen> createState() => _PaymentInformationScreenState();
}

class _PaymentInformationScreenState extends State<PaymentInformationScreen> {


  @override
  void initState() {
    super.initState();

    Get.find<PaymentInfoController>().getPaymentMethods(isUpdate: false, isReload: false);
  }

  void _onAddPaymentInfo() {
    final tutorialData = Get.find<UserProfileController>().providerModel?.content?.providerInfo?.tutorialData;

    if(tutorialData?[AppConstants.serviceAvailabilityTutorialKey]?.contains('0') ?? true) {
      Get.find<TutorialController>().updateTutorial(key: AppConstants.serviceAvailabilityTutorialKey);
    }

    Get.toNamed(RouteHelper.getAddPaymentInformationRoute());
  }

  @override
  Widget build(BuildContext context) {
    final heightSize = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: InkColors.background,
      body: SafeArea(
        bottom: false,
        child: GetBuilder<PaymentInfoController>(
          builder: (paymentInfoController) {
            final bool hasMethods = paymentInfoController.paymentMethodListModel?.content?.isNotEmpty ?? false;

            return Column(children: [

              InkTopBar(title: 'payment_information'.tr, onBack: () => Get.back()),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: InkColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: InkColors.border),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                     Icon(Icons.info_outline_rounded, size: 18, color: InkColors.mutedForeground),
                    const SizedBox(width: 10),

                    Flexible(child: Text('verify_payment_info_warning'.tr, style: robotoRegular.copyWith(
                      color: InkColors.mutedForeground,
                      fontSize: Dimensions.fontSizeSmall,
                      height: 1.45,
                    ))),
                  ]),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      InkEyebrow('payment_information'.tr),
                      const SizedBox(height: 12),

                      Expanded(
                        child: RefreshIndicator(
                          color: InkColors.foreground,
                          backgroundColor: InkColors.card,
                          onRefresh: () async => paymentInfoController.getPaymentMethods(isReload: true),
                          child: paymentInfoController.paymentMethodListModel != null ?
                          (paymentInfoController.paymentMethodListModel?.content?.isNotEmpty ?? false) ?
                          ListView.separated(
                            itemCount: paymentInfoController.paymentMethodListModel?.content?.length ?? 0,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) => PaymentInfoCard(
                              index: index,
                              paymentMethod: paymentInfoController.paymentMethodListModel?.content?[index],
                            ),
                          ) :
                          SingleChildScrollView(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                SizedBox(height: heightSize * 0.06),

                                NoDataScreen(
                                  text: 'no_payment_info_added_yet'.tr,
                                  type: NoDataType.paymentInfo,
                                ),

                                Center(
                                  child: InkPrimaryButton(
                                    label: 'add_payment_info'.tr,
                                    expanded: false,
                                    onTap: _onAddPaymentInfo,
                                  ),
                                ),
                                SizedBox(height: heightSize * 0.12),
                              ]),
                          ) :
                          CustomShimmerWidget(
                            isSliver: false,
                            child: PaymentInfoCard(index: 5, paymentMethod: null),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),

              if(hasMethods)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: InkPrimaryButton(
                    label: 'add_payment_info'.tr,
                    onTap: () => Get.toNamed(RouteHelper.getAddPaymentInformationRoute()),
                  ),
                ),
            ]);
          }
        ),
      ),
    );
  }
}
