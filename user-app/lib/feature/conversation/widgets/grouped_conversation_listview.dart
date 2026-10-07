import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:jdds/feature/conversation/widgets/empty_conversation_widget.dart';
import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';

/// Chats tab — section headers ke saath grouped conversation list.
/// Zone Admin (provider) · Service Men — super-admin/support row nahi (alag Support screen hai).
class GroupedConversationListView extends StatelessWidget {
  const GroupedConversationListView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConversationController>(
      builder: (conversationController) {
        final bool isSearching =
            conversationController.isActiveSuffixIcon &&
            conversationController.isSearchComplete;

        final List<ChannelData> zoneAdminChannels = isSearching
            ? (conversationController.searchedProviderChannelList ?? [])
            : (conversationController.providerChannelList ?? []);
        final List<ChannelData> serviceMenChannels = isSearching
            ? (conversationController.searchedServicemanChannelList ?? [])
            : (conversationController.servicemanChannelList ?? []);

        if (zoneAdminChannels.isEmpty && serviceMenChannels.isEmpty) {
          return const EmptyConversationWidget();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              conversationController.getChannelList(1, type: 'provider'),
              conversationController.getChannelList(1, type: 'serviceman'),
            ]);
          },
          child: ListView(
            controller: conversationController.channelScrollController1,
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: [
              if (zoneAdminChannels.isNotEmpty) ...[
                _SectionHeader(
                  title: 'zone_admin'.tr,
                  count: zoneAdminChannels.length,
                ),
                ...zoneAdminChannels.map(
                  (channel) => ChannelItem(channelData: channel),
                ),
              ],
              if (serviceMenChannels.isNotEmpty) ...[
                _SectionHeader(
                  title: 'service_men'.tr,
                  count: serviceMenChannels.length,
                ),
                ...serviceMenChannels.map(
                  (channel) => ChannelItem(channelData: channel),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 6),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: NestInk.display(
              size: 10,
              weight: FontWeight.w800,
              color: NestInk.mutedText,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '($count)',
            style: NestInk.body(size: 10, color: NestInk.mutedText),
          ),
        ],
      ),
    );
  }
}
