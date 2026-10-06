import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class ConversationSearchWidget extends StatelessWidget {
  const ConversationSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConversationController>(
      builder: (conversationController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: InkColors.card,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: InkColors.border),
          ),
          child: Row(children: [
             Icon(Icons.search_rounded, size: 16, color: InkColors.mutedForeground),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: conversationController.searchController,
                style:  TextStyle(fontSize: 13, color: InkColors.foreground),
                cursorColor: InkColors.foreground,
                autofocus: false,
                textInputAction: TextInputAction.search,
                onChanged: (text) => conversationController.showSuffixIcon(context, text),
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) {
                    conversationController.getSearchedChannelList(query: text);
                  }
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'search'.tr,
                  hintStyle:  TextStyle(fontSize: 13, color: InkColors.mutedForeground),
                ),
              ),
            ),
            conversationController.isActiveSuffixIcon
                ? GestureDetector(
                    onTap: () {
                      if (conversationController.searchController.text.trim().isNotEmpty) {
                        conversationController.clearSearchController();
                      }
                      FocusScope.of(context).unfocus();
                    },
                    child:  Icon(Icons.cancel_rounded, size: 18, color: InkColors.mutedForeground),
                  )
                : const SizedBox.shrink(),
          ]),
        );
      },
    );
  }
}
