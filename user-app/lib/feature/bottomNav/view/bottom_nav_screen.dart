import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';

class BottomNavScreen extends StatefulWidget {
  final AddressModel ? previousAddress;
  final bool showServiceNotAvailableDialog;
  final int pageIndex;
  const  BottomNavScreen({super.key, required this.pageIndex, this.previousAddress, required this.showServiceNotAvailableDialog});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _pageIndex = 0;
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.pageIndex;

    if(_pageIndex==1){
      Get.find<BottomNavController>().changePage(BnbItem.bookings, shouldUpdate: false);
    }else if(_pageIndex==2){
      Get.find<BottomNavController>().changePage(BnbItem.cart, shouldUpdate: false);
    }
    else if(_pageIndex==3){
      Get.find<BottomNavController>().changePage(BnbItem.offers, shouldUpdate: false);
    }else{
      Get.find<BottomNavController>().changePage(BnbItem.homePage, shouldUpdate: false);
    }
  }

  @override
  Widget build(BuildContext context) {

    bool isUserLoggedIn = Get.find<AuthController>().isLoggedIn();

    return CustomPopWidget(
      isExit: ResponsiveHelper.isWeb(),
      onPopInvoked: () {
        if (Get.find<BottomNavController>().currentPage != BnbItem.homePage) {
          Get.find<BottomNavController>().changePage(BnbItem.homePage);
        } else {
          if (_canExit) {
            if(!GetPlatform.isWeb) {
              SystemNavigator.pop();
            }
          } else {
            customSnackBar('back_press_again_to_exit'.tr, type : ToasterMessageType.info);
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
          }
        }
      },

      child: Scaffold(
        bottomNavigationBar: ResponsiveHelper.isDesktop(context) ? const SizedBox() : Container(
          color: Colors.transparent,
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              /// Floating rounded pill bar - SS layout
              Container(
                margin: const EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeExtraSmall,
                  vertical: Dimensions.paddingSizeExtraSmall,
                ),
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? Theme.of(context).cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge + 6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: Get.isDarkMode ? 0.3 : 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 56,
                  child: Row(children: [

                    _bnbItem(
                      icon: Images.home, bnbItem: BnbItem.homePage, context: context,
                      label: 'home'.tr,
                      onTap: () => Get.find<BottomNavController>().changePage(BnbItem.homePage),
                    ),

                    _bnbItem(
                      icon: Images.bookings, bnbItem: BnbItem.bookings, context: context,
                      label: 'bookings'.tr,
                      onTap: () {
                        if (!isUserLoggedIn && Get.find<SplashController>().configModel.content?.guestCheckout == 1) {
                          Get.toNamed(RouteHelper.getTrackBookingRoute());
                        } else  if(!isUserLoggedIn){
                          Get.toNamed(RouteHelper.getBookingScreenRoute(true));
                        } else {
                          Get.find<BottomNavController>().changePage(BnbItem.bookings);
                        }
                      },
                    ),

                    /// Cart - normal option like others (SS layout)
                    _bnbItem(
                      icon: Images.cart, bnbItem: BnbItem.cart, context: context,
                      label: 'cart'.tr,
                      iconData: Icons.shopping_cart_outlined,
                      onTap: () => Get.toNamed(RouteHelper.getCartRoute()),
                    ),

                    _bnbItem(
                      icon: Images.offerMenu, bnbItem: BnbItem.offers, context: context,
                      label: 'offers'.tr,
                      onTap: () => Get.find<BottomNavController>().changePage(BnbItem.offers),
                    ),

                    _bnbItem(
                      icon: Images.menu, bnbItem: BnbItem.more, context: context,
                      label: 'more'.tr,
                      onTap: () => Get.bottomSheet(const MenuScreen(),
                        backgroundColor: Colors.transparent, isScrollControlled: true,
                      ),
                    ),
                  ]),
                ),
              ),

              /// Home indicator line - SS layout
              Container(
                height: 4, width: 110,
                margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall + 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ]),
          ),
        ),

        body: GetBuilder<BottomNavController>(builder: (navController){
          return _bottomNavigationView(widget.previousAddress, widget.showServiceNotAvailableDialog);
        }),

      ),
    );
  }

  /// Bottom nav item - SS layout : active = gradient rounded chip with white icon+label
  Widget _bnbItem({required String icon, required BnbItem bnbItem, required GestureTapCallback onTap, required String label, required BuildContext context, IconData? iconData}) {
    return GetBuilder<BottomNavController>(builder: (bottomNavController){
      final bool isSelected = bottomNavController.currentPage == bnbItem;
      final Color activeColor = Theme.of(context).colorScheme.primary;
      final Color inactiveColor = Get.isDarkMode
          ? Theme.of(context).disabledColor
          : const Color(0xFFA6A6A6);

      return Expanded(
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          child: Center(
            child: isSelected
                ? /// Active gradient chip - SS exact
                Container(
                    height: 52,
                    width: 66,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [activeColor, Color.lerp(activeColor, const Color(0xFFE65100), 0.35)!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      iconData != null
                          ? Icon(iconData, size: 20, color: Colors.white)
                          : Image.asset(icon, width: 20, height: 20, color: Colors.white),
                      const SizedBox(height: 2),
                      Text(label,
                        style: robotoBold.copyWith(
                          fontSize: 9,
                          color: Colors.white,
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ]),
                  )
                : /// Inactive item - SS exact
                Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                    iconData != null
                        ? Icon(iconData, size: 22, color: inactiveColor)
                        : Image.asset(icon, width: 22, height: 22, color: inactiveColor),
                    const SizedBox(height: 4),
                    Text(label,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: inactiveColor),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ]),
          ),
        ),
      );
    });
  }

  dynamic _bottomNavigationView(AddressModel? previousAddress, bool showServiceNotAvailableDialog) {
    PriceConverter.getCurrency();
    switch (Get.find<BottomNavController>().currentPage) {
      case BnbItem.homePage:
        return HomeScreen(addressModel: previousAddress, showServiceNotAvailableDialog: showServiceNotAvailableDialog,);
      case BnbItem.bookings:
        if (!Get.find<AuthController>().isLoggedIn()) {
          break;
        } else {
          return const BookingListScreen();
        }
      case BnbItem.cart:
        if (!Get.find<AuthController>().isLoggedIn()) {
          break;
        } else {
          return Get.toNamed(RouteHelper.getCartRoute());
        }
      case BnbItem.offers:
        return const OfferScreen();
      case BnbItem.more:
        break;
    }
  }
}
