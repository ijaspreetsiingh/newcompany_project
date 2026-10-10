import 'package:jassdbx_provider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:jassdbx_provider/util/core_export.dart';
import 'package:jassdbx_provider/feature/profile/model/provider_model.dart';
import 'package:get/get.dart';


class BusinessPlanDetailsWidget extends StatelessWidget {
  final JustTheController? tooltipController;
  const BusinessPlanDetailsWidget({super.key, this.tooltipController});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<BusinessSubscriptionController>(builder: ( businessSubscriptionController){
      return GetBuilder<UserProfileController>(builder: (userProfileController){

        SubscriptionInfo? subscriptionInfo = userProfileController.providerModel?.content?.subscriptionInfo;

        if(subscriptionInfo == null){
          return const SizedBox();
        }

        SubscribedPackageDetails? subscribedPackageDetails = subscriptionInfo.subscribedPackageDetails;
        bool isCommissionPlan = subscriptionInfo.status == "commission_base";

        int remainingDays = subscribedPackageDetails?.packageEndDate != null ?
        DateConverter.countDays(endDate: DateTime.tryParse(subscribedPackageDetails?.packageEndDate ?? "")) : 0;

        bool showWarningTooltip = (Get.find<SplashController>().configModel.content?.subscriptionDeadlineWarning ?? 0) >= remainingDays;

        bool showCancelAction = subscriptionInfo.status == "subscription_base" && subscribedPackageDetails != null &&
            subscribedPackageDetails.isCanceled == 0 && remainingDays > 0;

        List<SubscriptionPackage> packages = (businessSubscriptionController.packageSubscriptionModel?.subscriptionPackages ?? [])
            .where((package) => package.id != "0").toList();

        String? currentPackageId = subscriptionInfo.status == "subscription_base" ? subscribedPackageDetails?.subscriptionPackageId : null;

        SubscriptionPackage? currentPackage;
        for (SubscriptionPackage package in packages) {
          if (currentPackageId != null && package.id == currentPackageId) {
            currentPackage = package;
          }
        }

        List<Widget> planCards = [];

        if(!isCommissionPlan){

          if(subscribedPackageDetails != null && currentPackageId != null && currentPackage == null){

            int duration = (subscribedPackageDetails.packageStartDate != null && subscribedPackageDetails.packageEndDate != null) ?
            DateConverter.countDays(
              dateTime: DateTime.tryParse(subscribedPackageDetails.packageStartDate ?? ""),
              endDate: DateTime.tryParse(subscribedPackageDetails.packageEndDate ?? ""),
            ) : subscriptionInfo.renewalPackageDetails?.duration ?? 0;

            planCards.add(PlanCardView(
              isCurrent: true,
              name: subscribedPackageDetails.packageName ?? "",
              price: (subscribedPackageDetails.packagePrice ?? 0) - (subscribedPackageDetails.vatAmount ?? 0),
              duration: duration,
              featureList: subscribedPackageDetails.featureList,
              featureLimit: subscribedPackageDetails.featureLimit,
              warning: showWarningTooltip ? WarningTooltipWidget(tooltipController: tooltipController, subscriptionDetails: subscribedPackageDetails) : null,
              onAction: (){
                showCustomBottomSheet(child: const ChangeBusinessPlanBottomSheet());
              },
              onCancelAction: showCancelAction ? () => _showCancelDialog(context, businessSubscriptionController, subscribedPackageDetails, remainingDays) : null,
            ));
          }

          if(currentPackage != null){
            planCards.add(PlanCardView(
              isCurrent: true,
              name: currentPackage.name ?? "",
              price: currentPackage.price,
              duration: currentPackage.duration,
              featureList: currentPackage.featureList,
              featureLimit: currentPackage.featureLimit,
              warning: showWarningTooltip ? WarningTooltipWidget(tooltipController: tooltipController, subscriptionDetails: subscribedPackageDetails) : null,
              onAction: (){
                showCustomBottomSheet(child: const ChangeBusinessPlanBottomSheet());
              },
              onCancelAction: showCancelAction ? () => _showCancelDialog(context, businessSubscriptionController, subscribedPackageDetails, remainingDays) : null,
            ));
          }

          for (SubscriptionPackage package in packages) {
            if(currentPackageId != null && package.id == currentPackageId) continue;
            planCards.add(PlanCardView(
              name: package.name ?? "",
              price: package.price,
              duration: package.duration,
              featureList: package.featureList,
              featureLimit: package.featureLimit,
              onAction: (){
                showCustomBottomSheet(child: const ChangeBusinessPlanBottomSheet());
              },
            ));
          }
        }

        return RefreshIndicator(
          onRefresh: () async {
            userProfileController.getProviderInfo(reload: true);
            businessSubscriptionController.clearSearchController();
            await businessSubscriptionController.getSubscriptionTransactionList(1);
          },
          child: ListView(
            controller: businessSubscriptionController.transactionList != null ? businessSubscriptionController.scrollController : null,
            physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: 40),
            children: [

              if(!isCommissionPlan)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: planCards.isNotEmpty ? Column(children: [
                    for (int i = 0; i < planCards.length; i++) ...[
                      if (i > 0) const SizedBox(height: Dimensions.paddingSizeDefault),
                      planCards[i],
                    ],
                  ]) : InkEmptyState('no_subscription_plan_available_at_this_moment'.tr),
                ),

              if(isCommissionPlan)
                _CommissionInfoCard(commissionStatus: userProfileController.providerModel?.content?.providerInfo?.commissionStatus),

              const SizedBox(height: 24),

              const SubscriptionTransactionListScreen(),

            ],
          ),
        );
      });
    });
  }

  void _showCancelDialog(BuildContext context, BusinessSubscriptionController businessSubscriptionController, SubscribedPackageDetails subscribedPackageDetails, int remainingDays){
    showCustomBottomSheet(child: CustomBottomSheetWidget(
      icon: Images.cancelDialogIcon,
      title: 'are_you_sure'.tr,
      buttonText: "cancel",
      subTitle : '${'if_you_cancel_the_subscription_after'.tr} $remainingDays ${'days_you_will_no_longer_be_able_to_run_the_business_before_subscribe_to_a_new_plan'.tr}',
      onTap : ()  async  {

        showCustomDialog(child: const CustomLoader());
        ResponseModel response = await businessSubscriptionController.cancelSubscription(packageId: subscribedPackageDetails.subscriptionPackageId!);
        Get.back();
        Get.back();
        if(response.isSuccess!){
          showCustomSnackBar(response.message, type: ToasterMessageType.success);
        }else{
          showCustomSnackBar(response.message);
        }
      },
    ));
  }
}


/// Commission based provider — current plan card (shown when the provider already has subscription history).
class _CommissionInfoCard extends StatelessWidget {
  final int? commissionStatus;
  const _CommissionInfoCard({this.commissionStatus});

  @override
  Widget build(BuildContext context) {

    String commission = commissionStatus == 1 ?
    Get.find<UserProfileController>().providerModel?.content?.providerInfo?.commissionPercentage?.toString() ?? "" :
    Get.find<SplashController>().configModel.content?.defaultCommission ?? "";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: InkCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Text("commission_base".tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: InkColors.foreground)),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text("$commission % ", style: displayBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: InkColors.foreground)),
            Flexible(child: Text('commission_per_booking_order'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: InkColors.mutedForeground))),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Text(
            "${'provider_will_pay'.tr} $commission% ${'commission_to'.tr} ${Get.find<SplashController>().configModel.content?.businessName} ${'from_each_order_You_will_get_access_of_all'.tr}",
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: InkColors.inkSoft, height: 1.6),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          InkSecondaryButton(
            label: "change_business_plan".tr,
            onTap: (){
              showCustomBottomSheet(child: const ChangeBusinessPlanBottomSheet(showCommissionCard: false,));
            },
          ),

        ]),
      ),
    );
  }
}


/// ---------------------------------------------------------------------------
/// Plan card — current plan renders on `ink-surface` (dark), others on `ink-card`.
/// ---------------------------------------------------------------------------
class PlanCardView extends StatelessWidget {
  final String name;
  final double? price;
  final int? duration;
  final List<String>? featureList;
  final FeatureLimit? featureLimit;
  final bool isCurrent;
  final VoidCallback onAction;
  final VoidCallback? onCancelAction;
  final Widget? warning;

  const PlanCardView({
    super.key, required this.name, this.price, this.duration, this.featureList, this.featureLimit,
    this.isCurrent = false, required this.onAction, this.onCancelAction, this.warning,
  });

  String _featureText(String feature){
    String label = feature == "category" ? "subcategory's_subscription".tr : feature.tr;
    if(feature == "booking" || feature == "category"){
      String? raw = feature == "booking" ? featureLimit?.booking : featureLimit?.category;
      int? limit = int.tryParse(raw ?? "");
      return "${limit ?? "unlimited".tr} $label";
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {

    final Color textColor = isCurrent ? Colors.white : InkColors.foreground;
    final Color mutedColor = isCurrent ? Colors.white.withValues(alpha: 0.6) : InkColors.mutedForeground;
    final Color checkColor = isCurrent ? Colors.white : InkColors.foreground;

    Widget content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(
                child: InkEyebrow(isCurrent ? "current_plan".tr : "package".tr, color: isCurrent ? Colors.white.withValues(alpha: 0.55) : InkColors.mutedForeground),
              ),
              if(warning != null) ...[const SizedBox(width: 6), warning!],
            ]),
            const SizedBox(height: 4),
            Text(name, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: displayBold.copyWith(fontSize: 18, height: 1.15, letterSpacing: -0.4, color: textColor),
            ),
          ]),
        ),

        const SizedBox(width: Dimensions.paddingSizeSmall),

        Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          InkMoney(price ?? 0, style: TextStyle(fontSize: 24, height: 1.1, color: textColor)),
          if(duration != null)
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text("/$duration ${'days'.tr}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: mutedColor)),
            ),
        ]),
      ]),

      if(featureList != null && featureList!.isNotEmpty) ...[
        const SizedBox(height: Dimensions.paddingSizeDefault),
        for (int i = 0; i < featureList!.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.check_rounded, size: 14, color: checkColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_featureText(featureList![i]), maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, height: 1.4, color: textColor),
              ),
            ),
          ]),
        ],
      ],

      const SizedBox(height: 20),

      GestureDetector(
        onTap: onAction,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isCurrent ? Colors.white.withValues(alpha: 0.2) : InkColors.foreground,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            isCurrent ? "renew_plan".tr : "upgrade".tr,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isCurrent ? Colors.white : InkColors.background),
          ),
        ),
      ),

      if(onCancelAction != null) ...[
        const SizedBox(height: Dimensions.paddingSizeSmall),
        GestureDetector(
          onTap: onCancelAction,
          child: Center(
            child: Text("cancel_subscription".tr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: InkColors.destructive)),
          ),
        ),
      ],

    ]);

    return isCurrent ? InkSurface(child: content) : InkCard(padding: const EdgeInsets.all(20), child: content);
  }
}
