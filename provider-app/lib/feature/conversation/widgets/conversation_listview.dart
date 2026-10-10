import 'package:jassdbx_provider/util/core_export.dart';

class ConversationListView extends StatelessWidget {
  final List<ChannelData> channelList;
  final ScrollController? scrollController;
  final bool fromSearch;
  const ConversationListView({
    super.key,
    required this.channelList,
    this.scrollController,
    this.fromSearch = false,
  });

  @override
  Widget build(BuildContext context) {
    if (channelList.isEmpty) {
      return ListView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyConversationWidget(fromSearch: fromSearch),
        ],
      );
    }

    return InkCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: ListView.separated(
          controller: scrollController,
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: channelList.length,
          separatorBuilder: (_, _) =>  Divider(height: 1, thickness: 1, color: InkColors.border),
          itemBuilder: (context, index) => ChannelItem(channelData: channelList[index]),
        ),
      ),
    );
  }
}
