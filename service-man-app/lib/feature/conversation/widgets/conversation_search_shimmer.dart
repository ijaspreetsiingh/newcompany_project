import 'package:jassdbx_serviceman/utils/core_export.dart';

class ConversationSearchShimmer extends StatelessWidget {
  const ConversationSearchShimmer({super.key,});

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(children: [

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

                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: context.kMuted, shape: BoxShape.circle),
                ),
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
