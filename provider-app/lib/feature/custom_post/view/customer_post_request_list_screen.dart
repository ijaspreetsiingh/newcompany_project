import 'package:jassdbx_provider/util/core_export.dart';
import 'package:jassdbx_provider/feature/custom_post/widget/custom_post_list_view.dart';
import 'package:get/get.dart';

class CustomerRequestListScreen extends StatefulWidget {
  const CustomerRequestListScreen({super.key});

  @override
  State<CustomerRequestListScreen> createState() => _CustomerRequestListScreenState();
}

class _CustomerRequestListScreenState extends State<CustomerRequestListScreen> {

  @override
  void initState() {

    super.initState();
    Get.find<PostController>().setTabControllerIndex(index: 0);
    if(Get.find<PostController>().tabController!.index==0){
      Get.find<PostController>().getCustomerPostList(1,"new_request",reload: false, fromBid: false);
    }else{
      Get.find<PostController>().getCustomerPostList(1,"placed_offer",reload: false, fromBid: true);
    }

    Get.find<SplashController>().updateCustomBookingRedDotButtonStatus(status: false, shouldUpdate: true);
  }

  void _selectTab(PostController postController, int index) {
    if (postController.tabController!.index == index) return;
    postController.tabController!.index = index;
    if (index == 0) {
      postController.getCustomerPostList(1, "new_request", fromBid: false);
    } else {
      postController.getCustomerPostList(1, "placed_offer", fromBid: true);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: InkColors.background,

      body: SafeArea(
        child: GetBuilder<PostController>(
          builder: (postController){

            final bool isBidTab = postController.tabController!.index == 1;
            final bool biddingEnabled = Get.find<UserProfileController>()
                .checkAvailableFeatureInSubscriptionPlan(featureType: 'bidding');
            final String packageName = Get.find<UserProfileController>()
                    .providerModel
                    ?.content
                    ?.subscriptionInfo
                    ?.subscribedPackageDetails
                    ?.packageName ??
                "";

            return Column(
              children: [

                InkTopBar(
                  title: "Custom requests",
                  subtitle: biddingEnabled && packageName.isNotEmpty
                      ? "Bidding enabled on $packageName"
                      : null,
                  onBack: (){
                    if(Navigator.canPop(context)){
                      Get.back();
                    }else{
                      Get.offNamed(RouteHelper.initial);
                    }
                  },
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkPills(
                    items: const ["Open posts", "My offers"],
                    value: isBidTab ? "My offers" : "Open posts",
                    onChanged: (value) => _selectTab(postController, value == "My offers" ? 1 : 0),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: GetBuilder<PostController>(
                    builder: (postController) {
                      if(postController.loading){
                        return const Center(child: CircularProgressIndicator(),);
                      }else{
                        return CustomPostListview(
                          myPost: postController.tabController!.index == 0 ? postController.postList??[]: postController.bidPostList??[],
                          newRequest: postController.tabController!.index == 0 ? true : false,
                        );
                      }
                    }
                  ),

                ),
              ],
            );
        },
        ),
      ),
    );
  }
}
