import 'package:demandium_serviceman/feature/dashboard/widgets/booking_statistics_widget.dart';
import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});
  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  void _loadData() {
    Get.find<DashboardController>().getDashboardData(reload: false);
    Get.find<DashboardController>().getBookingStatisticData(isReload: true);
    Get.find<UserController>().getUserInfo();
    Get.find<DashboardController>().changeToYearlyEarnStatisticsChart(
      EarningType.monthly,
    );
    Get.find<DashboardController>().getMonthlyBookingsDataForChart(
      DateConverter.stringYear(DateTime.now()),
      DateTime.now().month.toString(),
      isRefresh: true,
    );
    Get.find<DashboardController>().getYearlyBookingsDataForChart(
      DateConverter.stringYear(DateTime.now()),
      isRefresh: true,
    );
    Get.find<NotificationController>().getNotifications(
      1,
      saveNotificationCount: false,
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning'.tr;
    if (hour < 17) return 'good_afternoon'.tr;
    return 'good_evening'.tr;
  }

  @override
  void initState() {
    super.initState();
    Get.find<UserController>().getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: MainAppBar(
        color: Theme.of(context).primaryColor,
        title: AppConstants.appName,
        titleFontSize: Dimensions.fontSizeOverLarge,
      ),
      body: RefreshIndicator(
        backgroundColor: Theme.of(context).colorScheme.surface,
        color: Theme.of(
          context,
        ).textTheme.bodyLarge!.color!.withValues(alpha: 0.6),
        onRefresh: () async {
          _loadData();
        },
        child: GetBuilder<DashboardController>(
          builder: (dashboardController) {
            return dashboardController.isLoading
                ? const DashboardTopCardShimmer()
                : ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      _buildHeroCard(context, dashboardController),
                      const SizedBox(height: 20),
                      const _QuickActionsRow(),
                      const SizedBox(height: 24),
                      const BusinessSummerySection(),
                      const SizedBox(height: 24),
                      const BookingStatisticsWidget(),
                      const SizedBox(height: 24),
                      const RecentActivitySection(),
                      const SizedBox(height: 24),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, DashboardController controller) {
    final completed = controller.cards.completedBookings ?? 0;
    final ongoing = controller.cards.ongoingBookings ?? 0;
    final assigned = controller.cards.pendingBookings ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault + 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Color.lerp(
              Theme.of(context).primaryColor,
              const Color(0xFF1E40AF),
              0.55,
            )!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.30),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -24,
            top: -34,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            right: 70,
            bottom: -48,
            child: Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeOverLarge,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall,
                        ),
                        Text(
                          'quick_overview_of_your_bookings'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusLarge,
                      ),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _heroStat('$assigned', 'assigned_booking'.tr),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                  Expanded(child: _heroStat('$ongoing', 'ongoing_booking'.tr)),
                  Container(
                    width: 1,
                    height: 36,
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                  Expanded(
                    child: _heroStat('$completed', 'completed_booking'.tr),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeExtraLarge,
            color: Colors.white,
            height: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: Colors.white.withValues(alpha: 0.85),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickAction(
          icon: Icons.calendar_month_rounded,
          label: 'requests'.tr,
          color: const Color(0xFF2563EB),
          bgColor: const Color(0xFFDBEAFE),
          onTap: () => BottomNavScreen.onChangesIndex(1),
        ),
        const SizedBox(width: 12),
        _QuickAction(
          icon: Icons.history_rounded,
          label: 'history'.tr,
          color: const Color(0xFF0EA5E9),
          bgColor: const Color(0xFFE0F2FE),
          onTap: () => BottomNavScreen.onChangesIndex(2),
        ),
        const SizedBox(width: 12),
        _QuickAction(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'inbox'.tr,
          color: const Color(0xFF22C55E),
          bgColor: const Color(0xFFECFDF5),
          onTap: () => Get.toNamed(RouteHelper.getInboxScreenRoute()),
        ),
        const SizedBox(width: 12),
        _QuickAction(
          icon: Icons.notifications_outlined,
          label: 'notification'.tr,
          color: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFFFF7ED),
          onTap: () {
            Get.to(const NotificationScreen());
            Get.find<NotificationController>().resetNotificationCount();
          },
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Theme.of(context).hintColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
