import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class ConversationListScreen extends StatefulWidget {
  final String? fromNotification;
  const ConversationListScreen({super.key, this.fromNotification});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {

  static String get filterChats => 'chats'.tr;
  static String get filterCalls => 'calls'.tr;

  String _filter = filterChats;
  bool _isLoadingMore = false;
  bool _initialLoadSettled = false;

  final ScrollController _allScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final ConversationController conversationController = Get.find<ConversationController>();
    conversationController.clearSearchController(shouldUpdate: false);
    _allScrollController.addListener(_onAllScrollReachedEnd);

    _loadData();

    try {
      Get.find<CallController>().recoverActiveCall();
    } catch (_) {}
  }

  @override
  void dispose() {
    _allScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await Get.find<ConversationController>().getChannelList(1, type: "serviceman");
      await Get.find<ConversationController>().getChannelList(1, type: "customer");
    } finally {
      if (mounted) setState(() => _initialLoadSettled = true);
    }
  }

  void _onFilterChanged(String value) {
    if (value == _filter) return;
    setState(() => _filter = value);

    final ConversationController conversationController = Get.find<ConversationController>();
    final bool isShowingSearchResult = conversationController.isActiveSuffixIcon && conversationController.isSearchComplete;

    if (value == filterCalls) {
      try {
        Get.find<CallController>().loadHistory(reload: true);
      } catch (_) {}
    } else if (!isShowingSearchResult) {
      conversationController.getChannelList(1, type: "customer");
      conversationController.getChannelList(1, type: "serviceman");
    }
  }

  void _onAllScrollReachedEnd() {
    if (!mounted || !_allScrollController.hasClients) return;
    if (_allScrollController.position.pixels != _allScrollController.position.maxScrollExtent) return;

    final ConversationController conversationController = Get.find<ConversationController>();
    final int offset = conversationController.channelOffset ?? 1;
    final int pageSize = conversationController.channelPageSize ?? 1;

    if (_isLoadingMore || offset >= pageSize) return;

    _isLoadingMore = true;
    final int nextOffset = offset + 1;
    conversationController
        .getChannelList(nextOffset, type: "customer")
        .then((_) => conversationController.getChannelList(nextOffset, type: "serviceman"))
        .whenComplete(() => _isLoadingMore = false);
  }

  Future<void> _onRefresh(ConversationController conversationController) async {
    await conversationController.getChannelList(1, reload: true, type: "customer");
    await conversationController.getChannelList(1, reload: true, type: "serviceman");
  }

  void _onBackPressed() {
    if (widget.fromNotification == "fromNotification") {
      Get.offNamed(RouteHelper.getInitialRoute());
    } else {
      if (Get.find<ConversationController>().isActiveSuffixIcon && Get.find<ConversationController>().isSearchComplete) {
        Get.find<ConversationController>().clearSearchController();
      } else {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkColors.background,
      body: SafeArea(
        bottom: false,
        child: GetBuilder<ConversationController>(
          builder: (conversationController) {

            final int conversationCount = (conversationController.customerChannelList?.length ?? 0) +
                (conversationController.servicemanChannelList?.length ?? 0);

            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              InkTopBar(
                title: 'inbox'.tr,
                subtitle: "$conversationCount conversations",
                onBack: _onBackPressed,
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ConversationListTabview(value: _filter, onChanged: _onFilterChanged),
              ),

              const SizedBox(height: 10),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ConversationSearchWidget(),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: _filter == filterCalls
                    ? _buildCallHistory(context)
                    : RefreshIndicator(
                        color: InkColors.foreground,
                        backgroundColor: InkColors.card,
                        onRefresh: () => _onRefresh(conversationController),
                        child: _conversationContent(conversationController),
                      ),
              ),

            ],);
          },
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 8),
      child: Row(children: [
        Text(
          title.toUpperCase(),
          style: robotoMedium.copyWith(
            fontSize: 11,
            letterSpacing: 0.8,
            color: InkColors.mutedForeground,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '($count)',
          style: robotoRegular.copyWith(
            fontSize: 11,
            color: InkColors.mutedForeground,
            decoration: TextDecoration.none,
          ),
        ),
      ]),
    );
  }

  Widget _sectionCard(List<ChannelData> items) {
    return InkCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Column(children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: InkColors.border),
            ChannelItem(channelData: items[i]),
          ],
        ]),
      ),
    );
  }

  Widget _conversationContent(ConversationController conversationController) {

    if (conversationController.searchedChannelList == null && !conversationController.isSearchComplete) {
      return const ConversationSearchShimmer();
    }

    if (!_initialLoadSettled &&
        conversationController.customerChannelList == null &&
        conversationController.servicemanChannelList == null) {
      return const ConversationSearchShimmer();
    }

    final bool showSearchResult = conversationController.isSearchComplete;
    final List<ChannelData> customers = showSearchResult
        ? conversationController.searchedCustomerChannelList
        : (conversationController.customerChannelList ?? []);
    final List<ChannelData> servicemen = showSearchResult
        ? conversationController.searchedServicemanChannelList
        : (conversationController.servicemanChannelList ?? []);

    final bool fromSearch = conversationController.isActiveSuffixIcon && showSearchResult;

    if (customers.isEmpty && servicemen.isEmpty) {
      return ListView(
        controller: _allScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [EmptyConversationWidget(fromSearch: fromSearch)],
      );
    }

    return ListView(
      controller: _allScrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (customers.isNotEmpty) ...[
          _sectionHeader('customers'.tr, customers.length),
          _sectionCard(customers),
          const SizedBox(height: 14),
        ],
        if (servicemen.isNotEmpty) ...[
          _sectionHeader('service_men'.tr, servicemen.length),
          _sectionCard(servicemen),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCallHistory(BuildContext context) {
    return GetBuilder<CallController>(
      builder: (callController) {
        if (callController.historyList.isEmpty && callController.historyLoading) {
          return const ConversationSearchShimmer();
        }
        if (callController.historyList.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
            children: [
              const Icon(Icons.call_end_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'no_calls_yet'.tr,
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(fontSize: 15, color: InkColors.foreground, decoration: TextDecoration.none),
              ),
              const SizedBox(height: 6),
              Text(
                'call_history_empty_desc'.tr,
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(fontSize: 13, color: InkColors.mutedForeground, decoration: TextDecoration.none),
              ),
            ],
          );
        }
        return RefreshIndicator(
          color: InkColors.foreground,
          backgroundColor: InkColors.card,
          onRefresh: () => callController.loadHistory(reload: true),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                      : InkColors.foreground;
              final String name = (other['name'] ?? '').toString();

              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Stack(
                      children: [
                        InkAvatar(name: name.isEmpty ? "?" : name, size: 44),
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
                        fontSize: 14,
                        color: InkColors.foreground,
                        decoration: TextDecoration.none,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      [
                        call.callType == 'video' ? 'video'.tr : 'voice'.tr,
                        callController.callStatusText(call.status),
                        if ((call.duration ?? 0) > 0) callController.formatDuration(call.duration!),
                      ].join(' · '),
                      style: robotoRegular.copyWith(
                        fontSize: 12,
                        color: missed ? Colors.redAccent : InkColors.mutedForeground,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.call_rounded, color: InkColors.foreground),
                      onPressed: (other['id'] ?? '').toString().isEmpty
                          ? null
                          : () => callController.startCall(
                                calleeId: other['id'].toString(),
                                callType: 'voice',
                                name: name,
                                image: (other['image'] ?? '').toString(),
                                phone: (other['phone'] ?? '').toString(),
                              ),
                    ),
                  ),
                  if (index < callController.historyList.length - 1)
                    Divider(height: 1, thickness: 1, color: InkColors.border),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
