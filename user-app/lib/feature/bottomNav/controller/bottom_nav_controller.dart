import 'package:get/get.dart';

enum BnbItem { homePage, bookings, cart, offers, more, inbox }

class BottomNavController extends GetxController implements GetxService {
  static BottomNavController get to => Get.find();

  var currentPage = BnbItem.homePage;
  void changePage(BnbItem bnbItem, {bool shouldUpdate = true}) {
    currentPage = bnbItem;

    if (shouldUpdate) {
      update();
    }
  }

  int _currentMenuPagetndex = 0;
  int get currentMenuPagetndex => _currentMenuPagetndex;

  void updateMenuPagetndex(int index, {bool shouldUpdate = false}) {
    _currentMenuPagetndex = index;
    if (shouldUpdate) {
      update();
    }
  }

  /// Home ke category tap â†’ Services tab + us chip active
  /// categorySlug = actual category slug (not index)
  String? pendingServicesCategorySlug;
  String? pendingServicesCategoryId;
  int servicesCategoryRequestVersion = 0;

  void goToServicesTab({String? categorySlug, String? categoryId}) {
    pendingServicesCategorySlug = categorySlug;
    pendingServicesCategoryId = categoryId;
    servicesCategoryRequestVersion++;
    changePage(BnbItem.offers);
  }
}
