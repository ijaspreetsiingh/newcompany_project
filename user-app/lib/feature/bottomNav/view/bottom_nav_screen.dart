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

    final padding = MediaQuery.of(context).padding;
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
        floatingActionButton: (ResponsiveHelper.isDesktop(context) || MediaQuery.of(context).viewInsets.bottom != 0) ? null : InkWell(
          onTap: () => Get.toNamed(RouteHelper.getCartRoute()),
          child: Container(
            height: 70, width: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _pageIndex == 2 ? null : Get.isDarkMode ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
              gradient: _pageIndex == 2 ? const LinearGradient(
                colors: [Color(0xFFFBBB00), Color(0xFFFF833D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ) : null,
            ),
            child: CartWidget(color: Get.isDarkMode ? Theme.of(context).primaryColorLight : Colors.white, size: 35),
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,

        bottomNavigationBar: ResponsiveHelper.isDesktop(context) ? const SizedBox() : Container(
          padding: EdgeInsets.only(
            top: Dimensions.paddingSizeDefault,
            bottom: padding.bottom > 15 ? 0 : Dimensions.paddingSizeDefault,
          ),
          color:Get.isDarkMode ? Theme.of(context).cardColor.withValues(alpha: .5) : Theme.of(context).primaryColor,
          child: SafeArea(
            child: Padding( padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
              child: Row(children: [

                _bnbItem(
                  icon: Images.home, bnbItem: BnbItem.homePage, context: context,
                  onTap: () => Get.find<BottomNavController>().changePage(BnbItem.homePage),
                ),

                _bnbItem(
                  icon: Images.bookings, bnbItem: BnbItem.bookings, context: context,
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

                _bnbItem(
                  icon: '', bnbItem: BnbItem.cart, context: context,
                  onTap: () {
                    if (!isUserLoggedIn) {
                      Get.toNamed(RouteHelper.getSignInRoute(redirectUrl: RouteHelper.home));
                    } else {
                      Get.find<BottomNavController>().changePage(BnbItem.cart);
                    }
                  },
                ),

                _bnbItem(
                  icon: Images.offerMenu, bnbItem: BnbItem.offers, context: context,
                  onTap: () => Get.find<BottomNavController>().changePage(BnbItem.offers),
                ),

                _bnbItem(
                  icon: Images.menu, bnbItem: BnbItem.more,context: context,
                  onTap: () => Get.bottomSheet(const MenuScreen(),
                    backgroundColor: Colors.transparent, isScrollControlled: true,
                  ),

                ),
              ]),
            ),
          ),
        ),

        body: GetBuilder<BottomNavController>(builder: (navController){
          return _bottomNavigationView(widget.previousAddress, widget.showServiceNotAvailableDialog);
        }),

      ),
    );
  }

  Widget _bnbItem({required String icon, required BnbItem bnbItem, required GestureTapCallback onTap, context}) {
    return GetBuilder<BottomNavController>(builder: (bottomNavController){
      return Expanded(
        child: InkWell(
          onTap: bnbItem != BnbItem.cart ? onTap : null,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [

            icon.isEmpty ? const SizedBox(width: 20, height: 20) : Image.asset(icon, width: 18, height: 18,
              color: Get.find<BottomNavController>().currentPage == bnbItem ? Colors.white : Colors.white60,
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Text(bnbItem != BnbItem.cart ? bnbItem.name.tr : '',
              style: robotoRegular.copyWith( fontSize: Dimensions.fontSizeSmall,
                color: Get.find<BottomNavController>().currentPage == bnbItem ? Colors.white : Colors.white60,
              ),
            ),

          ]),
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

