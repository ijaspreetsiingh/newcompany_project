import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';
class BusinessReportStatisticsCard2 extends StatelessWidget {
  final bool withCurrencySymbol;
  final String? icon;
  final IconData? iconData;
  final String titleAmount;
  final String title;
  final String subtitle1;
  final String subtitle2;
  final String? subtitle3;
  final String? subtitle4;
  final String subtitleAmount1;
  final String subtitleAmount2;
  final String? subtitleAmount3;
  final String? subtitleAmount4;

  const BusinessReportStatisticsCard2({
    super.key,
    this.icon,
    this.iconData,
    required this.titleAmount,
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    this.subtitle3,
    required this.subtitleAmount1,
    required this.subtitleAmount2,
    this.subtitleAmount3,
    required this.withCurrencySymbol,
    this.subtitle4,
    this.subtitleAmount4
  });

  Widget _iconTile() {
    final IconData statIcon = iconData ?? Icons.bar_chart_rounded;
    return Container(
      height: 34,
      width: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: InkColors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(statIcon, size: 17, color: InkColors.foreground),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: double.infinity,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InkColors.card,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: InkColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconTile(),
              const SizedBox(width: 12,),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      withCurrencySymbol
                          ? PriceConverter.convertPrice(double.tryParse(titleAmount))
                          : titleAmount,
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
                      maxLines: 1,
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
          const SizedBox(height: 12,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: SubTitleView(
                  amount: subtitleAmount1,
                  subTitle: subtitle1,
                  titleColor: InkColors.destructive,
                  withCurrencySymbol: withCurrencySymbol,
                ),
              ),
              Expanded(
                child: SubTitleView(
                  amount: subtitleAmount2,
                  subTitle: subtitle2,
                  titleColor: InkColors.inkSoft,
                  withCurrencySymbol: withCurrencySymbol,
                ),
              ),
              if(subtitle3!=null)
                Expanded(
                  child: SubTitleView(
                    amount: subtitleAmount3!=null?subtitleAmount3!:'0',
                    subTitle: subtitle3!,
                    titleColor: InkColors.mutedForeground,
                    withCurrencySymbol: withCurrencySymbol,
                  ),
                ),

              if(subtitle4!=null)
                Expanded(
                  child: SubTitleView(
                    amount: subtitleAmount4!=null?subtitleAmount4!:'0',
                    subTitle: subtitle4!,
                    titleColor: InkColors.foreground,
                    withCurrencySymbol: withCurrencySymbol,
                  ),
                )
            ],
          )
        ],
      ),
    );
  }
}

class SubTitleView extends StatelessWidget {
  final String amount;
  final String subTitle;
  final Color titleColor;
  final bool withCurrencySymbol;
  const SubTitleView({
    super.key,
    required this.amount,
    required this.subTitle,
    required this.titleColor,
    required this.withCurrencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              withCurrencySymbol
                  ? PriceConverter.convertPrice(double.tryParse(amount),isShowLongPrice: true)
                  :amount,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 12.5,
                height: 1.2,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: titleColor,
              ),
            ),
          ),
          const SizedBox(height: 2,),
          Text(
            subTitle.tr,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style:  TextStyle(
              fontSize: 10,
              height: 1.2,
              fontWeight: FontWeight.w500,
              color: InkColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
