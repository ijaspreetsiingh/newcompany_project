import 'package:jassdbx_provider/feature/serviceman/view/serviceman_details.dart';
import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class ServicemanCardView extends StatelessWidget {
  final ServicemanModel? serviceman;
  final int index;
  const ServicemanCardView({super.key, this.serviceman, required this.index});

  Future<void> _openMenu(BuildContext context, ServicemanSetupController servicemanController) async {

    final bool isTrial = await Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet();
    if(!isTrial || !context.mounted) return;

    final RenderBox menuBox = context.findRenderObject() as RenderBox;
    final Offset offset = menuBox.localToGlobal(Offset.zero);
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final String? action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx - 140,
        offset.dy + menuBox.size.height + 6,
        overlay.size.width - (offset.dx + menuBox.size.width),
        overlay.size.height - (offset.dy + menuBox.size.height),
      ),
      items: [
        PopupMenuItem(value: 'edit', child: Text('edit'.tr, style: robotoRegular)),
        PopupMenuItem(value: 'delete', child: Text('delete'.tr, style: robotoRegular)),
        PopupMenuItem(
          value: 'status',
          child: Text(serviceman?.isActive == 1 ? 'inactive'.tr : "Active", style: robotoRegular),
        ),
      ],
    );

    if(action == null) return;

    if(action == 'edit'){
      servicemanController.clearImageData();
      servicemanController.resetOtherValidationData();
      servicemanController.updateTabControllerValue(ServicemanTabControllerState.generalInfo);
      servicemanController.controller!.index = 0;
      servicemanController.getSingleServicemanData(index: index, fromPage: 'editPage');
      Get.to(()=>const AddNewServicemanScreen(isEditScreen: true));

    }else if(action == 'delete'){
      showCustomDialog(child: ConfirmationDialog(
        title: "delete_this_service_man".tr,
        icon: Images.servicemanImage,
        description: 'this_operation_cannot_be_undone'.tr,
        onYesPressed: () async{
          Get.back();
          showCustomDialog(child: const CustomLoader());
          await servicemanController.deleteServiceman(servicemanController.servicemanList![index].serviceman!.id!);
        },
        onNoPressed: () {
          servicemanController.updateIndex(-1);
          Get.back();
        },
      ), barrierDismissible: true);

    }else if(action == 'status'){
      servicemanController.changeServicemanStatus(index, servicemanController.servicemanList![index].serviceman!.id!);
      Get.find<DashboardController>().getDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServicemanSetupController>(builder: (servicemanController){

      final bool isActive = serviceman?.isActive == 1;
      final String name = "${serviceman?.firstName ?? ""} ${serviceman?.lastName ?? ""}".trim();
      final String phone = serviceman?.phone ?? "";

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkCard(
          padding: const EdgeInsets.all(16),
          onTap: (){
            servicemanController.updateIndex(-1);
            Get.to(()=> ServicemanDetails(id: servicemanController.servicemanList![index].serviceman!.id!, fromDashboard: false,));
          },
          child: Row(children: [

            InkAvatar(name: name, size: 46),

            const SizedBox(width: 12),

            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style:  TextStyle(fontSize: 14, height: 1.3, fontWeight: FontWeight.w700, color: InkColors.foreground),
                ),
                if(phone.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(phone, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style:  TextStyle(fontSize: 11.5, height: 1.3, color: InkColors.mutedForeground),
                  ),
                ],
              ]),
            ),

            const SizedBox(width: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: InkColors.border),
              ),
              child: Text(isActive ? "ON DUTY" : "OFF DUTY",
                style: TextStyle(
                  fontSize: 10,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isActive ? InkColors.foreground : InkColors.mutedForeground,
                ),
              ),
            ),

            const SizedBox(width: 2),

            Builder(builder: (menuContext) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openMenu(menuContext, servicemanController),
              child:  Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.more_vert_rounded, size: 18, color: InkColors.mutedForeground),
              ),
            )),

          ]),
        ),
      );
    });
  }
}
