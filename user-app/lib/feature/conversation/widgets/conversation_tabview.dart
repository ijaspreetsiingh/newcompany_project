import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';

class ConversationListTabview extends StatelessWidget {
  final TabController? tabController;
  const ConversationListTabview({super.key, this.tabController});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConversationController>(
      builder: (conversationController) {
        bool isSearching =
            conversationController.isActiveSuffixIcon &&
            conversationController.isSearchComplete;

        int providerCount = isSearching
            ? (conversationController.searchedProviderChannelList?.length ?? 0)
            : 0;
        int servicemanCount = isSearching
            ? (conversationController.searchedServicemanChannelList?.length ??
                  0)
            : 0;

        void onSegmentTap(int index) {
          if (tabController != null) {
            tabController!.animateTo(index);
          }
          if (!isSearching) {
            conversationController.getChannelList(
              1,
              type: index == 0 ? "provider" : "serviceman",
            );
          }
        }

        /// nest. `.tab-row` â€” underline tabs
        Widget tabRow(int selectedIndex) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: NestInk.border)),
            ),
            child: Row(
              children: [
                _SegmentItem(
                  title: 'zone_admin'.tr,
                  count: providerCount,
                  isSelected: selectedIndex == 0,
                  onTap: () => onSegmentTap(0),
                ),

                _SegmentItem(
                  title: 'partner'.tr,
                  count: servicemanCount,
                  isSelected: selectedIndex == 1,
                  onTap: () => onSegmentTap(1),
                ),
              ],
            ),
          );
        }

        final TabController? tc = tabController;

        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: tc == null
              ? tabRow(0)
              : AnimatedBuilder(
                  animation: tc,
                  builder: (context, _) => tabRow(tc.index),
                ),
        );
      },
    );
  }
}

class _SegmentItem extends StatelessWidget {
  final String title;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  const _SegmentItem({
    required this.title,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? NestInk.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: NestInk.display(
                    size: 11,
                    weight: FontWeight.w700,
                    color: isSelected ? NestInk.primary : NestInk.mutedText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              if (count > 0) ...[
                const SizedBox(width: 5),
                Text(
                  '($count)',
                  style: NestInk.body(
                    size: 10,
                    color: isSelected ? NestInk.primary : NestInk.mutedText,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
