import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class ConversationListScreen extends StatefulWidget {
  final String? fromNotification;
  const ConversationListScreen({super.key, this.fromNotification}) ;

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> with SingleTickerProviderStateMixin {


  @override
  void initState() {
    super.initState();

    Get.find<ConversationController>().clearSearchController(shouldUpdate: false);
    _loadData();
  }

  Future<void> _loadData() async {
    await Get.find<ConversationController>().getChannelList(1, type: "provider");
    Get.find<ConversationController>().getChannelList(1, type: "customer");
  }

  ConversationUserModel? _supportUser(ChannelData? adminChannel) {
    if (adminChannel == null ||
        adminChannel.channelUsers == null ||
        adminChannel.channelUsers!.length <= 1) {
      return null;
    }
    final List<ConversationUserModel> users = adminChannel.channelUsers!;
    return users[0].user?.userType != "provider-serviceman" ? users[0] : users[1];
  }

  Widget _buildSupportCTA(BuildContext context, ConversationUserModel supportUser) {
    String? imageUrl = supportUser.user?.userType == 'customer'
        ? supportUser.user?.profileImageFullPath
        : supportUser.user?.userType == 'super-admin'
            ? "${Get.find<SplashController>().configModel?.content?.faviconFullPath}"
            : supportUser.user?.provider?.logoFullPath ?? "";
    final String image = "$imageUrl";
    final String name = "technical_support_team".tr;
    final String phone = supportUser.user?.phone ?? "";
    final String userType = supportUser.user?.userType ?? "";

    return Container(
      decoration: BoxDecoration(
        color: context.kPrimary,
        borderRadius: BorderRadius.circular(kRadiusMd),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(kRadiusMd),
          onTap: () {
            Get.toNamed(
              RouteHelper.getChatScreenRoute(
                supportUser.channelId ?? "",
                name,
                image,
                phone,
                userType,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.kPrimaryForeground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.support_agent_rounded,
                    size: 22,
                    color: context.kPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          fontWeight: FontWeight.w600,
                          color: context.kPrimaryForeground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'usually_replies'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: context.kPrimaryForeground
                              .withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: context.kPrimaryForeground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        backgroundColor: context.kBackground,
        body: GetBuilder<ConversationController>(
          builder: (conversationController){

            final ConversationUserModel? supportUser =
                _supportUser(conversationController.adminConversationModel);

            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              SafeArea(
                bottom: false,
                child: PageHeader(
                  title: 'conversations'.tr,
                  onBack: (){
                    if(widget.fromNotification == "fromNotification"){
                      Get.offNamed(RouteHelper.getInitialRoute());
                    }else{
                      if(conversationController.isActiveSuffixIcon && conversationController.isSearchComplete){
                        conversationController.clearSearchController();
                      }else{
                        Get.back();
                      }
                    }
                  },
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  color: context.kPrimary,
                  backgroundColor: context.kCard,
                  onRefresh: () async=> Get.find<ConversationController>().getChannelList(1, reload: true),

                  child: conversationController.customerChannelList != null ?

                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        const ConversationSearchWidget(),

                        if(supportUser != null) ...[
                          const SizedBox(height: 16),
                          _buildSupportCTA(context, supportUser),
                        ],

                        const SizedBox(height: 20),
                        ConversationListTabview( tabController: conversationController.tabController,),

                      ],),
                    ),

                    Expanded(
                      child: TabBarView( controller: conversationController.tabController, children: [

                        conversationController.searchedChannelList == null && !conversationController.isSearchComplete ?
                        const ConversationSearchShimmer() :
                        ConversationListView(
                          channelList: conversationController.isSearchComplete ?
                          conversationController.searchedCustomerChannelList : conversationController.customerChannelList!,
                          tabIndex: 0,
                        ),

                        conversationController.searchedChannelList == null && !conversationController.isSearchComplete ?
                        const ConversationSearchShimmer() :
                        ConversationListView(
                          channelList : conversationController.isSearchComplete ?
                          conversationController.searchedProviderChannelList : conversationController.providerChannelList??[],
                          tabIndex: 1,
                        ),


                      ]),
                    ),

                  ],) : const ConversationListShimmer(),
                ),
              ),

            ],);
          },
        ),
      ),
    );
  }
}
