import 'package:demandium_provider/feature/payement_information/controller/payment_info_controller.dart';
import 'package:demandium_provider/feature/menu/view/more_screen.dart';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

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
      Get.find<BusinessSubscriptionController>().getSubscriptionPackageList();
      if (pageIndex != 1) {
        Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet();
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
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    _screens = [
      const DashBoardScreen(),
      const BookingRequestScreen(),
      ShowCaseWidget(
        builder: (context) {
          return AllServicesScreen(isTutorialActive: isTutorialActive);
        },
      ),
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
        bottomNavigationBar: Container(
          color: Colors.transparent,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Floating pill nav bar
                Container(
                  margin: const EdgeInsets.fromLTRB(
                    Dimensions.paddingSizeDefault,
                    0,
                    Dimensions.paddingSizeDefault,
                    Dimensions.paddingSizeSmall,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraSmall,
                    vertical: Dimensions.paddingSizeExtraSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Get.isDarkMode
                        ? Theme.of(context).cardColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusExtraLarge + 6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: Get.isDarkMode ? 0.35 : 0.10,
                        ),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        _getBottomNavItem(0, Images.dashboard, 'dashboard'.tr),
                        _getBottomNavItem(1, Images.requests, 'requests'.tr),
                        _getBottomNavItem(2, Images.service, 'services'.tr),
                        _getBottomNavItem(3, Images.more, 'more'.tr),
                      ],
                    ),
                  ),
                ),

                /// Home indicator line
                Container(
                  height: 4,
                  width: 110,
                  margin: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeExtraSmall + 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
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
        floatingActionButton:
            Get.find<SplashController>().configModel.content?.biddingStatus ==
                    1 &&
                Get.find<SplashController>().showCustomBookingButton
            ? GestureDetector(
                onTap: () => Get.find<BusinessSubscriptionController>()
                    .openTrialEndBottomSheet()
                    .then((isTrial) {
                      if (isTrial) {
                        if (Get.find<UserProfileController>()
                            .checkAvailableFeatureInSubscriptionPlan(
                              featureType: 'bidding',
                            )) {
                          Get.to(() => const CustomerRequestListScreen());
                        }
                      }
                    }),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: context.customThemeColors.shadow,
                    borderRadius: BorderRadius.circular(50),
                    color: Theme.of(context).cardColor,
                  ),
                  padding: const EdgeInsets.all(
                    Dimensions.paddingSizeDefault - 2,
                  ),
                  child: Image.asset(
                    Images.createPostIconWithRedDot,
                    height: 40,
                    width: 40,
                  ),
                ),
              )
            : null,
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
        if (pageIndex == 2) {
          final bool tutorialCurrentStatus =
              Get.find<UserProfileController>()
                  .providerModel
                  ?.content
                  ?.providerInfo!
                  .tutorialData?[AppConstants.serviceSubscriptionTutorialKey]
                  ?.contains('0') ??
              true;

          isTutorialActive = tutorialCurrentStatus;
        }

        _pageController?.jumpToPage(pageIndex);
        _pageIndex = pageIndex;
      });
    }
  }

  Widget _getBottomNavItem(int index, String icon, String title) {
    bool isActive = _pageIndex == index;
    final Color primary = Theme.of(context).colorScheme.primary;
    final Color inactive = Get.isDarkMode
        ? Theme.of(context).hintColor
        : const Color(0xFF9AA3B2);

    return Expanded(
      child: InkWell(
        onTap: () => _setPage(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        child: Center(
          child: isActive
              /// Active gradient chip
              ? Container(
                  height: 50,
                  width: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primary,
                        Color.lerp(primary, const Color(0xFF1E40AF), 0.45)!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icon.isEmpty
                          ? const SizedBox(width: 20, height: 20)
                          : Image.asset(
                              icon,
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: robotoBold.copyWith(
                          fontSize: 9,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              /// Inactive item
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon.isEmpty
                        ? const SizedBox(width: 22, height: 22)
                        : Image.asset(
                            icon,
                            width: 22,
                            height: 22,
                            color: inactive,
                          ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: inactive,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
