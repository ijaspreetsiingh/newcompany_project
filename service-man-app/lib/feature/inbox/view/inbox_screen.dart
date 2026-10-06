import 'package:demandium_serviceman/feature/inbox/widgets/inbox_channel_card.dart';
import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final ScrollController _scrollController = ScrollController();

  /// 0 = all, 1 = customer, 2 = provider
  int _filter = 0;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    final ConversationController conversationController =
        Get.find<ConversationController>();
    conversationController.clearSearchController(shouldUpdate: false);

    if (conversationController.customerChannelList == null ||
        conversationController.providerChannelList == null) {
      _refresh();
    }

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final ConversationController conversationController =
        Get.find<ConversationController>();
    await conversationController.getChannelList(1, reload: true, type: "provider");
    await conversationController.getChannelList(1, reload: true, type: "customer");
  }

  void _onScroll() {
    if (_loadingMore || !_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    final ConversationController conversationController =
        Get.find<ConversationController>();
    setState(() => _loadingMore = true);

    if (_filter != 2) {
      await conversationController.loadMoreChannels("customer");
    }
    if (_filter != 1) {
      await conversationController.loadMoreChannels("provider");
    }

    if (mounted) {
      setState(() => _loadingMore = false);
    }
  }

  DateTime _lastActiveTime(ChannelData channelData) {
    try {
      final String? timeSource = (channelData.channelUsers != null &&
              channelData.channelUsers!.isNotEmpty)
          ? (channelData.channelUsers!.first.updatedAt ?? channelData.createdAt)
          : channelData.createdAt;
      if (timeSource == null || timeSource.isEmpty) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateConverter.isoUtcStringToLocalDate(timeSource);
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  List<ChannelData> _mergeAndSort(List<ChannelData> first, List<ChannelData> second) {
    final Set<String> seen = <String>{};
    final List<ChannelData> merged = <ChannelData>[];
    for (final ChannelData channel in [...first, ...second]) {
      if (channel.id == null || seen.add(channel.id!)) {
        merged.add(channel);
      }
    }
    merged.sort(
      (ChannelData a, ChannelData b) =>
          _lastActiveTime(b).compareTo(_lastActiveTime(a)),
    );
    return merged;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        backgroundColor: context.kBackground,
        body: GetBuilder<ConversationController>(
          builder: (conversationController) {
            final bool isSearching = conversationController.isActiveSuffixIcon &&
                conversationController.isSearchComplete;
            final bool isSearchingInProgress =
                conversationController.searchedChannelList == null &&
                    !conversationController.isSearchComplete;

            final int customerCount =
                conversationController.customerChannelList?.length ?? 0;
            final int providerCount =
                conversationController.providerChannelList?.length ?? 0;

            List<ChannelData> channelList;
            if (isSearchingInProgress) {
              channelList = <ChannelData>[];
            } else if (isSearching) {
              if (_filter == 1) {
                channelList = conversationController.searchedCustomerChannelList;
              } else if (_filter == 2) {
                channelList = conversationController.searchedProviderChannelList;
              } else {
                channelList = _mergeAndSort(
                  conversationController.searchedCustomerChannelList,
                  conversationController.searchedProviderChannelList,
                );
              }
            } else if (_filter == 1) {
              channelList = conversationController.customerChannelList ?? <ChannelData>[];
            } else if (_filter == 2) {
              channelList = conversationController.providerChannelList ?? <ChannelData>[];
            } else {
              channelList = _mergeAndSort(
                conversationController.customerChannelList ?? <ChannelData>[],
                conversationController.providerChannelList ?? <ChannelData>[],
              );

              final ChannelData? adminChannel =
                  conversationController.adminConversationModel;
              if (adminChannel != null &&
                  !channelList.any((ChannelData e) => e.id == adminChannel.id)) {
                channelList = <ChannelData>[adminChannel, ...channelList];
              }
            }

            final bool isInitialLoading =
                conversationController.customerChannelList == null &&
                    !isSearchingInProgress &&
                    !isSearching;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SafeArea(
                  bottom: false,
                  child: PageHeader(
                    title: 'inbox'.tr,
                    subtitle: "${customerCount + providerCount} ${'conversations'.tr}",
                    right: KIconButton(
                      icon: Icons.settings_outlined,
                      onTap: _refresh,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchField(context, conversationController),
                      const SizedBox(height: 12),
                      _buildFilterChips(),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: RefreshIndicator(
                    color: context.kPrimary,
                    backgroundColor: context.kCard,
                    onRefresh: _refresh,
                    child: isInitialLoading || isSearchingInProgress
                        ? _buildSkeleton(context)
                        : channelList.isEmpty
                            ? _buildEmptyState(context, fromSearch: isSearching)
                            : ListView.builder(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
                                itemCount: channelList.length +
                                    ((_loadingMore ||
                                            conversationController.loadingMoreChannels)
                                        ? 1
                                        : 0),
                                itemBuilder: (context, index) {
                                  if (index >= channelList.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: Dimensions.paddingSizeDefault,
                                      ),
                                      child: Center(
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  final ChannelData channelData = channelList[index];
                                  final bool showAdminCard =
                                      !isSearching &&
                                          _filter == 0 &&
                                          conversationController
                                                  .adminConversationModel !=
                                              null &&
                                          channelData.id ==
                                              conversationController
                                                  .adminConversationModel!.id;

                                  return Column(
                                    children: [
                                      InboxChannelCard(
                                        channelData: channelData,
                                        isAdmin: showAdminCard,
                                      ),
                                      if (index < channelList.length - 1)
                                        Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: context.kBorder,
                                        ),
                                    ],
                                  );
                                },
                              ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField(
    BuildContext context,
    ConversationController conversationController,
  ) {
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
              onChanged: (text) =>
                  conversationController.showSuffixIcon(context, text),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  conversationController.getSearchedChannelList(query: text);
                }
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'search_conversations'.tr,
                hintStyle: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: context.kMutedForeground,
                ),
                suffixIcon: conversationController.isActiveSuffixIcon
                    ? InkWell(
                        onTap: () {
                          conversationController.clearSearchController();
                          FocusScope.of(context).unfocus();
                        },
                        child: Icon(
                          Icons.cancel_outlined,
                          size: 19,
                          color: context.kMutedForeground,
                        ),
                      )
                    : null,
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: [
        KFilterChip(
          label: 'all'.tr,
          selected: _filter == 0,
          onTap: () => setState(() => _filter = 0),
        ),
        const SizedBox(width: 8),
        KFilterChip(
          label: 'customer'.tr,
          selected: _filter == 1,
          onTap: () => setState(() => _filter = 1),
        ),
        const SizedBox(width: 8),
        KFilterChip(
          label: 'zone_admin'.tr,
          selected: _filter == 2,
          onTap: () => setState(() => _filter = 2),
        ),
      ],
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.kMuted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                        color: context.kMuted,
                        borderRadius: BorderRadius.circular(kRadiusMd),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.kMuted,
                        borderRadius: BorderRadius.circular(kRadiusMd),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool fromSearch}) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        EmptyState(
          icon: Icons.mail_outline_rounded,
          title: fromSearch ? 'no_data_found'.tr : 'no_conversation_found'.tr,
          text: fromSearch
              ? 'search_conversations'.tr
              : "you_don't_have_any_conversation_yet".tr,
        ),
      ],
    );
  }
}
