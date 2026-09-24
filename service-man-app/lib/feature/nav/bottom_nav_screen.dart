import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class BottomNavScreen extends StatefulWidget {
  final int pageIndex;
  const BottomNavScreen({super.key, required this.pageIndex});

  static final GlobalKey<BottomNavScreenState> bottomNavKey =
      GlobalKey<BottomNavScreenState>();
  static void onChangesIndex(int index) =>
      bottomNavKey.currentState?._setPage(index);

  @override
  BottomNavScreenState createState() => BottomNavScreenState();
}

class BottomNavScreenState extends State<BottomNavScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  void _loadData() async {
    await Get.find<DashboardController>().getDashboardData();
    Get.find<DashboardController>().getBookingStatisticData();
    Get.find<DashboardController>().getMonthlyBookingsDataForChart(
      DateConverter.stringYear(DateTime.now()),
      DateTime.now().month.toString(),
    );
    Get.find<DashboardController>().getYearlyBookingsDataForChart(
      DateConverter.stringYear(DateTime.now()),
    );
    Get.find<BookingRequestController>().updateBookingStatusState(
      BooingListStatus.accepted,
    );
    Get.find<BookingRequestController>().getBookingHistory('all', 1);
    Get.find<BookingRequestController>().updateBookingHistorySelectedIndex(0);
    Get.find<LocalizationController>().filterLanguage(shouldUpdate: false);
    Get.find<ConversationController>().getChannelList(1, type: "customer");
    Get.find<ConversationController>().getChannelList(1, type: "provider");
    Get.find<AuthController>().updateToken();
  }

  int _currentIndex = 0;
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.pageIndex,
    );
    _currentIndex = widget.pageIndex;

    _tabController!.addListener(() {
      setState(() {
        _currentIndex = _tabController!.index;
      });
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      onPopInvoked: () {
        if (_currentIndex != 0) {
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
        extendBody: true,
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
                        _buildNavItem(0, Icons.home_rounded, 'dashboard'.tr),
                        _buildNavItem(
                          1,
                          Icons.calendar_today_rounded,
                          'bookings'.tr,
                        ),
                        _buildNavItem(2, Icons.history_rounded, 'history'.tr),
                        _buildNavItem(3, Icons.menu_rounded, 'more'.tr),
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
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            DashBoardScreen(),
            BookingListScreen(),
            BookingHistoryScreen(),
          ],
        ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    if (pageIndex == 3) {
      Get.bottomSheet(
        const MenuScreen(),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
      );
    } else {
      _tabController!.animateTo(pageIndex);
      setState(() {
        _currentIndex = pageIndex;
      });
    }
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = _currentIndex == index;
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
                      Icon(icon, size: 20, color: Colors.white),
                      const SizedBox(height: 2),
                      Text(
                        label,
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
                    Icon(icon, size: 22, color: inactive),
                    const SizedBox(height: 4),
                    Text(
                      label,
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
