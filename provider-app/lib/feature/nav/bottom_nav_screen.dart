import 'dart:ui';

import 'package:demandium_provider/feature/payement_information/controller/payment_info_controller.dart';
import 'package:demandium_provider/feature/menu/view/more_screen.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BottomNavScreen extends StatefulWidget {
  final int pageIndex;
  final bool formTutorial;

  static Future<void> loadData({int pageIndex = 0}) async {
    Get.find<DashboardController>().getDashboardData(reload: true);
    Get.find<DashboardController>().getEarningData();
    Get.find<UserProfileController>().getProviderInfo(reload: true);
    Get.find<ServiceCategoryController>().getCategoryList(
      shouldUpdate: true,
      reloadSubcategory: true,
    );
    Get.find<LocalizationController>().filterLanguage(shouldUpdate: false);
    Get.find<ConversationController>().getChannelList(1, type: "serviceman");
    Get.find<ConversationController>().getChannelList(1, type: "customer");
    Get.find<ServicemanSetupController>().getAllServicemanList(
      1,
      reload: true,
      status: 'all',
    );
    await Get.find<UserProfileController>().getProviderInfo(reload: true).then((
      isProviderModelAvailable,
    ) {
      if (Get.find<UserProfileController>().isSubscriptionRequired) {
        Get.find<BusinessSubscriptionController>().getSubscriptionPackageList();
        if (pageIndex != 1) {
          Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet();
        }
      }
      Get.find<UserProfileController>().trialWidgetShow(route: "");
    });
    Get.find<AuthController>().updateToken();
    Get.find<PaymentInfoController>().getPaymentMethods(
      isUpdate: false,
      isReload: false,
    );
  }

  const BottomNavScreen({
    super.key,
    required this.pageIndex,
    this.formTutorial = false,
  });

  @override
  BottomNavScreenState createState() => BottomNavScreenState();
}

class BottomNavScreenState extends State<BottomNavScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  List<Widget>? _screens;
  bool _canExit = GetPlatform.isWeb ? true : false;
  bool isTutorialActive = false;

  @override
  void initState() {
    super.initState();

    final bool tutorialCurrentStatus =
        Get.find<UserProfileController>()
            .providerModel
            ?.content
            ?.providerInfo!
            .tutorialData?[AppConstants.serviceSubscriptionTutorialKey]
            ?.contains('0') ??
        true;

    isTutorialActive = widget.formTutorial && tutorialCurrentStatus;

    if (!isTutorialActive) {
      BottomNavScreen.loadData(pageIndex: widget.pageIndex);
    }
    _pageIndex = widget.pageIndex;
    _pageController = PageController(initialPage: widget.pageIndex);

    Future.delayed(const Duration(seconds: 1), () {
      if (isTutorialActive) {
        Get.to(() => const AllServicesScreen(isTutorialActive: true));
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    _screens = [
      const DashBoardScreen(),
      const BookingRequestScreen(),
      const MyServicesScreen(),
      Text("more".tr),
    ];

    return CustomPopScopeWidget(
      onPopInvoked: () {
        if (_pageIndex != 0) {
          _setPage(0);
        } else {
          if (_canExit) {
            SystemNavigator.pop();
          } else {
            showCustomSnackBar(
              'back_press_again_to_exit'.tr,
              type: ToasterMessageType.info,
            );
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
          }
        }
      },
      child: Scaffold(
        backgroundColor: InkColors.background,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: InkColors.card.withValues(alpha: 0.96),
            border: Border(top: BorderSide(color: InkColors.border)),
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                  child: Row(
                    children: [
                      _getBottomNavItem(0, Icons.dashboard_outlined, 'dashboard'.tr),
                      _getBottomNavItem(1, Icons.inbox_outlined, 'requests'.tr),
                      _buildCenterFab(),
                      _getBottomNavItem(2, Icons.home_repair_service_rounded, 'my_services'.tr),
                      _getBottomNavItem(3, Icons.menu_rounded, 'more'.tr),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: GetBuilder<UserProfileController>(
          builder: (userProfileController) {
            return PageView.builder(
              controller: _pageController,
              itemCount: _screens!.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _screens![index];
              },
            );
          },
        ),
      ),
    );
  }

  /// Center "+" FAB — links to custom requests (bids) like the design.
  Widget _buildCenterFab() {
    return Expanded(
      child: GestureDetector(
        onTap: () => Get.find<BusinessSubscriptionController>()
            .openTrialEndBottomSheet()
            .then((isTrial) {
              if (isTrial) {
                if (Get.find<UserProfileController>()
                    .checkAvailableFeatureInSubscriptionPlan(featureType: 'bidding')) {
                  Get.to(() => const CustomerRequestListScreen());
                }
              }
            }),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: const Offset(0, -8),
              child: Container(
                height: 56,
                width: 56,
                decoration:  BoxDecoration(
                  color: InkColors.foreground,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x59000000),
                      blurRadius: 30,
                      offset: Offset(0, 10),
                      spreadRadius: -12,
                    ),
                  ],
                ),
                child:  Icon(Icons.add_rounded, size: 26, color: InkColors.background),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -8),
              child: const SizedBox(height: 4),
            ),
          ],
        ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    if (pageIndex == 3) {
      Get.find<UserProfileController>().trialWidgetShow(route: "show-dialog");
      Get.to(() => const MoreScreen())?.then((_) {
        Get.find<UserProfileController>().trialWidgetShow(route: "");
      });
    } else {
      setState(() {
        _pageController?.jumpToPage(pageIndex);
        _pageIndex = pageIndex;
      });
    }
  }

  /// Design tab item: icon pill + label. The active tab is filled with the
  /// ink colour so it is always clearly highlighted in both themes.
  Widget _getBottomNavItem(int index, IconData icon, String title) {
    final bool isActive = _pageIndex == index;
    final Color activeFg = InkColors.foreground;
    final Color idleFg = InkColors.mutedForeground;

    return Expanded(
      child: InkWell(
        onTap: () => _setPage(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              height: 32,
              width: isActive ? 60 : 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? activeFg : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 19,
                color: isActive ? InkColors.background : idleFg,
                weight: isActive ? 2.4 : 1.8,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                height: 1.2,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: 0.2,
                color: isActive ? activeFg : idleFg,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
