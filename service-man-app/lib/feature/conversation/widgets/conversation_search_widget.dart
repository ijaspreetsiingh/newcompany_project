import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class ConversationSearchWidget extends StatelessWidget {
  const ConversationSearchWidget({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConversationController>(
      builder: (conversationController){
        return Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: context.kCard,
            borderRadius: BorderRadius.circular(kRadiusMd),
            border: Border.all(color: context.kInputBorder, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 18, color: context.kMutedForeground),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: conversationController.searchController,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: context.kForeground,
                  ),
                  cursorColor: context.kMutedForeground,
                  autofocus: false,
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.search,
                  onChanged: (text) => conversationController.showSuffixIcon(context,text),
                  onSubmitted: (text){
                    if(text.isNotEmpty) {
                      conversationController.getSearchedChannelList(query: text);
                    }
                    FocusScope.of(context).unfocus();
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'search_by_name'.tr,
                    hintStyle: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: context.kMutedForeground,
                    ),
                    suffixIcon: conversationController.isActiveSuffixIcon ?
                    InkWell(
                      onTap: () {
                        if(conversationController.searchController.text.trim().isNotEmpty) {
                          conversationController.clearSearchController();
                        }
                        FocusScope.of(context).unfocus();
                      },
                      child: Icon(
                        Icons.cancel_outlined, size: 19, color: context.kMutedForeground,
                      ),
                    ) : null,
                    suffixIconConstraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
