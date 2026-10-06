import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

/// Zone Admin (provider) ka Recheck dashboard — har serviceman ki
/// recheck count + recent recheck requests (15 din ki window).
class RecheckDashboardScreen extends StatefulWidget {
  const RecheckDashboardScreen({super.key});

  @override
  State<RecheckDashboardScreen> createState() => _RecheckDashboardScreenState();
}

class _RecheckDashboardScreenState extends State<RecheckDashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<RecheckController>().getRecheckSummary(reload: true);
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
        Get.find<RecheckController>().loadMore();
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
        child: GetBuilder<RecheckController>(
          builder: (controller) {
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              InkTopBar(
                title: 'recheck_dashboard'.tr,
                subtitle: 'recheck_dashboard_subtitle'.tr,
                onBack: () => Get.back(),
              ),

              if (controller.isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: RefreshIndicator(
                    color: InkColors.foreground,
                    backgroundColor: InkColors.card,
                    onRefresh: () => controller.getRecheckSummary(reload: true),
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        // ---- summary stats ----
                        Row(children: [
                          Expanded(
                            child: _StatCard(
                              label: 'total_15_days'.tr,
                              value: '${controller.summary['total_last_15_days'] ?? 0}',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              label: 'open_rechecks'.tr,
                              value: '${controller.summary['open'] ?? 0}',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              label: 'completed_rechecks'.tr,
                              value: '${controller.summary['completed'] ?? 0}',
                            ),
                          ),
                        ]),

                        const SizedBox(height: 20),

                        // ---- per serviceman recheck count ----
                        if (controller.servicemen.isNotEmpty) ...[
                          Text(
                            'serviceman_recheck_counts'.tr,
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
                                        '${'rechecks'.tr}: ${controller.servicemen[i]['recheck_count'] ?? 0}',
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

                        // ---- recent rechecks ----
                        Text(
                          'recent_rechecks'.tr,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: InkColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (controller.rechecks.isEmpty)
                          InkEmptyState('no_recheck_found'.tr)
                        else
                          InkCard(
                            padding: EdgeInsets.zero,
                            child: Column(children: [
                              for (int i = 0; i < controller.rechecks.length; i++) ...[
                                if (i > 0) Divider(height: 1, thickness: 1, color: InkColors.border),
                                _RecheckRow(data: controller.rechecks[i]),
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

class _RecheckRow extends StatelessWidget {
  final dynamic data;
  const _RecheckRow({required this.data});

  Color get _statusColor {
    switch ('${data['status'] ?? ''}') {
      case 'completed':
        return Colors.green;
      case 'expired':
        return InkColors.destructive;
      case 'in_progress':
        return Colors.orange;
      default:
        return InkColors.foreground;
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(
              bookingId.isNotEmpty ? '${'booking'.tr} #$bookingId' : 'recheck'.tr,
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
    );
  }
}
