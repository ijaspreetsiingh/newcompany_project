import 'package:jassdbx_provider/feature/dashboard/widgets/dashboard_header_new.dart';
import 'package:jassdbx_provider/feature/dashboard/widgets/earning_statistics_widget.dart';
import 'package:jassdbx_provider/feature/nav/widgets/subscription_trail_end_widget.dart';
import 'package:jassdbx_provider/feature/booking_requests/view/cancelled_by_serviceman_screen.dart';
import 'package:jassdbx_provider/feature/booking_requests/controller/cancelled_booking_controller.dart';
import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});
  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  bool _ribbonDismissed = false;

  @override
  void initState() {
    super.initState();
    Get.find<DashboardController>().getEarningData();
    Get.find<MyServicesController>().ensureLoaded();
    Get.find<BusinessSettingController>().getBookingSettingsDataFromServer();
    Get.find<BusinessSettingController>()
        .getServiceAvailabilitySettingsFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        final bool subscriptionRequired =
            userProfileController.isSubscriptionRequired;

        final bool canShow =
            subscriptionRequired &&
            userProfileController.providerModel != null &&
            userProfileController.providerModel!.content != null &&
            userProfileController.providerModel!.content!.subscriptionInfo !=
                null &&
            userProfileController
                    .providerModel!
                    .content!
                    .subscriptionInfo!
                    .subscribedPackageDetails !=
                null &&
            userProfileController
                    .providerModel!
                    .content!
                    .subscriptionInfo!
                    .subscribedPackageDetails!
                    .trialDuration !=
                0 &&
            DateConverter.countDays(
                  endDate: DateTime.parse(
                    userProfileController
                        .providerModel!
                        .content!
                        .subscriptionInfo!
                        .subscribedPackageDetails!
                        .packageEndDate!,
                  ),
                ) >
                0;

        final bool showRibbon =
            canShow &&
            !userProfileController.trialWidgetNotShow &&
            !_ribbonDismissed;

        return Scaffold(
          backgroundColor: InkColors.background,
          appBar: const DashboardHeaderNew(),
          body: Stack(
            children: [
              RefreshIndicator(
                backgroundColor: Theme.of(context).primaryColor,
                onRefresh: () async {
                  await Get.find<DashboardController>().getDashboardData();
                  Get.find<DashboardController>().changeRecentActivityView(
                    status: true,
                    shouldUpdate: true,
                  );
                  Get.find<DashboardController>()
                      .changeTypeOfShowBookingStatus(
                        status: true,
                        shouldUpdate: true,
                      );
                  await Get.find<DashboardController>().getEarningData();
                  await Get.find<UserProfileController>().getProviderInfo(
                    reload: true,
                  );
                  Get.find<NotificationController>().getNotifications(
                    1,
                    saveNotificationCount: false,
                  );
                  Get.find<SplashController>().getConfigData();
                },
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: GetBuilder<DashboardController>(
                    builder: (dashboardController) {
                      final bool showActivity =
                          dashboardController
                              .dashboardRecentActivityList
                              .isNotEmpty ||
                          dashboardController
                              .dashboardCustomizedPostList
                              .isNotEmpty;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 28),

                          /// Hero — ink-surface overview card
                          const BusinessSummarySection(),
                          const SizedBox(height: 28),

                          /// 2x2 grid of API top cards
                          const DashboardStatGrid(),
                          const SizedBox(height: 28),

                          const EarningStatisticsWidget(),
                          const SizedBox(height: 28),

                          if (showActivity) ...[
                            const RecentActivitySection(),
                            const SizedBox(height: 28),
                          ],

                          const AssignedCategoriesSection(),
                          const SizedBox(height: 28),

                          const _AiAssignedBookingsBanner(),

                          // Cancelled by serviceman banner
                          _CancelledBookingsBanner(),
                          const SizedBox(height: 28),

                          const ServiceManSection(),
                          SizedBox(height: showRibbon ? 96 : 32),
                        ],
                      );
                    },
                  ),
                ),
              ),
              if (showRibbon)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: SubscriptionTrailEndWidget(
                    onDismiss: () => setState(() => _ribbonDismissed = true),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Toggle-ON bookings stay visible here until the provider assigns one
/// category-matched serviceman.
class _AiAssignedBookingsBanner extends StatefulWidget {
  const _AiAssignedBookingsBanner();

  @override
  State<_AiAssignedBookingsBanner> createState() => _AiAssignedBookingsBannerState();
}

class _AiAssignedBookingsBannerState extends State<_AiAssignedBookingsBanner> {
  bool _loading = false;
  List<BookingRequestModel> _bookings = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    _loading = true;
    try {
      final response = await Get.find<BookingRequestRepo>().getBookingRequestData(
        'pending', 1, ServiceType.all, limit: 200,
      );
      if (response.statusCode == 200 && mounted) {
        final dynamic data = response.body['content']?['bookings']?['data'];
        _bookings = (data is List ? data : const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(BookingRequestModel.fromJson)
            .where((booking) => booking.bookingStatus == 'pending'
                && (booking.assignmentMode == 'provider_manual' ||
                    booking.assignmentMode == 'manual_required'))
            .toList();
      }
    } catch (_) {
      // Keep the dashboard usable if this optional summary request fails.
    } finally {
      _loading = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bookings.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        InkWell(
          onTap: _load,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: InkColors.foreground.withValues(alpha: 0.08),
              border: Border.all(color: InkColors.foreground.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Icon(Icons.auto_awesome, color: InkColors.foreground),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${_bookings.length} ${'ai_assigned_bookings'.tr}', style: robotoSemiBold.copyWith(fontSize: 13, color: InkColors.foreground)),
                const SizedBox(height: 2),
                Text('ai_bookings_hint'.tr, style: robotoRegular.copyWith(fontSize: 11, color: InkColors.foreground.withValues(alpha: 0.8))),
              ])),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: InkColors.foreground),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        ..._bookings.map((booking) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () async {
              final id = booking.id;
              if (id == null || id.isEmpty) return;
              await Get.toNamed(RouteHelper.getIncomingBookingPopupRoute(bookingId: id));
              _load();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: InkColors.card, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.home_repair_service_outlined),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('#${booking.readableId ?? ''}', style: robotoMedium.copyWith(fontSize: 12)),
                  Text(booking.subCategory?.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(fontSize: 12, color: Theme.of(context).hintColor)),
                ])),
                const Icon(Icons.chevron_right),
              ]),
            ),
          ),
        )),
      ]),
    );
  }
}

/// Dashboard banner: sirf tab dikhega jab ek ya zyada cancelled-by-serviceman
/// bookings pending hain. Provider tap kare to CancelledByServicemanScreen khule.
class _CancelledBookingsBanner extends StatefulWidget {
  const _CancelledBookingsBanner();

  @override
  State<_CancelledBookingsBanner> createState() =>
      _CancelledBookingsBannerState();
}

class _CancelledBookingsBannerState extends State<_CancelledBookingsBanner> {
  @override
  void initState() {
    super.initState();
    // Controller already registered hoga agar screen pehle khuli ho,
    // warna register karo aur load karo
    if (!Get.isRegistered<CancelledBookingController>()) {
      Get.put(CancelledBookingController(userRepo: Get.find()));
    }
    Get.find<CancelledBookingController>().loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CancelledBookingController>(
      builder: (ctrl) {
        if (ctrl.bookings.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: () => Get.to(() => const CancelledByServicemanScreen()),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: InkColors.destructive.withValues(alpha: 0.08),
                border:
                    Border.all(color: InkColors.destructive.withValues(alpha: 0.35)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: InkColors.destructive.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.warning_amber_rounded,
                        size: 20, color: InkColors.destructive),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ctrl.bookings.length} ${'cancelled_bookings_need_assign'.tr}',
                          style: robotoSemiBold.copyWith(
                              fontSize: 13, color: InkColors.destructive),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'tap_to_assign_serviceman'.tr,
                          style: robotoRegular.copyWith(
                              fontSize: 11,
                              color: InkColors.destructive.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: InkColors.destructive),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
