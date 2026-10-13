import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

/// Zone Admin (provider) ka Unsatisfied (free re-service) dashboard —
/// serviceman-wise + service-wise complaint counts + recent requests.
class UnsatisfiedDashboardScreen extends StatefulWidget {
  const UnsatisfiedDashboardScreen({super.key});

  @override
  State<UnsatisfiedDashboardScreen> createState() => _UnsatisfiedDashboardScreenState();
}

class _UnsatisfiedDashboardScreenState extends State<UnsatisfiedDashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  static const List<String> _statuses = ['all', 'requested', 'completed', 'expired'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<UnsatisfiedController>().getUnsatisfiedSummary(reload: true);
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
        Get.find<UnsatisfiedController>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkColors.background,
      body: SafeArea(
        bottom: false,
        child: GetBuilder<UnsatisfiedController>(
          builder: (controller) {
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              InkTopBar(
                title: 'unsatisfied_dashboard'.tr,
                subtitle: 'unsatisfied_dashboard_subtitle'.tr,
                onBack: () => Get.back(),
              ),

              if (controller.isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: RefreshIndicator(
                    color: InkColors.foreground,
                    backgroundColor: InkColors.card,
                    onRefresh: () => controller.getUnsatisfiedSummary(reload: true),
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        // ---- summary stats ----
                        Row(children: [
                          Expanded(
                            child: _StatCard(
                              label: 'in_window_total'.tr,
                              value: '${controller.summary['total_in_window'] ?? 0}',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              label: 'open_unsatisfied'.tr,
                              value: '${controller.summary['open'] ?? 0}',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              label: 'completed_unsatisfied'.tr,
                              value: '${controller.summary['completed'] ?? 0}',
                            ),
                          ),
                        ]),

                        const SizedBox(height: 16),

                        // ---- status filter chips ----
                        SizedBox(
                          height: 34,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _statuses.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 8),
                            itemBuilder: (_, int index) {
                              final String status = _statuses[index];
                              final bool selected = controller.selectedStatus == status;
                              return GestureDetector(
                                onTap: () => controller.getUnsatisfiedSummary(reload: true, status: status),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: selected ? InkColors.foreground : InkColors.card,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      color: selected ? InkColors.foreground : InkColors.inkLine,
                                    ),
                                  ),
                                  child: Text(
                                    status.tr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: selected ? InkColors.background : InkColors.foreground,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ---- per serviceman unsatisfied count ----
                        if (controller.servicemen.isNotEmpty) ...[
                          Text(
                            'serviceman_unsatisfied_counts'.tr,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: InkColors.foreground,
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkCard(
                            padding: EdgeInsets.zero,
                            child: Column(children: [
                              for (int i = 0; i < controller.servicemen.length; i++) ...[
                                if (i > 0) Divider(height: 1, thickness: 1, color: InkColors.border),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: Row(children: [
                                    InkAvatar(
                                      name: '${controller.servicemen[i]['name'] ?? '?'}',
                                      size: 36,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '${controller.servicemen[i]['name'] ?? ''}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: InkColors.foreground,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: InkColors.inkTint,
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(color: InkColors.inkLine),
                                      ),
                                      child: Text(
                                        '${'unsatisfied'.tr}: ${controller.servicemen[i]['unsatisfied_count'] ?? 0}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: InkColors.foreground,
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              ],
                            ]),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // ---- service-wise complaint counts ----
                        if (controller.services.isNotEmpty) ...[
                          Text(
                            'services_with_complaints'.tr,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: InkColors.foreground,
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkCard(
                            padding: EdgeInsets.zero,
                            child: Column(children: [
                              for (int i = 0; i < controller.services.length; i++) ...[
                                if (i > 0) Divider(height: 1, thickness: 1, color: InkColors.border),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: Row(children: [
                                    Icon(Icons.cleaning_services_outlined, size: 18, color: InkColors.mutedForeground),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '${controller.services[i]['service_name'] ?? ''}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: InkColors.foreground,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: InkColors.inkTint,
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(color: InkColors.inkLine),
                                      ),
                                      child: Text(
                                        '${controller.services[i]['unsatisfied_count'] ?? 0}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: InkColors.foreground,
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              ],
                            ]),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // ---- recent requests ----
                        Text(
                          'recent_unsatisfied_requests'.tr,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: InkColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (controller.requests.isEmpty)
                          InkEmptyState('no_unsatisfied_found'.tr)
                        else
                          InkCard(
                            padding: EdgeInsets.zero,
                            child: Column(children: [
                              for (int i = 0; i < controller.requests.length; i++) ...[
                                if (i > 0) Divider(height: 1, thickness: 1, color: InkColors.border),
                                _UnsatisfiedRow(
                                  data: controller.requests[i],
                                  onTap: () => _openBooking(controller.requests[i]),
                                ),
                              ],
                            ]),
                          ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
            ]);
          },
        ),
      ),
    );
  }

  void _openBooking(dynamic data) {
    final dynamic booking = data?['booking'];
    final dynamic reservice = data?['reservice_booking'];
    final dynamic target = (reservice != null && '${reservice?['id'] ?? ''}'.isNotEmpty) ? reservice : booking;
    final dynamic targetId = target?['id'];
    if (targetId == null) return;
    Get.toNamed(RouteHelper.getBookingDetailsRoute(
      bookingId: targetId.toString(),
      fromPage: "fromNotification",
    ));
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return InkCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
            color: InkColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 22,
            height: 1,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: InkColors.foreground,
          ),
        ),
      ]),
    );
  }
}

class _UnsatisfiedRow extends StatelessWidget {
  final dynamic data;
  final VoidCallback? onTap;
  const _UnsatisfiedRow({required this.data, this.onTap});

  Color get _statusColor {
    switch ('${data['status'] ?? ''}') {
      case 'completed':
        return Colors.green;
      case 'expired':
        return InkColors.destructive;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamic booking = data['booking'];
    final dynamic customer = data['customer'] ?? booking?['customer'];
    final dynamic serviceman = data['serviceman'];
    final dynamic servicemanUser = serviceman?['user'];

    final String bookingId = '${booking?['readable_id'] ?? ''}';
    final String customerName = '${customer?['first_name'] ?? ''} ${customer?['last_name'] ?? ''}'.trim();
    final String servicemanName =
        '${servicemanUser?['first_name'] ?? ''} ${servicemanUser?['last_name'] ?? ''}'.trim();
    final String status = '${data['status'] ?? 'requested'}';
    final String reason = '${data['reason'] ?? ''}';
    final String reserviceId = '${data['reservice_booking_id'] ?? ''}';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(
                bookingId.isNotEmpty ? '${'booking'.tr} #$bookingId' : 'unsatisfied'.tr,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: InkColors.foreground,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: _statusColor.withValues(alpha: 0.35)),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: _statusColor,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 5),
          Text(
            [
              if (customerName.isNotEmpty) '${'customer'.tr}: $customerName',
              if (servicemanName.isNotEmpty) '${'serviceman'.tr}: $servicemanName',
            ].join('  ·  '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.5, color: InkColors.mutedForeground),
          ),
          if (reserviceId.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              '${'re_service_booking'.tr} #$reserviceId',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: InkColors.foreground),
            ),
          ],
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              reason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, height: 1.3, color: InkColors.mutedForeground),
            ),
          ],
        ]),
      ),
    );
  }
}
