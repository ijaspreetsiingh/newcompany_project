import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class BottomNavScreen extends StatefulWidget {
  final int pageIndex;
  const BottomNavScreen({super.key, required this.pageIndex});

  static final GlobalKey<BottomNavScreenState> bottomNavKey =
      GlobalKey<BottomNavScreenState>();
  static void onChangesIndex(int index) =>
      bottomNavKey.currentState?._setPage(index);

  /// Opens the reference "More" sheet (menu screen).
  static void openMenu() => Get.bottomSheet(
    const MenuScreen(),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
  );

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
      BooingListStatus.all,
    );
    Get.find<BookingRequestController>().getBookingHistory('all', 1);
    Get.find<BookingRequestController>().updateBookingHistorySelectedIndex(0);
    Get.find<LocalizationController>().filterLanguage(shouldUpdate: false);
    Get.find<ConversationController>().getChannelList(1, type: "customer");
    Get.find<ConversationController>().getChannelList(1, type: "provider");
    Get.find<AuthController>().updateToken();
    WorkStatusService.syncFromServer();
  }

  int _currentIndex = 0;
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
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
          decoration: BoxDecoration(
            color: context.kBackground.withValues(alpha: 0.95),
            border: Border(top: BorderSide(color: context.kBorder, width: 1)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  _buildNavItem(0, Icons.access_time_rounded, 'dashboard'.tr),
                  _buildNavItem(1, Icons.work_outline_rounded, 'bookings'.tr),
                  _buildNavItem(2, Icons.mail_outline_rounded, 'inbox'.tr),
                  _buildNavItem(3, Icons.account_circle_outlined, 'profile'.tr),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            DashBoardScreen(),
            BookingListScreen(),
            InboxScreen(),
            ProfileScreen(),
          ],
        ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    _tabController!.animateTo(pageIndex);
    setState(() {
      _currentIndex = pageIndex;
    });
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = _currentIndex == index;
    final Color activeFg = context.kPrimaryForeground;
    final Color inactive = context.kMutedForeground;

    return Expanded(
      child: InkWell(
        onTap: () => _setPage(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(kRadiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? context.kPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(kRadiusMd),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? activeFg : inactive,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: robotoMedium.copyWith(
                  fontSize: 10,
                  color: isActive ? activeFg : inactive,
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
