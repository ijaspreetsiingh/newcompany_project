import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:jdds/common/widgets/image_dialog.dart';
import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';
import 'package:jdds/feature/notification/widget/notification_shimmer.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';

/// nest. Notifications screen (reference: designnew NotificationsScreen)
/// page-header + "Read all" · date-label · .notification rows
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        drawer:
            ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,
        endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
        backgroundColor: NestInk.background,
        appBar: CustomAppBar(
          title: "notifications".tr,
          bgColor: NestInk.background,
          isBackButtonExist: true,
          actionWidget: GetBuilder<NotificationController>(
            builder: (controller) => controller.notificationModel == null
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () {
                      final int total =
                          controller.notificationModel?.content?.total ?? 0;
                      controller.markAllAsRead(total);
                      controller.update();
                      customSnackBar(
                        'All notifications marked as read',
                        type: ToasterMessageType.success,
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Read all',
                      style: NestInk.display(
                        size: 12,
                        weight: FontWeight.w700,
                        color: NestInk.primary,
                      ),
                    ),
                  ),
          ),
        ),
        body: GetBuilder<NotificationController>(
          initState: (state) {
            Get.find<NotificationController>().getNotifications(1);
          },
          builder: (controller) {
            return FooterBaseView(
              isScrollView: true,
              scrollController: scrollController,
              isCenter: controller.notificationList.isEmpty,
              child: WebShadowWrap(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: controller.notificationModel == null
                      ? const NotificationShimmer()
                      : controller.dateList.isEmpty
                          ? NoDataScreen(
                              text: 'no_notification_found'.tr,
                              type: NoDataType.notification,
                            )
                          : PaginatedListView(
                              scrollController: scrollController,
                              totalSize:
                                  controller.notificationModel!.content!.total!,
                              onPaginate: (int offset) async =>
                                  await controller.getNotifications(
                                offset,
                                reload: false,
                              ),
                              offset:
                                  controller.notificationModel?.content?.currentPage,
                              itemView: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (int index0 = 0;
                                        index0 < controller.dateList.length;
                                        index0++) ...[
                                      /// reference `.date-label`
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 22, bottom: 6),
                                        child: Text(
                                          controller.dateList[index0]
                                              .toString()
                                              .toUpperCase(),
                                          style: NestInk.display(
                                            size: 9,
                                            weight: FontWeight.w700,
                                            letterSpacing: 0.6,
                                          ),
                                          textDirection: TextDirection.ltr,
                                        ),
                                      ),
                                      if (controller.notificationList[index0]
                                          .isNotEmpty)
                                        for (int index1 = 0;
                                            index1 <
                                                controller
                                                    .notificationList[index0]
                                                    .length;
                                            index1++)
                                          _NotificationTile(
                                            data: controller
                                                .notificationList[index0][index1],
                                            onTap: () => showDialog(
                                              context: context,
                                              builder: (ctx) => ImageDialog(
                                                imageUrl:
                                                    '${controller.notificationList[index0][index1].coverImageFullPath ?? ""}',
                                                title: controller
                                                    .notificationList[index0]
                                                        [index1]
                                                    .title
                                                    .toString()
                                                    .trim(),
                                                subTitle:
                                                    "${controller.notificationList[index0][index1].description}",
                                              ),
                                            ),
                                          ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// reference `.notification`
class _NotificationTile extends StatelessWidget {
  final dynamic data;
  final VoidCallback? onTap;

  const _NotificationTile({required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String image = (data.coverImageFullPath ?? '').toString();

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 78),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: NestInk.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ink icon tile (40 × 40 · radius 12)
            Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: NestInk.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: image.isNotEmpty
                  ? CustomImage(
                      image: image,
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      Icons.notifications_none_rounded,
                      size: 19,
                      color: NestInk.background,
                    ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (data.title ?? '').toString().trim(),
                    style: NestInk.display(size: 12, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    (data.description ?? '').toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: NestInk.body(
                      size: 10,
                      color: NestInk.mutedText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _timeAgo(data.createdAt),
                    style: NestInk.body(size: 8, color: NestInk.mutedText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(dynamic createdAt) {
    final DateTime? created = DateTime.tryParse(createdAt?.toString() ?? '');
    if (created == null) return '';
    final Duration diff = DateTime.now().difference(created);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 30) return '${diff.inDays} days ago';
    return DateConverter.dateStringMonthYear(created);
  }
}
