import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class ServicemanSetupScreen extends StatefulWidget {
  const ServicemanSetupScreen({super.key});

  @override
  State<ServicemanSetupScreen> createState() => _ServicemanSetupScreenState();
}

class _ServicemanSetupScreenState extends State<ServicemanSetupScreen> {

  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  void initState() {
    super.initState();
    Get.find<ServicemanSetupController>().getAllServicemanList(1, reload: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addServiceman() {
    Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrial){
      if(isTrial){
        Get.find<ServicemanSetupController>().controller!.index = 0;
        Get.find<ServicemanSetupController>().getSingleServicemanData(index: -1, fromPage: "others");
        Get.find<ServicemanSetupController>().clearAllData();
        Get.find<ServicemanSetupController>().resetOtherValidationData();
        Get.to(()=>const AddNewServicemanScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkColors.background,
      body: SafeArea(
        child: GetBuilder<ServicemanSetupController>(builder: (servicemanController) {

          final List<ServicemanModel> servicemen = servicemanController.servicemanList ?? [];
          final String query = _query.trim().toLowerCase();

          final List<int> visibleIndexes = [];
          for (int i = 0; i < servicemen.length; i++) {
            final String name = "${servicemen[i].firstName ?? ""} ${servicemen[i].lastName ?? ""}".trim().toLowerCase();
            if (query.isEmpty || name.contains(query)) {
              visibleIndexes.add(i);
            }
          }

          return Column(children: [

            InkTopBar(
              title: "Service men",
              subtitle: "${servicemanController.totalServiceman} ${servicemanController.totalServiceman == 1 ? "team member" : "team members"}",
              onBack: () => Get.back(),
              right: InkIconButton(icon: Icons.add_rounded, filled: true, onTap: _addServiceman),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkSearchField(
                hint: "Search technician",
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: servicemanController.servicemanList == null ?
              const SingleChildScrollView(child: ServiceManListShimmer()) :

              servicemen.isEmpty ?
              const NoServicemanView() :

              visibleIndexes.isEmpty ?
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: InkEmptyState('no_data_found'.tr),
                ),
              ) :

              ServiceManListview(visibleIndexes: visibleIndexes),
            ),

          ]);
        }),
      ),
    );
  }
}
