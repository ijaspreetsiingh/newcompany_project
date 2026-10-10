import 'package:get/get.dart';
import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:jassdbx_serviceman/feature/dashboard/model/booking_statistics_model.dart';

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

  String _formatChange(double change) {
    final bool isWhole = change == change.roundToDouble();
    final String value = isWhole ? change.round().toString() : change.toStringAsFixed(1);
    return '${change >= 0 ? '+' : ''}$value%';
  }

  @override
  void initState() {
    super.initState();
    Get.find<UserController>().getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.kBackground,
      body: RefreshIndicator(
        backgroundColor: context.kBackground,
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
                    padding: EdgeInsets.zero,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      _buildHeader(context),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildOnlineCard(context),
                            const SizedBox(height: 16),
                            _buildStatsRow(context, dashboardController),
                            const SizedBox(height: 24),
                            _buildQuickActions(context),
                            const SizedBox(height: 24),
                            _buildEarningCard(context, dashboardController),
                            const SizedBox(height: 24),
                            _buildRecentBookings(context, dashboardController),
                            const SizedBox(height: 20),
                            KButton(
                              label: 'refresh_dashboard'.tr,
                              outline: true,
                              icon: Icons.refresh_rounded,
                              onTap: _loadData,
                            ),
                            const SizedBox(height: 112),
                          ],
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: () => BottomNavScreen.onChangesIndex(3),
              borderRadius: BorderRadius.circular(kRadiusMd),
              child: Row(
                children: [
                  GetBuilder<UserController>(
                    builder: (userController) => ValueListenableBuilder<bool>(
                      valueListenable: WorkStatusService.online,
                      builder: (context, online, _) => UserAvatar(
                        imageUrl: userController.userInfo.profileImageFullPath,
                        name: userController.userInfo.firstName,
                        online: online,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _greeting(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(
                            fontSize: 11,
                            color: context.kMutedForeground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: GetBuilder<UserController>(
                                builder: (userController) {
                                  final String firstName =
                                      userController.userInfo.firstName ?? '';
                                  return Text(
                                    firstName.isNotEmpty
                                        ? firstName
                                        : 'service_man'.tr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: robotoBold.copyWith(
                                      fontSize: 16,
                                      color: context.kForeground,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: context.kMuted,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'PRO',
                                style: robotoBold.copyWith(
                                  fontSize: 9,
                                  color: context.kForeground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GetBuilder<NotificationController>(
                builder: (notificationController) => KIconButton(
                  icon: Icons.notifications_outlined,
                  showBadge: notificationController.unseenNotificationCount > 0,
                  onTap: () {
                    Get.to(const NotificationScreen());
                    notificationController.resetNotificationCount();
                  },
                ),
              ),
              const SizedBox(width: 4),
              KIconButton(
                icon: Icons.menu,
                onTap: () => BottomNavScreen.openMenu(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineCard(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: WorkStatusService.online,
      builder: (context, online, _) {
        final Color labelColor = online
            ? context.kPrimaryForeground
            : context.kPrimary;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.kPrimary,
            borderRadius: BorderRadius.circular(kRadiusMd),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'work_availability'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: 12,
                        color: context.kPrimaryForeground.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      online ? 'you_are_online'.tr : 'you_are_offline'.tr,
                      style: robotoBold.copyWith(
                        fontSize: 18,
                        color: context.kPrimaryForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: online ? context.kSuccess : context.kCard,
                borderRadius: BorderRadius.circular(kRadiusMd),
                child: InkWell(
                  borderRadius: BorderRadius.circular(kRadiusMd),
                  onTap: () => WorkStatusService.setStatus(!online),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: labelColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          online ? 'online'.tr : 'go_online'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(BuildContext context, DashboardController controller) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'assigned_booking'.tr,
            value: '${controller.cards.pendingBookings ?? 0}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            label: 'ongoing_booking'.tr,
            value: '${controller.cards.ongoingBookings ?? 0}',
            success: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            label: 'completed_booking'.tr,
            value: '${controller.cards.completedBookings ?? 0}',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'quick_actions'.tr),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionTile(
                icon: Icons.work_outline_rounded,
                label: 'requests'.tr,
                onTap: () => BottomNavScreen.onChangesIndex(1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickActionTile(
                icon: Icons.history_rounded,
                label: 'history'.tr,
                onTap: () => Get.to(() => const BookingHistoryScreen()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickActionTile(
                icon: Icons.mail_outline_rounded,
                label: 'inbox'.tr,
                onTap: () => BottomNavScreen.onChangesIndex(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickActionTile(
                icon: Icons.notifications_outlined,
                label: 'notification'.tr,
                onTap: () {
                  Get.to(const NotificationScreen());
                  Get.find<NotificationController>().resetNotificationCount();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEarningCard(BuildContext context, DashboardController controller) {
    final BookingData? thisMonth = controller.bookingStatisticsModel?.thisMonth;
    final int total = thisMonth?.total ?? 0;
    final String changeText = _formatChange(thisMonth?.change ?? 0);

    final List<FlSpot> spots = controller.monthlyChartList;
    final List<FlSpot> bars = spots.length > 8
        ? spots.sublist(spots.length - 8)
        : spots;
    double maxValue = 0;
    for (final spot in bars) {
      if (spot.y > maxValue) maxValue = spot.y;
    }

    return KCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'this_month'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: 12,
                        color: context.kMutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$total',
                      style: robotoBold.copyWith(
                        fontSize: 30,
                        color: context.kForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.kSuccessSoft,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  changeText,
                  style: robotoBold.copyWith(
                    fontSize: 12,
                    color: context.kSuccess,
                  ),
                ),
              ),
            ],
          ),
          if (bars.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < bars.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: (maxValue <= 0
                              ? 6.0
                              : (bars[i].y / maxValue) * 56)
                          .clamp(6.0, 56.0)
                          .toDouble(),
                      decoration: BoxDecoration(
                        color: i == bars.length - 1
                            ? context.kForeground
                            : context.kMuted,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentBookings(
    BuildContext context,
    DashboardController controller,
  ) {
    final List<_RecentBookingEntry> entries = [];
    for (final booking in controller.bookings) {
      final List<RepeatBooking>? repeats = booking.repeatBookingList;
      if (repeats != null && repeats.isNotEmpty) {
        for (final repeat in repeats) {
          entries.add(_RecentBookingEntry(booking, repeat));
        }
      } else {
        entries.add(_RecentBookingEntry(booking, null));
      }
    }

    final int count = entries.length < 2 ? entries.length : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'recent_bookings'.tr,
          trailing: LinkButton(
            label: 'see_all'.tr,
            onTap: () => BottomNavScreen.onChangesIndex(1),
          ),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < count; i++) ...[
          _buildBookingCard(entries[i]),
          if (i < count - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildBookingCard(_RecentBookingEntry entry) {
    final DashboardBooking booking = entry.booking;
    final RepeatBooking? repeat = entry.repeat;
    final num amount =
        repeat?.totalBookingAmount ?? booking.totalBookingAmount ?? 0;
    final String? readableId =
        repeat?.readableId ?? booking.readableId?.toString();

    return BookingCard(
      status: repeat?.bookingStatus ?? booking.bookingStatus ?? '',
      id: readableId != null ? '#$readableId' : '',
      title: _serviceTitle(booking, repeat),
      schedule: _scheduleOf(repeat, booking),
      amount: PriceConverter.convertPrice(amount.toDouble()),
      onTap: () {
        Get.toNamed(
          RouteHelper.getBookingDetailsRoute(
            bookingId: repeat?.id ?? booking.id!,
            isSubBooking: repeat != null,
          ),
        );
      },
    );
  }

  String _serviceTitle(DashboardBooking booking, RepeatBooking? repeat) {
    final List<ItemService>? repeatDetails = repeat?.details;
    if (repeatDetails != null && repeatDetails.isNotEmpty) {
      final String? name = repeatDetails.first.service?.name;
      if (name != null && name.isNotEmpty) return name;
    }
    final List<RecentOrderDetail>? details = booking.detail;
    if (details != null && details.isNotEmpty) {
      return details.first.service?.name ?? '';
    }
    return '';
  }

  String? _scheduleOf(RepeatBooking? repeat, DashboardBooking booking) {
    final List<String?> candidates = [
      repeat?.serviceSchedule,
      repeat?.createdAt,
      booking.serviceSchedule,
      booking.createdAt,
    ];
    String? raw;
    for (final candidate in candidates) {
      if (candidate != null && candidate.isNotEmpty) {
        raw = candidate;
        break;
      }
    }
    if (raw == null) return null;
    try {
      return DateConverter.dateMonthYearTime(
        DateConverter.isoUtcStringToLocalDate(raw),
      );
    } catch (_) {
      return null;
    }
  }
}

class _RecentBookingEntry {
  final DashboardBooking booking;
  final RepeatBooking? repeat;

  const _RecentBookingEntry(this.booking, this.repeat);
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: context.kInputBorder, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(kRadiusMd),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: context.kForeground),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(
                  fontSize: 11,
                  color: context.kMutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
