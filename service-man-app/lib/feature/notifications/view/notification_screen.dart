import 'package:demandium_serviceman/common/widgets/no_data_screen.dart';
import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key}) ;
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  @override
  void initState() {
    super.initState();
    Get.find<NotificationController>().getNotifications(1,reload: true);
  }

  void _onBackPressed() {
    if (Navigator.canPop(context)) {
      Get.back();
    } else {
      Get.offAllNamed(RouteHelper.getInitialRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        backgroundColor: context.kBackground,
        body: GetBuilder<NotificationController>(
          builder: (controller) {
            return Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: PageHeader(
                    title: "notifications".tr,
                    subtitle:
                        '${controller.allNotificationList.length} ${'notifications_count'.tr}',
                    onBack: _onBackPressed,
                    right: KIconButton(
                      icon: Icons.refresh_rounded,
                      onTap: () {
                        Get.find<NotificationController>().getNotifications(1);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      Get.find<NotificationController>().getNotifications(1);
                    },
                    child: controller.notificationModel == null
                        ? const NotificationShimmer()
                        : controller.dateList.isEmpty
                            ? NoDataScreen(
                                text: 'empty_notifications'.tr,
                                type: NoDataType.notification,
                              )
                            : CustomScrollView(
                                controller: controller.scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeLarge),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (int index0 = 0;
                                              index0 <
                                                  controller.dateList.length;
                                              index0++) ...[
                                            if (index0 != 0)
                                              const SizedBox(height: 24),
                                            Text(
                                              controller.dateList[index0]
                                                  .toUpperCase(),
                                              textDirection: TextDirection.ltr,
                                              style: robotoBold.copyWith(
                                                fontSize: 12,
                                                letterSpacing: 0.5,
                                                color:
                                                    context.kMutedForeground,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Column(
                                              children: [
                                                for (int index1 = 0;
                                                    index1 <
                                                        controller
                                                            .notificationList[
                                                                index0]
                                                            .length;
                                                    index1++) ...[
                                                  if (index1 != 0)
                                                    Divider(
                                                      height: 1,
                                                      thickness: 1,
                                                      color: context.kBorder,
                                                    ),
                                                  _notificationRow(context,
                                                      controller
                                                              .notificationList[
                                                          index0][index1]),
                                                ],
                                              ],
                                            ),
                                          ],
                                          controller.isLoading
                                              ? const CircularProgressIndicator()
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraLarge),
                                  ),
                                ],
                              ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _notificationRow(BuildContext context, dynamic notification) {
    final String imageUrl = '${notification.coverImageFullPath}';
    final bool hasImage = imageUrl.isNotEmpty && imageUrl != 'null';

    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (ctx) => NotificationDialog(
                  title: notification.title.toString().trim(),
                  subTitle: "${notification.description}",
                  imageUrl: imageUrl,
                ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: context.kMuted,
                borderRadius: BorderRadius.circular(kRadiusMd),
              ),
              child: hasImage
                  ? CustomImage(
                      image: imageUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      Icons.notifications_outlined,
                      size: 20,
                      color: context.kMutedForeground,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title.toString().trim(),
                    style: robotoMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.kForeground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${notification.description}",
                    style: robotoRegular.copyWith(
                      fontSize: 12,
                      color: context.kMutedForeground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              DateConverter.convertStringTimeToDate(
                  DateConverter.isoUtcStringToLocalDate(notification.createdAt)),
              style: robotoRegular.copyWith(
                fontSize: 10,
                color: context.kMutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
