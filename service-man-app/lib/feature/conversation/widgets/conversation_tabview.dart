import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class ConversationListTabview extends StatefulWidget {
  final TabController? tabController;
  const ConversationListTabview({super.key, this.tabController}) ;

  @override
  State<ConversationListTabview> createState() => _ConversationListTabviewState();
}

class _ConversationListTabviewState extends State<ConversationListTabview> {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = widget.tabController;
    _tabController?.addListener(_handleTabChange);
  }

  @override
  void didUpdateWidget(covariant ConversationListTabview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabController != widget.tabController) {
      _tabController?.removeListener(_handleTabChange);
      _tabController = widget.tabController;
      _tabController?.addListener(_handleTabChange);
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onTapTab(ConversationController conversationController, int index) {
    widget.tabController?.index = index;

    if(!( conversationController.isActiveSuffixIcon && conversationController.isSearchComplete)){
      conversationController.getChannelList(1,type: index == 0 ? "customer": "provider");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConversationController>(builder: (conversationController){

      final int activeIndex = widget.tabController?.index ?? 0;

      return Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.kBorder, width: 1)),
        ),
        child: Row(
          children: [
            _buildTab(context, conversationController, 0, 'customer'.tr, activeIndex),
            _buildTab(context, conversationController, 1, 'zone_admin'.tr, activeIndex),
          ],
        ),
      );
    });
  }

  Widget _buildTab(
    BuildContext context,
    ConversationController conversationController,
    int index,
    String label,
    int activeIndex,
  ) {
    final bool isActive = activeIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onTapTab(conversationController, index),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? context.kForeground : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: isActive
                ? robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    fontWeight: FontWeight.w600,
                    color: context.kForeground,
                  )
                : robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: context.kMutedForeground,
                  ),
          ),
        ),
      ),
    );
  }
}
