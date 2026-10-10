import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

/// Shared booking card matching the reference `BookingCard`.
class BookingCard extends StatelessWidget {
  final String status;
  final String id;
  final String title;
  final String? customer;
  final String? schedule;
  final String? location;
  final String amount;
  final VoidCallback? onTap;

  /// When non-null and status is pending, Decline/Accept actions are shown.
  final VoidCallback? onDecline;
  final VoidCallback? onAccept;

  const BookingCard({
    super.key,
    required this.status,
    required this.id,
    required this.title,
    this.customer,
    this.schedule,
    this.location,
    required this.amount,
    this.onTap,
    this.onDecline,
    this.onAccept,
  });

  bool get _pending => status.toLowerCase() == 'pending';
  bool get _hasActions => onDecline != null && onAccept != null && _pending;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.kCard,
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: context.kBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(status: status),
                    Text(
                      id,
                      style: robotoMedium.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.kMutedForeground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: robotoBold.copyWith(fontSize: 16, color: context.kForeground),
                ),
                if (customer != null && customer!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _MetaRow(icon: Icons.person_outline_rounded, text: customer!),
                ],
                if ((schedule != null && schedule!.isNotEmpty) ||
                    (location != null && location!.isNotEmpty)) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (schedule != null && schedule!.isNotEmpty) ...[
                        Icon(Icons.calendar_today_outlined, size: 14, color: context.kMutedForeground),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            schedule!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(fontSize: 12, color: context.kMutedForeground),
                          ),
                        ),
                      ],
                      if (schedule != null &&
                          schedule!.isNotEmpty &&
                          location != null &&
                          location!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text('·', style: robotoRegular.copyWith(fontSize: 12, color: context.kMutedForeground)),
                        const SizedBox(width: 6),
                      ],
                      if (location != null && location!.isNotEmpty) ...[
                        Icon(Icons.location_on_outlined, size: 14, color: context.kMutedForeground),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(fontSize: 12, color: context.kMutedForeground),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: context.kBorder, width: 1)),
                  ),
                  child: Text(
                    amount,
                    textAlign: TextAlign.right,
                    style: robotoBold.copyWith(fontSize: 16, color: context.kForeground),
                  ),
                ),
              ],
            ),
          ),
          if (_hasActions) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: KButton(label: 'decline'.tr, outline: true, onTap: onDecline),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: KButton(label: 'accept_job'.tr, onTap: onAccept),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: context.kMutedForeground),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoRegular.copyWith(fontSize: 12, color: context.kMutedForeground),
          ),
        ),
      ],
    );
  }
}
