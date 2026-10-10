import 'package:jassdbx_provider/feature/notifications/model/notofication_model.dart';
import 'package:jassdbx_provider/feature/notifications/widget/notification_shimmer.dart';
import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';


class NotificationScreen extends StatefulWidget {
  final String? fromNotificationPage;
  const NotificationScreen({super.key,this.fromNotificationPage});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<NotificationController>().getNotifications(1, reload: true);
  }

  void _onBack() {
    if (widget.fromNotificationPage == "notification") {
      Get.offAllNamed(RouteHelper.getInitialRoute());
    } else if (Navigator.canPop(Get.context!)) {
      Get.back();
    } else {
      Get.offNamed(RouteHelper.initial);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        backgroundColor: InkColors.background,
        body: SafeArea(
          child: GetBuilder<NotificationController>(builder: (controller) {

            final int unseenCount = controller.unseenNotificationCount;
            final bool isLoading = controller.notificationModel == null;

            final List<Data> items = [];
            for (final group in controller.notificationList) {
              if (group is List) {
                items.addAll(group.whereType<Data>());
              }
            }

            return Column(
              children: [

                InkTopBar(
                  title: "Notifications",
                  subtitle: isLoading ? null : (unseenCount > 0 ? "$unseenCount unseen" : null),
                  onBack: _onBack,
                ),

                Expanded(
                  child: isLoading ? const NotificationShimmer() : items.isEmpty ?

                  Center(
                    child: NoDataScreen(text: 'empty_notifications'.tr, type: NoDataType.notification),
                  ) :

                  RefreshIndicator(
              color: InkColors.foreground,
              backgroundColor: InkColors.card,
              onRefresh: () async {
                controller.getNotifications(1);
              },
              child: ListView(
                controller: controller.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [

                  InkCard(
                    padding: EdgeInsets.zero,
                    child: items.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'empty_notifications'.tr,
                              textAlign: TextAlign.center,
                              style: robotoRegular.copyWith(fontSize: 13, color: InkColors.mutedForeground),
                            ),
                          )
                        : Column(
                            children: List.generate(items.length, (index) {
                              final Data notification = items[index];
                              final bool unseen = index < unseenCount;

                              return Column(
                                children: [
                                  if (index != 0)  Divider(height: 1, color: InkColors.border),
                                  InkWell(
                                    onTap: () => showDialog(
                                      context: context,
                                      builder: (ctx) => ImageDialog(
                                        imageUrl: '${notification.coverImageFullPath}',
                                        title: notification.title.toString().trim(),
                                        subTitle: "${notification.description}",
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Container(
                                            height: 36,
                                            width: 36,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: unseen ? InkColors.foreground : InkColors.card,
                                              border: unseen ? null : Border.all(color: InkColors.border),
                                            ),
                                            child: Icon(
                                              Icons.notifications_none_rounded,
                                              size: 16,
                                              color: unseen ? InkColors.background : InkColors.mutedForeground,
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  notification.title.toString().trim(),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: robotoSemiBold.copyWith(
                                                    fontSize: 13.5,
                                                    height: 1.3,
                                                    color: InkColors.foreground,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  "${notification.description}",
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: robotoRegular.copyWith(
                                                    fontSize: 12,
                                                    height: 1.3,
                                                    color: InkColors.mutedForeground,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          if (notification.createdAt != null)
                                            Text(
                                              DateConverter.convertStringTimeOnly(
                                                  DateConverter.isoUtcStringToLocalDate(notification.createdAt!)),
                                              style: robotoRegular.copyWith(
                                                fontSize: 10.5,
                                                height: 1.3,
                                                color: InkColors.mutedForeground,
                                              ),
                                              textDirection: TextDirection.ltr,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                  ),

                  if (controller.paginationLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
