import 'package:jassdbx_serviceman/feature/inbox/widgets/inbox_channel_card.dart';
import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class InboxScreen extends StatefulWidget {
  final String? fromNotification;
  const InboxScreen({super.key, this.fromNotification});

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

    try {
      Get.find<CallController>().recoverActiveCall();
    } catch (_) {}
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

    if (_filter == 0) {
      await conversationController.loadMoreChannels("customer");
      await conversationController.loadMoreChannels("provider");
    }

    if (mounted) {
      setState(() => _loadingMore = false);
    }
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

            List<ChannelData> customers;
            List<ChannelData> providers;
            if (isSearchingInProgress) {
              customers = <ChannelData>[];
              providers = <ChannelData>[];
            } else if (isSearching) {
              customers = conversationController.searchedCustomerChannelList;
              providers = conversationController.searchedProviderChannelList;
            } else {
              customers =
                  conversationController.customerChannelList ?? <ChannelData>[];
              providers =
                  conversationController.providerChannelList ?? <ChannelData>[];
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
                    onBack: widget.fromNotification != null
                        ? () {
                            if (widget.fromNotification == "fromNotification") {
                              Get.offNamed(RouteHelper.getInitialRoute());
                            } else if (conversationController.isActiveSuffixIcon &&
                                conversationController.isSearchComplete) {
                              conversationController.clearSearchController();
                            } else {
                              Get.back();
                            }
                          }
                        : null,
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

                const SizedBox(height: 8),

                Expanded(
                  child: _filter == 3
                      ? _buildCallHistory(context)
                      : RefreshIndicator(
                    color: context.kPrimary,
                    backgroundColor: context.kCard,
                    onRefresh: _refresh,
                    child: isInitialLoading || isSearchingInProgress
                        ? _buildSkeleton(context)
                        : customers.isEmpty && providers.isEmpty
                            ? _buildEmptyState(context, fromSearch: isSearching)
                            : _buildGroupedList(
                                context,
                                conversationController,
                                customers,
                                providers,
                                isSearching,
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

  Widget _sectionHeader(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 2),
      child: Row(children: [
        Text(
          title.toUpperCase(),
          style: robotoMedium.copyWith(
            fontSize: 11,
            letterSpacing: 0.8,
            color: context.kMutedForeground,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '($count)',
          style: robotoRegular.copyWith(
            fontSize: 11,
            color: context.kMutedForeground,
          ),
        ),
      ]),
    );
  }

  Widget _buildGroupedList(
    BuildContext context,
    ConversationController conversationController,
    List<ChannelData> customers,
    List<ChannelData> providers,
    bool isSearching,
  ) {
    final bool showFooter =
        _loadingMore || conversationController.loadingMoreChannels;

    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
      children: [
        if (customers.isNotEmpty) ...[
          _sectionHeader(context, 'customers'.tr, customers.length),
          for (int i = 0; i < customers.length; i++) ...[
            InboxChannelCard(channelData: customers[i]),
            if (i < customers.length - 1)
              Divider(height: 1, thickness: 1, color: context.kBorder),
          ],
        ],
        if (providers.isNotEmpty) ...[
          _sectionHeader(context, 'zone_admin'.tr, providers.length),
          for (int i = 0; i < providers.length; i++) ...[
            InboxChannelCard(channelData: providers[i]),
            if (i < providers.length - 1)
              Divider(height: 1, thickness: 1, color: context.kBorder),
          ],
        ],
        if (showFooter)
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeDefault,
            ),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
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
          label: 'chats'.tr,
          selected: _filter == 0,
          onTap: () => setState(() => _filter = 0),
        ),
        const SizedBox(width: 8),
        KFilterChip(
          label: 'calls'.tr,
          selected: _filter == 3,
          onTap: () {
            setState(() => _filter = 3);
            Get.find<CallController>().loadHistory(reload: true);
          },
        ),
      ],
    );
  }

  Widget _buildCallHistory(BuildContext context) {
    return GetBuilder<CallController>(
      builder: (callController) {
        if (callController.historyList.isEmpty && callController.historyLoading) {
          return _buildSkeleton(context);
        }
        if (callController.historyList.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              EmptyState(
                icon: Icons.call_end_rounded,
                title: 'no_calls_yet'.tr,
                text: 'call_history_empty_desc'.tr,
              ),
            ],
          );
        }
        return RefreshIndicator(
          color: context.kPrimary,
          backgroundColor: context.kCard,
          onRefresh: () => callController.loadHistory(reload: true),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
            itemCount: callController.historyList.length,
            itemBuilder: (context, index) {
              final call = callController.historyList[index];
              final other = call.otherUser ?? <String, dynamic>{};
              final bool missed = call.status == 'missed';
              final bool outgoing = call.direction == 'out';
              final IconData dirIcon = missed
                  ? Icons.call_missed_rounded
                  : outgoing
                      ? Icons.call_made_rounded
                      : Icons.call_received_rounded;
              final Color dirColor = missed
                  ? Colors.redAccent
                  : outgoing
                      ? Colors.green
                      : context.kPrimary;
              final String name = (other['name'] ?? '').toString();
              final String image = (other['image'] ?? '').toString();

              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: context.kMuted,
                          backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                          child: image.isEmpty
                              ? const Icon(Icons.person, size: 24)
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Icon(dirIcon, size: 15, color: dirColor),
                        ),
                      ],
                    ),
                    title: Text(
                      name.isNotEmpty ? name : 'call'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: context.kForeground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      [
                        call.callType == 'video' ? 'video'.tr : 'voice'.tr,
                        callController.callStatusText(call.status),
                        if ((call.duration ?? 0) > 0)
                          callController.formatDuration(call.duration!),
                      ].join(' · '),
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: missed ? Colors.redAccent : context.kMutedForeground,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.call_rounded, color: context.kPrimary),
                      onPressed: (other['id'] ?? '').toString().isEmpty
                          ? null
                          : () => callController.startCall(
                                calleeId: other['id'].toString(),
                                callType: 'voice',
                                name: name,
                                image: image,
                                phone: (other['phone'] ?? '').toString(),
                              ),
                    ),
                  ),
                  if (index < callController.historyList.length - 1)
                    Divider(height: 1, thickness: 1, color: context.kBorder),
                ],
              );
            },
          ),
        );
      },
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
