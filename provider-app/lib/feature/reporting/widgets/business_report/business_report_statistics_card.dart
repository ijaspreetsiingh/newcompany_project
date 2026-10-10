import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';
class BusinessReportStatisticsCard extends StatelessWidget {
  final IconData icon;
  final String titleAmount;
  final String title;
  const BusinessReportStatisticsCard({
    super.key,
    required this.icon,
    required this.titleAmount,
    required this.title
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: double.infinity,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InkColors.card,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: InkColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 34,
            width: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: InkColors.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: InkColors.foreground),
          ),
          const SizedBox(width: 12,),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PriceConverter.convertPrice(double.tryParse(titleAmount),isShowLongPrice: true),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:  TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 16,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: InkColors.foreground,
                  ),
                ),
                const SizedBox(height: 4,),
                Text(
                  title.tr.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:  TextStyle(
                    fontSize: 11,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                    color: InkColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
