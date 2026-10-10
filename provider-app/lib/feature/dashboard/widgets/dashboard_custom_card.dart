import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class DashboardStatGrid extends StatelessWidget {
  const DashboardStatGrid({super.key});

  static String _indianGrouping(num value) {
    final bool negative = value.isNegative;
    final double v = value.abs().toDouble();
    final bool isInt = v == v.roundToDouble();
    final String s = isInt ? v.round().toString() : v.toStringAsFixed(2);

    String whole;
    String dec = '';
    if (isInt) {
      whole = s;
    } else {
      final int idx = s.indexOf('.');
      whole = s.substring(0, idx);
      dec = s.substring(idx);
    }

    String grouped;
    if (whole.length <= 3) {
      grouped = whole;
    } else {
      final String last3 = whole.substring(whole.length - 3);
      String rest = whole.substring(0, whole.length - 3);
      final List<String> buffer = <String>[];
      while (rest.length > 2) {
        buffer.insert(0, rest.substring(rest.length - 2));
        rest = rest.substring(0, rest.length - 2);
      }
      if (rest.isNotEmpty) buffer.insert(0, rest);
      grouped = '${buffer.join(',')},$last3';
    }
    return '${negative ? '-' : ''}$grouped$dec';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        final topCards = dashboardController.dashboardTopCards;

        if (topCards == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 96,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(4, (_) => _buildShimmer(context)),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 96,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              InkStat(
                label: 'total_earning'.tr,
                value: '₹${_indianGrouping(topCards.totalEarning ?? 0)}',
              ),
              InkStat(
                label: 'subscribed_services'.tr,
                value: '${topCards.totalSubscribedServices ?? 0}',
              ),
              InkStat(
                label: 'serviceman'.tr,
                value: '${topCards.totalServiceMan ?? 0}',
              ),
              InkStat(
                label: 'total_booking'.tr,
                value: '${topCards.totalBookingServed ?? 0}',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: InkColors.secondary,
        borderRadius: BorderRadius.circular(14.4),
      ),
    );
  }
}
