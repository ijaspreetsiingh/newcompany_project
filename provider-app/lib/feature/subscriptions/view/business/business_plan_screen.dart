import 'package:demandium_provider/util/core_export.dart';
import 'package:demandium_provider/feature/profile/model/provider_model.dart';
import 'package:get/get.dart';

class BusinessPlanScreen extends StatefulWidget {
  const BusinessPlanScreen({super.key});

  @override
  State<BusinessPlanScreen> createState() => _BusinessPlanScreenState();
}

class _BusinessPlanScreenState extends State<BusinessPlanScreen> {

  final tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();
    Get.find<BusinessSubscriptionController>().clearSearchController(shouldUpdate: false);
    Get.find<BusinessSubscriptionController>().getSubscriptionPackageList(reload: true);
    Get.find<UserProfileController>().getProviderInfo(reload: true);
    Get.find<BusinessSubscriptionController>().getSubscriptionTransactionList(1);
    Get.find<SplashController>().getConfigData();
    _loadTrialWidgetShow();
    _showToolTip();
  }

  Future<void> _loadTrialWidgetShow() async {
    await Get.find<UserProfileController>().trialWidgetShow(route: RouteHelper.businessPlan);
  }

  void _showToolTip() {
    int remainingDays = DateConverter.countDays(endDate : DateTime.tryParse(Get.find<UserProfileController>().providerModel?.content?.subscriptionInfo?.subscribedPackageDetails?.packageEndDate ?? "")) ;
    if((Get.find<SplashController>().configModel.content?.subscriptionDeadlineWarning ?? 0) >= remainingDays && Get.find<UserProfileController>().providerModel?.content?.subscriptionInfo?.status == "subscription_base"){
      Future.delayed(const Duration(seconds: 1), (){
        tooltipController.showTooltip();
      });
      Future.delayed(const Duration(seconds: 6), (){
        if(Get.currentRoute.contains(RouteHelper.businessPlan)){
          tooltipController.hideTooltip();
        }
      });
    }

  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        Get.find<UserProfileController>().trialWidgetShow(route: '');
        return;
      },
      child: Scaffold(
        backgroundColor: InkColors.background,
        body: SafeArea(
          child: GetBuilder<UserProfileController>(builder: (userProfileController){
            SubscriptionInfo? subscriptionInfo = userProfileController.providerModel?.content?.subscriptionInfo;

            if (subscriptionInfo == null) {
              return const Center(child: CircularProgressIndicator());
            }

            SubscribedPackageDetails? subscribedPackageDetails = subscriptionInfo.subscribedPackageDetails;

            bool isCommissionCase = subscriptionInfo.status == "commission_base" && (subscriptionInfo.totalSubscription ?? 0) == 0;

            int remainingDays = subscribedPackageDetails?.packageEndDate != null ?
            DateConverter.countDays(endDate: DateTime.tryParse(subscribedPackageDetails?.packageEndDate ?? "")) : 0;

            String? planName = subscribedPackageDetails?.packageName ?? subscriptionInfo.renewalPackageDetails?.name;

            String title = isCommissionCase ? "business_plan".tr : (planName ?? "business_plan".tr);
            String? subtitle;
            if(!isCommissionCase){
              subtitle = "$remainingDays ${'days_left'.tr}";
            }

            return Column(children: [

              InkTopBar(
                title: title,
                subtitle: subtitle,
                onBack: () => Get.back(),
              ),

              Expanded(
                child: isCommissionCase ? const CommissionInfoWidget() :
                BusinessPlanDetailsWidget(tooltipController: tooltipController),
              ),

            ]);
          }),
        ),
      ),
    );
  }
}
