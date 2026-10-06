import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class NotificationSettingScreen extends StatefulWidget{
  const NotificationSettingScreen({super.key});

  @override
  State<NotificationSettingScreen> createState() => _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {

    NotificationSetupController controller = Get.find<NotificationSetupController>();
    controller.clearSearchController(shouldUpdate: false);
    controller.getNotificationSetupList(type: "provider");
    controller.getNotificationSetupList(type: "serviceman");
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<NotificationSetupController>(builder: (businessSettingController){
      return Scaffold( backgroundColor: InkColors.background,

        body: SafeArea(
          bottom: false,
          child: Column(children: [

            InkTopBar(
              title: "notification_channel_setup".tr,
              onBack: () => Get.back(),
              right: InkIconButton(
                icon: Icons.search_rounded,
                onTap: () => _searchFocusNode.requestFocus(),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              height: 45,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration:  BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: InkColors.border,
                        width: 1,
                    )
                ),
              ),
              child: TabBar(
                unselectedLabelColor: InkColors.mutedForeground,
                indicatorColor: InkColors.foreground,
                indicatorWeight: 2,
                labelColor: InkColors.foreground,
                labelStyle:  robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                labelPadding: EdgeInsets.zero,
                controller: businessSettingController.tabController,
                tabs:  [
                  SizedBox(
                    width: MediaQuery.of(context).size.width* .5,
                    child:Tab(text: "notification_for_you".tr),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*.4,
                    child: Tab(text: "serviceman".tr),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12,),
            NotificationSetupSearchWidget(
              tabController: businessSettingController.tabController,
              focusNode: _searchFocusNode,
            ),

            const SizedBox(height: 12,),

            Expanded(
              child: TabBarView(
                controller: businessSettingController.tabController,
                children: const [
                  ProviderNotificationSetup(),
                  ServicemanNotificationSetup(),
                ],
              ),
            ),
          ]),
        ),
      );
    });
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
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [ Row(children: [

        Text( titleText.tr, style: titleTextStyle ?? robotoSemiBold.copyWith(fontSize: 14, height: 1.3, color: InkColors.foreground),),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall,),

        if(tooltipController !=null)
        JustTheTooltip( backgroundColor: Colors.black87, controller: tooltipController,
          preferredDirection: AxisDirection.down, tailLength: 14, tailBaseWidth: 20,
          content: Padding( padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child:  Text(tootTipText.tr, style: robotoRegular.copyWith(color: Colors.white,)),
          ),
          child:  InkWell( onTap: ()=> tooltipController?.showTooltip(),
            child: Icon(Icons.info_outline_rounded, color: InkColors.mutedForeground, size: 18,),
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
