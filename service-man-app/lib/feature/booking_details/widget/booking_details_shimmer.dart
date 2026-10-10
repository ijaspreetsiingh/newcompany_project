import 'dart:math';
import 'package:jassdbx_serviceman/utils/core_export.dart';

class BookingDetailsShimmer extends StatelessWidget {
  const BookingDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            _block(context, height: 170, width: double.infinity),
            const SizedBox(height: 16),

            _block(context, height: 130, width: double.infinity),
            const SizedBox(height: 16),

            _block(context, height: 110, width: double.infinity),
            const SizedBox(height: 16),

            _block(context, height: 130, width: double.infinity),
            const SizedBox(height: 16),

            Row(children: [
              Expanded(child: _block(context, height: 48, width: double.infinity)),
              const SizedBox(width: 12),
              Expanded(child: _block(context, height: 48, width: double.infinity)),
            ]),
            const SizedBox(height: 16),

            _block(context, height: 220, width: double.infinity),

          ]),
        ),
      ),
    );
  }

  Widget _block(BuildContext context, {required double height, double? width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: context.kMuted,
        borderRadius: BorderRadius.circular(kRadiusMd),
      ),
    );
  }
}

class HorizontalRow extends StatelessWidget {
  const HorizontalRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    int randomForStart = Random().nextInt(50)+100;
    int randomForLast = Random().nextInt(20)+50;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Container(width: randomForStart.toDouble(),
          height: Dimensions.paddingSizeSmall,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadiusSm),
            color: context.kMuted,
          ),
        ),

        Container(width: randomForLast.toDouble(), height: Dimensions.paddingSizeSmall,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadiusSm),
            color: context.kMuted,
          ),
        ),


      ],);
  }
}
