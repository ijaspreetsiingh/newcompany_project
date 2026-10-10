import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:jdds/feature/account/view/account_screen.dart';
import 'package:jdds/feature/service/view/services_tab_view.dart';
import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdds/feature/cart/controller/cart_controller.dart';

class BottomNavScreen extends StatefulWidget {
  final AddressModel ? previousAddress;
  final bool showServiceNotAvailableDialog;
  final int pagetndex;
  const  BottomNavScreen({super.key, required this.pagetndex, this.previousAddress, required this.showServiceNotAvailableDialog});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _pagetndex = 0;
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  void initState() {
    super.initState();
    _pagetndex = widget.pagetndex;

    // BookingListScreen is hosted directly in this IndexedStack, so route
    // bindings are not guaranteed to run before its initState calls Get.find.
    if (!Get.isRegistered<ServiceBookingController>()) {
      Get.put(
        ServiceBookingController(
          serviceBookingRepo: Get.find<ServiceBookingRepo>(),
        ),
        permanent: true,
      );
    }

    // Load home screen data
    HomeScreen.loadData(false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.pagetndex != 0) return;
      if (Get.find<LocationController>().getUserAddress() == null) {
        EnableLocationPopup.show(context, barrierDismissible: true);
      }
    });

    if(_pagetndex==1){
      Get.find<BottomNavController>().changePage(BnbItem.bookings, shouldUpdate: false);
    }else if(_pagetndex==2){
      Get.find<BottomNavController>().changePage(BnbItem.cart, shouldUpdate: false);
    }
    else if(_pagetndex==3){
      Get.find<BottomNavController>().changePage(BnbItem.offers, shouldUpdate: false);
    }else{
      Get.find<BottomNavController>().changePage(BnbItem.homePage, shouldUpdate: false);
    }
  }

  @override
  Widget build(BuildContext context) {

    bool isUserLoggedIn = Get.find<AuthController>().isLoggedIn();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);
    final bgColor = isDark ? const Color(0xFF0D0D0D) : Colors.white;
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);

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

              /// nest. design bottom nav - flat bar with border
              Container(
                height: 82,
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border(
                    top: BorderSide(color: borderColor, width: 1),
                  ),
                ),
                child: Row(children: [

                  _bnbItem(
                    icon: Images.home, bnbItem: BnbItem.homePage, context: context,
                    label: 'home'.tr,
                    onTap: () => Get.find<BottomNavController>().changePage(BnbItem.homePage),
                  ),

                  /// Services - inline tab
                  _bnbItem(
                    icon: '', bnbItem: BnbItem.offers, context: context,
                    label: 'services'.tr,
                    iconData: Icons.grid_view_outlined,
                    onTap: () => Get.find<BottomNavController>().changePage(BnbItem.offers),
                  ),

                  /// Bookings
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

                  /// Cart - with badge
                  _bnbItem(
                    icon: Images.cart, bnbItem: BnbItem.cart, context: context,
                    label: 'cart'.tr,
                    iconData: Icons.shopping_cart_outlined,
                    showBadge: true,
                    onTap: () => Get.toNamed(RouteHelper.getCartRoute()),
                  ),

                  /// Account tab
                  _bnbItem(
                    icon: '', bnbItem: BnbItem.more, context: context,
                    label: 'account'.tr,
                    iconData: Icons.person_outline_rounded,
                    onTap: () => Get.find<BottomNavController>().changePage(BnbItem.more),
                  ),
                ]),
              ),
            ]),
          ),
        ),

        body: GetBuilder<BottomNavController>(builder: (navController){
          return IndexedStack(
            index: _pagetndexFor(navController.currentPage),
            children: [
              HomeScreen(
                addressModel: widget.previousAddress,
                showServiceNotAvailableDialog: widget.showServiceNotAvailableDialog,
              ),
              Get.find<AuthController>().isLoggedIn()
                  ? const BookingListScreen()
                  : const SizedBox(),
              const SizedBox(),
              const ServicesTabView(),
              const AccountScreen(),
            ],
          );
        }),

      ),
    );
  }

  /// Bottom nav item - nest. design : active = pill background + inverted colors
  Widget _bnbItem({required String icon, required BnbItem bnbItem, required GestureTapCallback onTap, required String label, required BuildContext context, IconData? iconData, bool showBadge = false}) {
    return GetBuilder<BottomNavController>(builder: (bottomNavController){
      final bool isSelected = bottomNavController.currentPage == bnbItem;
      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
      final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);
      final bgColor = isDark ? const Color(0xFF0D0D0D) : Colors.white;

      return Expanded(
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 28,
                width: 38,
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: iconData != null
                          ? Icon(iconData, size: 20, color: isSelected ? bgColor : mutedColor)
                          : Image.asset(icon, width: 20, height: 20, color: isSelected ? bgColor : mutedColor),
                    ),
                    if (showBadge && !isSelected)
                      Positioned(
                        top: -3,
                        right: 1,
                        child: GetBuilder<CartController>(builder: (cartController) {
                          final cartCount = cartController.cartList?.length ?? 0;
                          if (cartCount == 0) return const SizedBox();
                          return Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: bgColor, width: 1),
                            ),
                            child: Center(
                              child: Text(
                                cartCount > 9 ? '9+' : cartCount.toString(),
                                style: GoogleFonts.dmSans(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: bgColor,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(label,
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? primaryColor : mutedColor,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    });
  }

  int _pagetndexFor(BnbItem item) {
    switch (item) {
      case BnbItem.homePage:
        return 0;
      case BnbItem.bookings:
        return 1;
      case BnbItem.cart:
        return 2;
      case BnbItem.offers:
        return 3;
      case BnbItem.more:
        return 4;
      case BnbItem.inbox:
        return 0;
    }
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
        /// Services tab - inline screen (bottom menu ke saath)
        return const ServicesTabView();
      case BnbItem.more:
        return const AccountScreen();
      case BnbItem.inbox:
        break;
    }
  }
}



