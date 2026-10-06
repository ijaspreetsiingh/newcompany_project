import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class RecentActivityCardItem extends StatelessWidget {
  final DashboardRecentActivityModel dashboardRecentActivityModel;
  final VoidCallback? onTap;
  final bool showDivider;

  const RecentActivityCardItem({
    super.key,
    required this.dashboardRecentActivityModel,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final DashboardRecentActivityModel booking = dashboardRecentActivityModel;

    String serviceName = '';
    if (booking.detail != null && booking.detail!.isNotEmpty) {
      serviceName = booking.detail!.first.service?.name ?? '';
    }

    final DateTime? createdAt = booking.createdAt == null
        ? null
        : DateConverter.isoUtcStringToLocalDate(booking.createdAt!);
    final String dateLabel = createdAt == null
        ? ''
        : DateConverter.dateStringMonthYear(createdAt, format: 'd MMM');
    final double amount =
        double.tryParse(booking.totalBookingAmount ?? '') ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: showDivider
                ?  Border(bottom: BorderSide(color: InkColors.border))
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkAvatar(name: serviceName, size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      serviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoSemiBold.copyWith(
                        fontSize: 13.5,
                        height: 1.3,
                        color: InkColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${'booking'.tr}#${booking.readableId ?? ''} · $dateLabel",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(
                        fontSize: 11.5,
                        height: 1.3,
                        color: InkColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkMoney(
                    amount,
                    style:  TextStyle(
                      fontSize: 13,
                      color: InkColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkStatusChip(status: booking.bookingStatus ?? ''),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
