import 'package:jassdbx_provider/feature/serviceman/view/serviceman_details.dart';
import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class ServiceManSection extends StatelessWidget {
  const ServiceManSection({super.key});

  void _openServiceManList() =>
      Get.toNamed(RouteHelper.serviceManSetup);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        final List<DashboardServicemanModel> serviceMen =
            dashboardController.dashboardServicemanList;
        final bool isEmpty = serviceMen.isEmpty;

        return InkSection(
          title: 'Service men'.tr,
          action: isEmpty ? 'add_new_service_man'.tr : 'View all'.tr,
          onAction: _openServiceManList,
          child: isEmpty
              ? InkEmptyState('no_data_found'.tr)
              : SizedBox(
                  height: 164,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: serviceMen.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final DashboardServicemanModel serviceman =
                          serviceMen[index];
                      final String firstName = serviceman.user?.firstName ?? '';
                      final String lastName = serviceman.user?.lastName ?? '';
                      final String name = '$firstName $lastName'.trim();
                      final int completedBookings =
                          serviceman.bookingsCount?.completed ?? 0;
                      final bool isActive = serviceman.user?.isActive == 1;

                      return SizedBox(
                        height: 164,
                        width: 150,
                        child: InkCard(
                          onTap: () {
                            final String id = serviceman.id ?? '';
                            if (id.isEmpty) return;
                            Get.to(
                              () => ServicemanDetails(
                                id: id,
                                fromDashboard: true,
                              ),
                            );
                          },
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(23),
                                child: CustomImage(
                                  height: 46,
                                  width: 46,
                                  fit: BoxFit.cover,
                                  image:
                                      serviceman.user?.profileImageFullPath ?? '',
                                  placeholder: Images.userPlaceHolder,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: robotoBold.copyWith(
                                  fontSize: 13,
                                  height: 1.3,
                                  color: InkColors.foreground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$completedBookings ${'bookings'.tr}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(
                                  fontSize: 11,
                                  color: InkColors.mutedForeground,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ServicemanStatusPill(isActive: isActive),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}
