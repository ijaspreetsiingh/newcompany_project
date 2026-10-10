import 'package:jassdbx_serviceman/utils/core_export.dart';

class ConversationListShimmer extends StatelessWidget {
  const ConversationListShimmer({super.key,});

  Widget _block(BuildContext context, {double? width, double height = 12}) {
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
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        _block(context, height: 44),
        const SizedBox(height: 16),

        _block(context, height: 76),
        const SizedBox(height: 20),

        Row(children: [
          Expanded(child: _block(context, height: 44)),
          const SizedBox(width: 8),
          Expanded(child: _block(context, height: 44)),
        ]),
        const SizedBox(height: 8),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 1,
            color: context.kBorder,
          ),
          itemBuilder: (context, index){
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(children: [

                _circle(context),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _block(context, width: 120, height: 12),
                    const SizedBox(height: 8),
                    _block(context, height: 10),
                  ],),
                ),

              ],),
            );
          },
        ),

      ],),
    );
  }
}
