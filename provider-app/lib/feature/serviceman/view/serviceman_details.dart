import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class ServicemanDetails extends StatefulWidget {
  final String id;
  final bool fromDashboard;
  const ServicemanDetails({super.key, required this.id, required this.fromDashboard});
  @override
  State<ServicemanDetails> createState() => _ServicemanDetailsState();
}

class _ServicemanDetailsState extends State<ServicemanDetails> {

  void _toggleStatus(ServicemanDetailsController controller) {
    final String servicemanId = controller.servicemanModel?.id ?? '';
    if (servicemanId.isEmpty) return;

    Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrial){
      if(isTrial){
        Get.find<ServicemanSetupController>().changeServicemanStatus(
            -1, servicemanId, fromDetailsPage: true
        );

        if(widget.fromDashboard){
          Get.find<DashboardController>().getDashboardData();
        }else{
          Get.find<ServicemanSetupController>().getAllServicemanList(1,reload: true);
        }
      }
    });
  }

  void _editServiceman() {
    Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrial){
      if(isTrial){
        Get.find<ServicemanSetupController>().getSingleServicemanData(index :-1, fromPage: "detailsPage");
        Get.to(()=>const AddNewServicemanScreen(isEditScreen: true,));
      }
    });
  }

  void _deleteServiceman(ServicemanDetailsController controller) {
    final String servicemanId = controller.servicemanModel?.id ?? '';
    if (servicemanId.isEmpty) return;

    Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrial){
      if(isTrial){
        showCustomDialog(child: ConfirmationDialog(
            title: "delete_this_service_man".tr,
            icon: Images.servicemanImage,
            description: 'this_operation_cannot_be_undone'.tr,
            onYesPressed: () async{
              Get.back();
              showCustomDialog(child: const CustomLoader());
              await Get.find<ServicemanSetupController>()
                  .deleteServiceman(servicemanId, fromDetails: true);
            },
            onNoPressed: () {
              Get.back();
            }), barrierDismissible: true,
        );
      }
    });
  }

  Widget _contactTile(IconData icon) {
    return Container(
      height: 34,
      width: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: InkColors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 17, color: InkColors.foreground),
    );
  }

  Widget _hideBottomBorder(Widget child) {
    return Stack(
      children: [
        child,
         Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SizedBox(
            height: 1,
            child: ColoredBox(color: InkColors.card),
          ),
        ),
      ],
    );
  }

  Widget _rowsCard(List<Widget> rows) {
    return InkCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < rows.length; i++)
            i == rows.length - 1 ? _hideBottomBorder(rows[i]) : rows[i],
        ],
      ),
    );
  }

  Widget _header(String profileImage, String name, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(48),
            child: CustomImage(
              height: 96,
              width: 96,
              fit: BoxFit.cover,
              image: profileImage,
              placeholder: Images.userPlaceHolder,
            ),
          ),
          if (name.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: robotoBold.copyWith(
                fontSize: 17,
                height: 1.3,
                color: InkColors.foreground,
              ),
            ),
          ],
          const SizedBox(height: 8),
          ServicemanStatusPill(isActive: isActive),
        ],
      ),
    );
  }

  Widget _statsCard(int ongoing, int completed, int canceled) {
    return InkCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(child: _StatColumn(label: 'ongoing'.tr, value: '$ongoing')),
          Container(width: 1, height: 40, color: InkColors.border),
          Expanded(child: _StatColumn(label: 'completed'.tr, value: '$completed')),
          Container(width: 1, height: 40, color: InkColors.border),
          Expanded(child: _StatColumn(label: 'canceled'.tr, value: '$canceled')),
        ],
      ),
    );
  }

  Widget _documentsCard(List<String> documents) {
    return InkCard(
      radius: 12,
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.4,
        ),
        itemCount: documents.length,
        itemBuilder: (context, index) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomImage(
            fit: BoxFit.cover,
            image: documents[index],
            placeholder: Images.userPlaceHolder,
          ),
        ),
      ),
    );
  }

  Widget _actionBar(ServicemanDetailsController controller, double bottomInset) {
    final bool isActive = controller.servicemanModel?.user?.isActive == 1;
    final String toggleLabel = isActive ? 'inactive'.tr : "Active";

    return Container(
      width: double.infinity,
      decoration:  BoxDecoration(
        color: InkColors.card,
        border: Border(top: BorderSide(color: InkColors.border)),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkPrimaryButton(
            label: toggleLabel,
            onTap: () => _toggleStatus(controller),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkSecondaryButton(label: 'edit'.tr, onTap: _editServiceman),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkSecondaryButton(
                  label: 'delete'.tr,
                  onTap: () => _deleteServiceman(controller),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: InkColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            InkTopBar(title: 'profile_details'.tr, onBack: () => Get.back()),
            Expanded(
              child: GetBuilder<ServicemanDetailsController>(
                initState: (_){
                  Get.find<ServicemanDetailsController>().getServicemanDetails(widget.id);
                },
                builder: (servicemanDetailsController){
                  final serviceman = servicemanDetailsController.servicemanModel;
                  if(serviceman == null){
                    return const SingleChildScrollView(child: ServiceManDetailsShimmer());
                  }

                  final user = serviceman.user;
                  final String name = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
                  final bool isActive = user?.isActive == 1;
                  final String profileImage = user?.profileImageFullPath ?? '';
                  final String phone = user?.phone ?? '';
                  final String email = user?.email ?? '';
                  final String identityType = user?.identificationType ?? '';
                  final String identityNumber = user?.identificationNumber ?? '';
                  final String identityLabel = [
                    if(identityType.isNotEmpty) identityType.tr,
                    if(identityNumber.isNotEmpty) identityNumber,
                  ].join(' - ');
                  final List<String> documents = user?.identificationImageFullPath ?? <String>[];

                  final int ongoing = serviceman.bookingsCount?.ongoing ?? 0;
                  final int completed = serviceman.bookingsCount?.completed ?? 0;
                  final int canceled = serviceman.bookingsCount?.canceled ?? 0;

                  final List<Widget> contactRows = <Widget>[
                    if(phone.isNotEmpty)
                      InkRowLink(
                        title: phone,
                        meta: 'phone_number'.tr,
                        leading: _contactTile(Icons.phone_rounded),
                      ),
                    if(email.isNotEmpty)
                      InkRowLink(
                        title: email,
                        meta: 'email'.tr,
                        leading: _contactTile(Icons.email_rounded),
                      ),
                    if(identityLabel.isNotEmpty)
                      InkRowLink(
                        title: identityLabel,
                        meta: 'identity_information'.tr,
                        leading: _contactTile(Icons.badge_outlined),
                      ),
                  ];

                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 20),
                              _header(profileImage, name, isActive),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: _statsCard(ongoing, completed, canceled),
                              ),
                              if(contactRows.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                InkSection(
                                  title: "Contact Information",
                                  child: _rowsCard(contactRows),
                                ),
                              ],
                              if(documents.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                InkSection(
                                  title: "Documents",
                                  child: _documentsCard(documents),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      _actionBar(servicemanDetailsController, bottomInset),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:  TextStyle(
            fontSize: 10.5,
            height: 1.2,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
            color: InkColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          style:  TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.1,
            color: InkColors.foreground,
          ),
        ),
      ],
    );
  }
}

class ServicemanStatusPill extends StatelessWidget {
  final bool isActive;
  const ServicemanStatusPill({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? InkColors.foreground : InkColors.secondary,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        isActive ? 'Active' : 'inactive'.tr,
        style: TextStyle(
          fontSize: 10,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: isActive ? InkColors.background : InkColors.mutedForeground,
        ),
      ),
    );
  }
}
