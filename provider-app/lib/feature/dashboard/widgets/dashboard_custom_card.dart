import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class TopCardItem extends StatelessWidget {
  final Color cardColor;
  final String amount;
  final String title;
  final double? height;
  final String iconData;
  final Color? curveColor;
  const TopCardItem({super.key,this.curveColor,required this.amount,required this.title,required this.cardColor,this.height,required this.iconData});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: height ,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cardColor,
              Color.lerp(cardColor, Colors.black, 0.18)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: cardColor.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Stack(children: [
            Positioned(
              right: -22, top: -26,
              child: Container(
                height: 84, width: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(
              right: 34, bottom: -34,
              child: Container(
                height: 64, width: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall + 2, vertical: Dimensions.paddingSizeSmall),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(amount,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall + 1),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(iconData, height: 16, width: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
                  Text(title,style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall,color: Colors.white.withValues(alpha: 0.92)),
                    textDirection: TextDirection.ltr, maxLines: 2, overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}
