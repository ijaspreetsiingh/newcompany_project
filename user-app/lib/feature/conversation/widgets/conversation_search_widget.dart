import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';

class ConversationSearchWidget extends StatelessWidget {
  const ConversationSearchWidget({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return Padding( padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: GetBuilder<ConversationController>(
        builder: (conversationController){
          return TextField(

            controller: conversationController.searchController,
            style: robotoMedium.copyWith(
              color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeDefault,
            ),

            cursorColor: Theme.of(context).colorScheme.primary,
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
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              fillColor: Get.isDarkMode
                  ? Theme.of(context).cardColor
                  : Theme.of(context).hintColor.withValues(alpha: 0.07),
              filled: true,
              isDense: true,
              hintText: 'search'.tr,
              hintStyle: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor,
              ),

              prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).hintColor, size: 22),
              prefixIconConstraints: const BoxConstraints(minWidth: 46, minHeight: 20),

              suffixIcon: conversationController.isActiveSuffixIcon ? IconButton(
                color: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  if(conversationController.searchController.text.trim().isNotEmpty) {
                    conversationController.clearSearchController();
                  }
                  FocusScope.of(context).unfocus();
                },
                icon: Icon(Icons.cancel_rounded, size: 20, color: Theme.of(context).hintColor),
              ) : null,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                borderSide: BorderSide(
                  width: 1, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                borderSide: BorderSide.none,
              ),
            ),
          );
        },
      ),
    );
  }
}


