import 'package:demandium_provider/feature/settings/business/widget/business_info_tab_item_widget.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class BusinessSettingScreen extends StatefulWidget{
  final int? tabIndex;
  const BusinessSettingScreen({super.key, this.tabIndex});

  @override
  State<BusinessSettingScreen> createState() => _BusinessSettingScreenState();
}

class _BusinessSettingScreenState extends State<BusinessSettingScreen> {

  @override
  void initState() {
    super.initState();
    // Get.find<UserProfileController>().getProviderInfo(reload: true);
    Get.find<UserProfileController>().resetImage();

    Get.find<BusinessSettingController>().initServiceLocationValue();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold( backgroundColor: InkColors.background,
      body: SafeArea(
        bottom: false,
        child: GetBuilder<BusinessSettingController>(builder: (businessSettingController){
          return DefaultTabController(length: 3, initialIndex: widget.tabIndex ?? 0, child: Column(children: [

            InkTopBar(
              title: "business_settings".tr,
              onBack: () => Get.back(),
              right: const InkIconButton(icon: Icons.more_horiz),
            ),

            const SizedBox(height: 16),

            Container(
              height: 45,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                isScrollable: true,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                  color: InkColors.foreground,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: InkColors.mutedForeground,
                labelStyle: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                unselectedLabelStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                tabAlignment: TabAlignment.start,
                dividerHeight: 0,
                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                splashBorderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                tabs: [
                  Tab(child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                      color: InkColors.secondary,
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Text("business_information".tr),
                  )),

                  Tab(child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                      color: InkColors.secondary,
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      child: Text("service_availability".tr),
                    ),
                  )),

                  Tab(child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                      color: InkColors.secondary,
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Text("bookings".tr),
                  )),
                ],
              ),
            ),

            const Expanded(child: TabBarView(
              children: [
                BusinessInfoTabItemWidget(),

                ServiceAvailabilityTabItemWidget(),

                BookingSetupTabItemWidget(),
              ],
            )),


          ]));
        }),
      ),
    );
  }
}

class SwitchButton extends StatelessWidget {
  final String titleText;
  final String tootTipText;
  final int value;
  final Function(bool) onTap;
  final JustTheController ? tooltipController;
  final bool showOutSideBorder;
  final TextStyle ? titleTextStyle;
  const SwitchButton({super.key, required this.titleText, required this.value, required this.onTap,this.tooltipController,this.showOutSideBorder = false, this.titleTextStyle, required this.tootTipText,});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: showOutSideBorder
          ? BoxDecoration(
              color: InkColors.card,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: InkColors.border),
            )
          : null,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Row(children: [

        Text( titleText.tr, style: titleTextStyle ?? robotoSemiBold.copyWith(fontSize: 14, height: 1.3, color: InkColors.foreground),),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall,),

        if(tooltipController !=null)
        JustTheTooltip( backgroundColor: Colors.black87, controller: tooltipController,
          preferredDirection: AxisDirection.down, tailLength: 14, tailBaseWidth: 20,
          content: Padding( padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child:  Text(tootTipText.tr, style: robotoRegular.copyWith(color: Colors.white,)),
          ),
          child:  InkWell( onTap: ()=> tooltipController?.showTooltip(),
            child:  Icon(Icons.info_outline_rounded, color: InkColors.mutedForeground, size: 18,),
          )
        )]),

        Switch.adaptive(
          value: value == 1,
          activeTrackColor: InkColors.foreground,
          inactiveTrackColor: InkColors.accent,
          thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
          onChanged: (bool newValue) => onTap(newValue),
        ),
      ],),
    );
  }
}
