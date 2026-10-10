import 'package:get/get.dart';
import 'package:jassdbx_serviceman/utils/core_export.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 2);
    tabController!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    Get.find<UserController>()
        .pickImage(removePickedProfileImage: true, shouldUpdate: false);
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.kBackground,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: PageHeader(
              title: "edit_profile_title".tr,
              subtitle: "keep_details_updated".tr,
              onBack: () {
                if (Navigator.canPop(context)) {
                  Get.back();
                } else {
                  Get.offAllNamed(RouteHelper.getInitialRoute());
                }
              },
            ),
          ),
          Expanded(
            child: GetBuilder<UserController>(
              builder: (userController) {
                return Column(
                  children: [
                    _buildTabStrip(context, userController),
                    Expanded(
                      child: TabBarView(
                        controller: tabController,
                        children: const [
                          EditProfileGeneralInfo(),
                          EditProfileAccountInfo(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabStrip(BuildContext context, UserController userController) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.kBorder, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildTab(
            context,
            userController,
            index: 0,
            label: "general_info".tr,
          ),
          _buildTab(
            context,
            userController,
            index: 1,
            label: "account_info".tr,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    UserController userController, {
    required int index,
    required String label,
  }) {
    final bool isActive = (tabController?.index ?? 0) == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          tabController?.animateTo(index);
          switch (index) {
            case 0:
              userController
                  .updatePageCurrentState(EditProfileTabControllerState.generalInfo);
              break;
            case 1:
              userController
                  .updatePageCurrentState(EditProfileTabControllerState.accountIno);
              break;
          }
        },
        child: Container(
          height: 48,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: isActive
                ? robotoMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.kForeground,
                  )
                : robotoMedium.copyWith(
                    fontSize: 14,
                    color: context.kMutedForeground,
                  ),
          ),
        ),
      ),
    );
  }
}
