import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';


class ConversationListView extends StatelessWidget {
  final List<ChannelData> channelList;
  final int tabIndex;
  const ConversationListView({super.key, required this.channelList, this.tabIndex =0}) ;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConversationController>(builder: (conversationController){
      return channelList.isEmpty ?  EmptyConversationWidget(fromSearch:  conversationController.isActiveSuffixIcon && conversationController.isSearchComplete,
      ) : RefreshIndicator(

        color: context.kPrimary,
        backgroundColor: context.kCard,
        onRefresh: () async {
          conversationController.getChannelList(1,type: tabIndex == 0 ? "customer": "provider");
        },
        child: ListView.separated(
          controller: tabIndex == 0 ? Get.find<ConversationController>().channelScrollController1 : Get.find<ConversationController>().channelScrollController2,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          itemCount: channelList.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 1,
            color: context.kBorder,
          ),
          itemBuilder: (context,index){

            return  ChannelItem(
              channelData: channelList[index],
            );
          },
        ),
      );
    });
  }
}
