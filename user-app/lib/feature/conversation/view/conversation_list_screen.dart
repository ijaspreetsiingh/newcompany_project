import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:jdds/feature/conversation/widgets/conversation_list_shimmer.dart';
import 'package:jdds/feature/conversation/widgets/conversation_listview.dart';
import 'package:jdds/feature/conversation/widgets/conversation_search_shimmer.dart';
import 'package:jdds/feature/conversation/widgets/conversation_search_widget.dart';
import 'package:jdds/feature/conversation/widgets/conversation_tabview.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';

class ConversationListScreen extends StatefulWidget {
  final String? fromNotification;
  const ConversationListScreen({super.key, this.fromNotification});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Get.find<ConversationController>().clearSearchController(
      shouldUpdate: false,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    final ConversationController controller =
        Get.find<ConversationController>();
    await Future.wait([
      controller.getChannelList(1, type: 'provider'),
      controller.getChannelList(1, type: 'serviceman'),
    ]);
  }

  void _onBackPressed() {
    if (widget.fromNotification == "fromNotification" ||
        !Navigator.canPop(context)) {
      /// Deferred navigation - navigator locked crash fix
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offNamed(RouteHelper.getMainRoute(RouteHelper.chatInbox));
      });
    } else {
      ConversationController conversationController = Get.find();
      if (conversationController.isActiveSuffixIcon &&
          conversationController.isSearchComplete) {
        conversationController.clearSearchController();
      } else {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      onPopInvoked: () {
        /// Navigator locked state me crash na ho isliye deferred navigation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offNamed(RouteHelper.getMainRoute(RouteHelper.chatInbox));
        });
      },
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,
        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        backgroundColor: NestInk.background,

        /// nest. `.page-header` — Inbox
        appBar: CustomAppBar(
          title: 'inbox'.tr,
          bgColor: NestInk.background,
          isBackButtonExist: true,
          onBackPressed: _onBackPressed,
        ),

        body: FooterBaseView(
          isScrollView: true,
          child: Center(
            child: SizedBox(
              height: Get.height,
              width: Dimensions.webMaxWidth,
              child: GetBuilder<ConversationController>(
                builder: (conversationController) {
                  if (conversationController.providerChannelList == null) {
                    return const ConversationListShimmer();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ConversationSearchWidget(),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      ConversationListTabview(
                        tabController: conversationController.tabController,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (conversationController.adminConversationModel !=
                                null) ...[
                              ChannelItem(
                                channelData: conversationController
                                    .adminConversationModel!,
                                isAdmin: true,
                              ),
                            ],

                            Expanded(
                              child: TabBarView(
                                controller:
                                    conversationController.tabController,
                                children: [
                                  conversationController.searchedChannelList ==
                                              null &&
                                          !conversationController
                                              .isSearchComplete
                                      ? const ConversationSearchShimmer()
                                      : ConversationListView(
                                          channelList:
                                              conversationController
                                                  .isSearchComplete
                                              ? conversationController
                                                    .searchedProviderChannelList!
                                              : conversationController
                                                        .providerChannelList ??
                                                    [],
                                          tabIndex: 0,
                                        ),

                                  conversationController.searchedChannelList ==
                                              null &&
                                          !conversationController
                                              .isSearchComplete
                                      ? const ConversationSearchShimmer()
                                      : ConversationListView(
                                          channelList:
                                              conversationController
                                                  .isSearchComplete
                                              ? conversationController
                                                    .searchedServicemanChannelList!
                                              : conversationController
                                                        .servicemanChannelList ??
                                                    [],
                                          tabIndex: 1,
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
