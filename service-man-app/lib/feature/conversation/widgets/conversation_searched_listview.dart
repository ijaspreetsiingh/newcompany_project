import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class ConversationSearchedListView extends StatelessWidget {
  const ConversationSearchedListView({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConversationController>(builder: (conversationController){
      return conversationController.searchedChannelList!.isEmpty ?
      const Expanded(child: Center(child: EmptyConversationWidget(fromSearch: true,))): ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: conversationController.searchedChannelList!.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          color: context.kBorder,
        ),
        itemBuilder: (context,index){
          return  ChannelItem(
            channelData:  conversationController.searchedChannelList![index],
          );
        },
      );
    });
  }
}
