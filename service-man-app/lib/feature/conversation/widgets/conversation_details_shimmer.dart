import 'package:demandium_serviceman/utils/core_export.dart';

class ConversationDetailsShimmer extends StatelessWidget {
  const ConversationDetailsShimmer({super.key}) ;

  Widget _block(BuildContext context, {double? width, double height = 14}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.kMuted,
        borderRadius: BorderRadius.circular(kRadiusMd),
      ),
    );
  }

  Widget _circle(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: context.kMuted, shape: BoxShape.circle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [

      Expanded(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(children: [
              _circle(context),
              const SizedBox(width: 10),
              _block(context, width: 200, height: 44),
            ]),
            const SizedBox(height: 12),

            Row(children: [
              _circle(context),
              const SizedBox(width: 10),
              _block(context, width: 150, height: 44),
            ]),
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: _block(context, width: 200, height: 44),
            ),
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: _block(context, width: 130, height: 44),
            ),
            const SizedBox(height: 12),

            Row(children: [
              _circle(context),
              const SizedBox(width: 10),
              _block(context, width: 120, height: 120),
            ]),
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: _block(context, width: 240, height: 44),
            ),
            const SizedBox(height: 12),

            Row(children: [
              _circle(context),
              const SizedBox(width: 10),
              _block(context, width: 180, height: 44),
            ]),

          ],),
        ),
      ),

      Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.kBorder, width: 1)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: SafeArea(
          top: false,
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.kMuted,
                borderRadius: BorderRadius.circular(kRadiusMd),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: _block(context, height: 44)),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.kPrimary,
                borderRadius: BorderRadius.circular(kRadiusMd),
              ),
            ),
          ],),
        ),
      ),

    ]);
  }
}
