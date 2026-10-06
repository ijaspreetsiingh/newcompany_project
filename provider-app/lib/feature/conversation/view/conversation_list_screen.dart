import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class ConversationListScreen extends StatefulWidget {
  final String? fromNotification;
  const ConversationListScreen({super.key, this.fromNotification});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {

  static const String filterAll = 'All';
  static const String filterCustomers = 'Customers';
  static const String filterServicemen = 'Servicemen';

  String _filter = filterAll;
  bool _isLoadingMore = false;
  bool _initialLoadSettled = false;

  final ScrollController _allScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final ConversationController conversationController = Get.find<ConversationController>();
    conversationController.clearSearchController(shouldUpdate: false);
    conversationController.tabController?.addListener(_onTabIndexChanged);
    _allScrollController.addListener(_onAllScrollReachedEnd);

    _loadData();
  }

  @override
  void dispose() {
    if (Get.isRegistered<ConversationController>()) {
      Get.find<ConversationController>().tabController?.removeListener(_onTabIndexChanged);
    }
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

  void _onTabIndexChanged() {
    if (_filter == filterAll) return;
    final int index = Get.find<ConversationController>().tabController?.index ?? 0;
    final String nextFilter = index == 0 ? filterCustomers : filterServicemen;
    if (nextFilter != _filter) {
      setState(() => _filter = nextFilter);
    }
  }

  void _onFilterChanged(String value) {
    if (value == _filter) return;
    setState(() => _filter = value);

    final ConversationController conversationController = Get.find<ConversationController>();
    final bool isShowingSearchResult = conversationController.isActiveSuffixIcon && conversationController.isSearchComplete;

    if (value == filterCustomers) {
      conversationController.tabController?.index = 0;
      if (!isShowingSearchResult) {
        conversationController.getChannelList(1, type: "customer");
      }
    } else if (value == filterServicemen) {
      conversationController.tabController?.index = 1;
      if (!isShowingSearchResult) {
        conversationController.getChannelList(1, type: "serviceman");
      }
    } else {
      if (!isShowingSearchResult) {
        conversationController.getChannelList(1, type: "customer");
        conversationController.getChannelList(1, type: "serviceman");
      }
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
    if (_filter == filterServicemen) {
      await conversationController.getChannelList(1, reload: true, type: "serviceman");
    } else if (_filter == filterCustomers) {
      await conversationController.getChannelList(1, reload: true, type: "customer");
    } else {
      await conversationController.getChannelList(1, reload: true, type: "customer");
      await conversationController.getChannelList(1, reload: true, type: "serviceman");
    }
  }

  List<ChannelData> _channelList(ConversationController conversationController) {
    final bool isSearchResult = conversationController.isSearchComplete;

    switch (_filter) {
      case filterCustomers:
        return isSearchResult
            ? conversationController.searchedCustomerChannelList
            : (conversationController.customerChannelList ?? []);
      case filterServicemen:
        return isSearchResult
            ? conversationController.searchedServicemanChannelList
            : (conversationController.servicemanChannelList ?? []);
      default:
        return [
          ...(isSearchResult
              ? conversationController.searchedCustomerChannelList
              : (conversationController.customerChannelList ?? [])),
          ...(isSearchResult
              ? conversationController.searchedServicemanChannelList
              : (conversationController.servicemanChannelList ?? [])),
        ];
    }
  }

  ScrollController? _scrollControllerFor(ConversationController conversationController) {
    switch (_filter) {
      case filterCustomers:
        return conversationController.channelScrollController1;
      case filterServicemen:
        return conversationController.channelScrollController2;
      default:
        return _allScrollController;
    }
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

            final ChannelData? adminChannel = conversationController.adminConversationModel;
            final int conversationCount = (conversationController.customerChannelList?.length ?? 0) +
                (conversationController.servicemanChannelList?.length ?? 0) +
                (adminChannel != null ? 1 : 0);

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
                child: RefreshIndicator(
                  color: InkColors.foreground,
                  backgroundColor: InkColors.card,
                  onRefresh: () => _onRefresh(conversationController),
                  child: _conversationContent(conversationController, adminChannel),
                ),
              ),

            ],);
          },
        ),
      ),
    );
  }

  Widget _conversationContent(ConversationController conversationController, ChannelData? adminChannel) {

    if (conversationController.searchedChannelList == null && !conversationController.isSearchComplete) {
      return const ConversationSearchShimmer();
    }

    if (!_initialLoadSettled &&
        conversationController.customerChannelList == null &&
        conversationController.servicemanChannelList == null &&
        conversationController.adminConversationModel == null) {
      return const ConversationSearchShimmer();
    }

    final List<ChannelData> channels = _channelList(conversationController);
    final List<ChannelData> items = [...channels];
    if (adminChannel != null) items.insert(0, adminChannel);

    return ConversationListView(
      channelList: items,
      scrollController: _scrollControllerFor(conversationController),
      fromSearch: conversationController.isActiveSuffixIcon && conversationController.isSearchComplete,
    );
  }
}
