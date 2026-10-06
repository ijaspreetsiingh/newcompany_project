import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class NotificationSetupShimmer extends StatelessWidget {
  const NotificationSetupShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context ,index){
        return Padding(padding: const EdgeInsets.symmetric(
          vertical: 6,
        ),
          child: Shimmer(duration: const Duration(seconds: 2), child: Container(
            height: 120, width: Get.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: InkColors.card,
              border: Border.all(color: InkColors.border),
            ),
            child:  Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12,),
              child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [

                Container(height: 18, width: 150,
                  decoration: BoxDecoration(
                      color: InkColors.accent,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                  ),
                ),
                const SizedBox(height: 10),


                Container(height: 12 , width: 200,
                  decoration: BoxDecoration(
                      color: InkColors.accent,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Container(height: 12 , width: 170,
                  decoration: BoxDecoration(
                      color: InkColors.accent,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeDefault),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                  Row(
                    children: [
                      Container(height: 18, width: 18,
                        decoration: BoxDecoration(
                            color: InkColors.accent,
                            borderRadius: BorderRadius.circular(5)
                        ),
                      ),

                      const SizedBox(width: Dimensions.paddingSizeExtraSmall,),

                      Container(height: 18, width: 80,
                        decoration: BoxDecoration(
                            color: InkColors.accent,
                            borderRadius: BorderRadius.circular(5)
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(height: 18, width: 18,
                        decoration: BoxDecoration(
                            color: InkColors.accent,
                            borderRadius: BorderRadius.circular(5)
                        ),
                      ),

                      const SizedBox(width: Dimensions.paddingSizeExtraSmall,),

                      Container(height: 18, width: 70,
                        decoration: BoxDecoration(
                            color: InkColors.accent,
                            borderRadius: BorderRadius.circular(5)
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(height: 18, width: 18,
                        decoration: BoxDecoration(
                            color: InkColors.accent,
                            borderRadius: BorderRadius.circular(5)
                        ),
                      ),

                      const SizedBox(width: Dimensions.paddingSizeExtraSmall,),

                      Container(height: 18, width: 60,
                        decoration: BoxDecoration(
                            color: InkColors.accent,
                            borderRadius: BorderRadius.circular(5)
                        ),
                      ),
                    ],
                  ),

                ]),


              ]),
            ),
          )),
        );
      },shrinkWrap: true, itemCount: 10,);
  }
}
