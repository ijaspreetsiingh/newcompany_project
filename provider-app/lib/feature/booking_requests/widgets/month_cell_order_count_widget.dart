import 'package:demandium_provider/util/core_export.dart';

/// Single day cell of the redesigned month grid.
///
/// Renders the day number with a solid ink circle when selected and up to
/// three booking-status dots underneath (confirmed / completed / cancelled).
class MonthCellOrderCountWidget extends StatelessWidget {
  final DateTime day;
  final bool isSelected;
  final bool isWithinFilterRange;
  final List<Color> dotColors;
  final VoidCallback? onTap;

  const MonthCellOrderCountWidget({
    super.key,
    required this.day,
    required this.isSelected,
    this.dotColors = const [],
    this.isWithinFilterRange = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color numberColor = !isWithinFilterRange
        ? InkColors.accent
        : isSelected ? InkColors.background : InkColors.foreground;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isWithinFilterRange ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? InkColors.foreground : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: robotoSemiBold.copyWith(
                fontSize: 12.5,
                height: 1.1,
                color: numberColor,
              ),
            ),
            SizedBox(
              height: 7,
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 2,
                  runSpacing: 0,
                  children: [
                    for (final Color color in dotColors)
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected ? InkColors.background : color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
