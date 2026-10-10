import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class EmptyConversationWidget extends StatelessWidget {
  final bool fromSearch;
  const EmptyConversationWidget({super.key,  this.fromSearch = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConversationController>(builder: (conversationController){

      final String title = fromSearch ? "no_data_found".tr : "no_conversation_found".tr;

      final String text = fromSearch &&  conversationController.tabController?.index ==0 ?
      "no_customer_found_to_your_related_search".tr : fromSearch &&  conversationController.tabController?.index == 1 ?
      "no_provider_found_to_your_related_search".tr : "you_don't_have_any_conversation_yet".tr;

      return Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center ,children: [

        EmptyState(
          icon: Icons.mail_outline_rounded,
          title: title,
          text: text,
        ),

      ]);
    });
  }
}
