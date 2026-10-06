import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';

class EmptyConversationWidget extends StatelessWidget {
  final bool fromSearch;
  const EmptyConversationWidget({super.key,  this.fromSearch = false}) ;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center ,children: [

      Container(
        height: 96, width: 96,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        ),
        child: Image.asset(Images.emptyConversation, width: 46,),
      ),

      const SizedBox(height: Dimensions.paddingSizeDefault,),

      Padding(padding: EdgeInsets.symmetric(horizontal: Get.width * 0.15),
        child: Text( fromSearch ? "no_conversation_found_to_your_related_search".tr : "you_don't_have_any_conversation_yet".tr,
          style: robotoMedium.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
            fontSize: Dimensions.fontSizeDefault,
          ),
          textAlign: TextAlign.center,
        ),
      ),

      SizedBox(height: MediaQuery.of(context).size.height * 0.08,)
    ]);
  }
}


