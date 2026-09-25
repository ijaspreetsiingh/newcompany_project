import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:jdds/common/widgets/image_dialog.dart';
import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';
import 'package:jdds/feature/notification/widget/notification_shimmer.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key}) ;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  /// Soft pastel colors for notification icon tiles - SS-3 style
  static const List<Color> _tileColors = [
    Color(0xFF6B5CE7),
    Color(0xFFE94B6A),
    Color(0xFFF5B93D),
    Color(0xFF2BB673),
    Color(0xFF4A90D9),
    Color(0xFFF26B22),
  ];

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    bool isDark = Get.isDarkMode;

    return CustomPopWidget(
      child: Scaffold(
          drawer: ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,
          endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar(title: "notifications".tr, isBackButtonExist: true,),
          body: GetBuilder<NotificationController>(
            initState: (state){
              Get.find<NotificationController>().getNotifications(1);
            },
            builder: (controller) {
              return FooterBaseView(
                  isScrollView:true,
                  scrollController: scrollController,
                  isCenter: Get.find<NotificationController>().notificationList.isEmpty ? true:false,
                  child: WebShadowWrap(
                    child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: controller.notificationModel == null ? const NotificationShimmer() :
                      controller.notificationModel != null && controller.dateList.isEmpty ?
                      NoDataScreen(text: 'no_notification_found'.tr,type: NoDataType.notification,):
                      PaginatedListView(
                        scrollController: scrollController,
                        totalSize: controller.notificationModel!.content!.total!,
                        onPaginate: (int offset) async => await controller.getNotifications(
                          offset,
                          reload: false,
                        ),
                        offset: controller.notificationModel?.content?.currentPage,

                        itemView: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                          itemBuilder: (context, index0) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                /// Date header - SS exact (bold, dark)
                                Padding(padding:  const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeExtraSmall,
                                  vertical: Dimensions.paddingSizeSmall,
                                ),
                                  child: Text(
                                    Get.find<NotificationController>().dateList[index0].toString(),
                                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge,
                                        color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.85)),
                                    textDirection: TextDirection.ltr,
                                  ),
                                ),

                                if(controller.notificationList.isNotEmpty)
                                  ListView.builder(
                                    itemBuilder: (context, index1) {
                                      return InkWell(
                                        onTap: () => showDialog(context: context, builder: (ctx)  =>
                                          ImageDialog(
                                            imageUrl:'${controller.notificationList[index0][index1].coverImageFullPath ?? ""}',
                                            title: controller.notificationList[index0][index1].title.toString().trim(),
                                            subTitle: "${controller.notificationList[index0][index1].description}",
                                          )
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                                            boxShadow: isDark ? null : [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.04),
                                                blurRadius: 12,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [

                                              /// Colorful icon tile - SS-3 exact
                                              Container(
                                                height: 46, width: 46,
                                                decoration: BoxDecoration(
                                                  color: _tileColors[(index0 + index1) % _tileColors.length],
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                                alignment: Alignment.center,
                                                child: (controller.notificationList[index0][index1].coverImageFullPath ?? "").toString().isNotEmpty
                                                    ? ClipRRect(
                                                        borderRadius: BorderRadius.circular(14),
                                                        child: CustomImage(
                                                          image: '${controller.notificationList[index0][index1].coverImageFullPath}',
                                                          height: 46, width: 46, fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : Icon(Icons.notifications_rounded, color: Colors.white, size: 22),
                                              ),
                                              const SizedBox(width: Dimensions.paddingSizeDefault),

                                              /// Title + Description
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(controller.notificationList[index0][index1].title.toString().trim(),
                                                        style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color,
                                                            fontSize: Dimensions.fontSizeDefault
                                                        )),
                                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
                                                    Text("${controller.notificationList[index0][index1].description ?? ""}",
                                                        maxLines: 2,
                                                        style: robotoRegular.copyWith(color: Theme.of(context).hintColor,
                                                            fontSize: Dimensions.fontSizeSmall
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: controller.notificationList[index0].length,
                                  )
                              ],
                            );
                          },
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.dateList.length,
                        ),
                      ),
                    ),
                  )
              );
            },
          )),
    );
  }
}
