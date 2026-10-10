import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class NotificationSetupSearchWidget extends StatelessWidget {
  final TabController? tabController;
  final FocusNode? focusNode;
  const NotificationSetupSearchWidget({super.key, this.tabController, this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Padding( padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<NotificationSetupController>(
        builder: (notificationSetupController){
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
                  controller: notificationSetupController.searchController,
                  focusNode: focusNode,
                  style:  TextStyle(fontSize: 13, color: InkColors.foreground),
                  cursorColor: InkColors.foreground,
                  autofocus: false,
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.search,
                  onChanged: (text)  {
                    notificationSetupController.showSuffixIcon(context,text);
                    if(text.isNotEmpty) {
                      notificationSetupController.searchItems(query : text.trim());
                    }
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'search_by_topic_description'.tr,
                    hintStyle:  TextStyle(fontSize: 13, color: InkColors.mutedForeground),
                  ),
                ),
              ),

              notificationSetupController.isActiveSuffixIcon
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if(notificationSetupController.searchController.text.trim().isNotEmpty) {
                          notificationSetupController.clearSearchController();
                        }
                        FocusScope.of(context).unfocus();
                      },
                      child:  Icon(Icons.cancel_rounded, size: 18, color: InkColors.mutedForeground),
                    )
                  : const SizedBox.shrink(),
            ]),
          );
        },
      ),
    );
  }
}
