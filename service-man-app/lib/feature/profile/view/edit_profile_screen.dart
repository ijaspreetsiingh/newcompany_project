import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 2);
    Get.find<UserController>().pickImage(removePickedProfileImage: true, shouldUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: "edit_profile".tr),
      body: GetBuilder<UserController>(
        builder: (userController) {
          return Column(
            children: [
              const SizedBox(height: 4),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: tabController,
                  indicator: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                  labelColor: Colors.white,
                  unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
                  labelStyle: robotoMedium.copyWith(fontSize: 13),
                  unselectedLabelStyle: robotoMedium.copyWith(fontSize: 13),
                  labelPadding: EdgeInsets.zero,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: "general_info".tr),
                    Tab(text: "account_info".tr),
                  ],
                  onTap: (int index) {
                    switch (index) {
                      case 0:
                        userController.updatePageCurrentState(EditProfileTabControllerState.generalInfo);
                        break;
                      case 1:
                        userController.updatePageCurrentState(EditProfileTabControllerState.accountIno);
                        break;
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
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
    );
  }
}
