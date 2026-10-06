import 'package:get/get.dart';
import 'package:jdds/feature/home/widget/nest_home_widgets.dart';
import 'package:jdds/feature/home/widget/all_services_vertical_list.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdds/util/core_export.dart';

class HomeScreen extends StatefulWidget {
  static Future<void> loadData(bool reload, {int availableServiceCount = 1}) async {
    if(availableServiceCount==0){
      Get.find<BannerController>().getBannerList(reload);
    }else{
      await Future.wait([
        Get.find<ServiceController>().getRecommendedSearchList(),
        Get.find<BannerController>().getBannerList(reload),
        Get.find<CategoryController>().getCategoryList(reload),
        Get.find<ServiceController>().getPopularServiceList(1,reload),
        Get.find<AdvertisementController>().getAdvertisementList(reload),
      ]);

      Future.wait([
        Get.find<ServiceController>().getAllServiceList(1,reload),
        Get.find<ProviderBookingController>().getProviderList(1,reload),
        Get.find<NearbyProviderController>().getProviderList(1,reload),
        Get.find<CampaignController>().getCampaignList(reload),
        Get.find<ServiceController>().getRecommendedServiceList(1, reload),
        Get.find<CheckOutController>().getOfflinePaymentMethod(false, shouldUpdate: false),
        Get.find<ServiceController>().getFeatherCategoryList(reload),
        if(Get.find<AuthController>().isLoggedIn())  Get.find<AuthController>().updateToken(),
        if(Get.find<AuthController>().isLoggedIn())  Get.find<ServiceController>().getRecentlyViewedServiceList(1,reload),
      ]);

      Get.find<BookingDetailsController>().manageDialog();
    }
  }

  final AddressModel? addressModel;
  final bool showServiceNotAvailableDialog;
  const HomeScreen({super.key, this.addressModel, required this.showServiceNotAvailableDialog});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<RadiusSearchController>()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(Get.find<RadiusSearchController>().checkAvailabilityAndPrompt());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Get.find<BannerController>().setCurrentIndex(0, false);
    
    return GetBuilder<ServiceController>(builder: (serviceController) {
      bool isAvailableService = serviceController.popularServiceList != null && serviceController.popularServiceList!.isNotEmpty;
      
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: isAvailableService ? _buildHome(context) : const ServiceNotAvailableScreen(),
      );
    });
  }

  Widget _buildHome(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NestHomeHeader(),
          const NestGreetingHeader(),
          _buildSearchBox(context),
          const SizedBox(height: 16),
          const CategoryView(),
          const SizedBox(height: 20),
          GetBuilder<ServiceController>(builder: (serviceController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: NestHeroBanner(serviceList: serviceController.popularServiceList),
            );
          }),
          const SizedBox(height: 20),
          GetBuilder<ServiceController>(builder: (serviceController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: NestPopularRows(serviceList: serviceController.popularServiceList),
            );
          }),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Why choose Jass', style: robotoBold.copyWith(fontSize: 16)),
                const SizedBox(height: 12),
                const NestTrustBadges(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSpecialOfferBanner(context),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('All services', style: robotoBold.copyWith(fontSize: 16)),
                InkWell(
                  onTap: () => Get.toNamed(RouteHelper.allServiceScreenRoute('home')),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('See all', style: robotoMedium.copyWith(fontSize: 12, color: primaryAccent)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14, color: primaryAccent),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GetBuilder<ServiceController>(builder: (serviceController) {
            return serviceController.allService != null && serviceController.allService!.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    child: AllServicesVerticalList(serviceList: serviceController.allService),
                  )
                : const SizedBox();
          }),
          const SizedBox(height: 24),
        ],
      ),
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color fillColor = isDark ? const Color(0xFF262626) : const Color(0xFFF6F6F6);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);
    final Color mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);

    return GestureDetector(
      onTap: () => Get.toNamed(RouteHelper.allServiceScreenRoute('home')),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        height: 48,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
        ),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.search_outlined, size: 18, color: mutedColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'search_services'.tr,
                style: robotoRegular.copyWith(fontSize: 13, color: mutedColor),
              ),
            ),
            Icon(Icons.tune_rounded, size: 18, color: mutedColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialOfferBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.black;
    final textColor = Colors.white;

    return GestureDetector(
      onTap: () => Get.toNamed(RouteHelper.getCouponRoute()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.local_offer_rounded, color: textColor, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Special Offer',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      'Current Offers',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(Icons.arrow_forward_rounded, color: textColor, size: 20),
          ],
        ),
      ),
    );
  }
}
