import 'package:demandium_provider/common/widgets/circular_icon_button_widget.dart';
import 'package:demandium_provider/helper/help_me.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color color;
  final bool fromBookingRequest;
  final double? titleFontSize;
  const MainAppBar({
    super.key,
    this.title,
    required this.color,
    this.fromBookingRequest = false,
    this.titleFontSize,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Get.isDarkMode;

    return GetBuilder<NotificationController>(
      builder: (notificationController) {
        return GetBuilder<SplashController>(
          builder: (splashController) {
            List<String> bookingFilterList = [
              'all_booking',
              "regular_booking",
              "repeat_booking",
            ];

            return AppBar(
              elevation: 0,
              titleSpacing: 0,
              surfaceTintColor: Colors.transparent,
              backgroundColor: isDark
                  ? Theme.of(context).cardColor.withValues(alpha: 0.2)
                  : Theme.of(context).scaffoldBackgroundColor,
              shape: Border(
                bottom: BorderSide(
                  width: 0.4,
                  color: Theme.of(
                    context,
                  ).primaryColorLight.withValues(alpha: 0.2),
                ),
              ),
              leading: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall + 3,
                  vertical: Dimensions.paddingSizeExtraSmall,
                ),
                child: Image.asset(Images.appbarLogo, fit: BoxFit.fitWidth),
              ),
              title: title != null
                  ? Text(
                      title!.tr,
                      style: robotoBold.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize:
                            titleFontSize ?? Dimensions.fontSizeExtraLarge,
                      ),
                    )
                  : Image.asset(Images.logo, width: 110),
              actions: [
                if (fromBookingRequest)
                  InkWell(
                    onTap: () {
                      Get.toNamed(RouteHelper.getCalendarOrderRoute());
                    },
                    child: Container(
                      height: 36,
                      width: 36,
                      margin: const EdgeInsets.only(
                        right: Dimensions.paddingSizeExtraSmall,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? Theme.of(
                                  context,
                                ).primaryColorLight.withValues(alpha: 0.3)
                              : const Color(0xFFE9EAEC),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.calendar_month_rounded,
                        size: 20,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                if (fromBookingRequest &&
                    Get.find<SplashController>()
                            .configModel
                            .content
                            ?.biddingStatus ==
                        1)
                  Row(
                    children: [
                      GetBuilder<BookingRequestController>(
                        builder: (bookingRequestController) {
                          return PopupMenuButton<String>(
                            shape: RoundedRectangleBorder(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(Dimensions.radiusDefault),
                              ),
                              side: BorderSide(
                                color: Theme.of(
                                  context,
                                ).hintColor.withValues(alpha: 0.1),
                              ),
                            ),
                            surfaceTintColor: Theme.of(context).cardColor,
                            position: PopupMenuPosition.under,
                            elevation: 8,
                            shadowColor: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.3),
                            padding: EdgeInsets.zero,
                            menuPadding: EdgeInsets.zero,
                            itemBuilder: (BuildContext context) {
                              return bookingFilterList.map((String option) {
                                ServiceType type = option == "regular_booking"
                                    ? ServiceType.regular
                                    : option == "repeat_booking"
                                    ? ServiceType.repeat
                                    : ServiceType.all;
                                return PopupMenuItem<String>(
                                  value: option,
                                  padding: EdgeInsets.zero,
                                  height: 45,
                                  child:
                                      bookingRequestController
                                              .selectedServiceType ==
                                          type
                                      ? Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withValues(
                                                  alpha: Get.isDarkMode
                                                      ? 0.2
                                                      : 0.08,
                                                ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeDefault,
                                            vertical: 12,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                option.tr,
                                                style: robotoRegular.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeDefault,
                                          ),
                                          child: Text(
                                            option.tr,
                                            style: robotoRegular,
                                          ),
                                        ),
                                  onTap: () {
                                    bookingRequestController
                                        .updateSelectedServiceType(
                                          type: option == "regular_booking"
                                              ? ServiceType.regular
                                              : option == "repeat_booking"
                                              ? ServiceType.repeat
                                              : ServiceType.all,
                                        );
                                  },
                                );
                              }).toList();
                            },
                            child: CircularIconButtonWidget(
                              icon: Icons.filter_list,
                              showIndicator:
                                  bookingRequestController
                                      .selectedServiceType !=
                                  ServiceType.all,
                            ),
                          );
                        },
                      ),
                      GestureDetector(
                        onTap: () => Get.find<BusinessSubscriptionController>()
                            .openTrialEndBottomSheet()
                            .then((isTrial) {
                              if (isTrial) {
                                if (Get.find<UserProfileController>()
                                    .checkAvailableFeatureInSubscriptionPlan(
                                      featureType: 'bidding',
                                    )) {
                                  Get.to(
                                    () => const CustomerRequestListScreen(),
                                  );
                                }
                              }
                            }),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                          ),
                          child: Image.asset(
                            splashController.showRedDotIconForCustomBooking
                                ? Images.createPostIconWithRedDot
                                : Images.createPostIconWithoutDot,
                            height: 35,
                            width: 35,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Container(
                        height: 36,
                        width: 36,
                        margin: const EdgeInsets.only(
                          right: Dimensions.paddingSizeExtraSmall,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? Theme.of(
                                    context,
                                  ).primaryColorLight.withValues(alpha: 0.3)
                                : const Color(0xFFE9EAEC),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if (isRedundentClick(DateTime.now())) {
                              return;
                            }
                            Get.toNamed(RouteHelper.getInboxScreenRoute());
                          },
                          icon: Icon(
                            Icons.chat_bubble_outline,
                            size: 18,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                      ),
                      GetBuilder<NotificationController>(
                        builder: (controller) {
                          return Container(
                            height: 36,
                            width: 36,
                            margin: const EdgeInsets.only(
                              right: Dimensions.paddingSizeSmall,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? Theme.of(
                                        context,
                                      ).primaryColorLight.withValues(alpha: 0.3)
                                    : const Color(0xFFE9EAEC),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    if (isRedundentClick(DateTime.now())) {
                                      return;
                                    }
                                    Get.toNamed(
                                      RouteHelper.getNotificationRoute(),
                                    );
                                    controller.resetNotificationCount();
                                  },
                                  icon: Icon(
                                    Icons.notifications_outlined,
                                    size: 20,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge!.color,
                                  ),
                                ),
                                if (controller.unseenNotificationCount > 0)
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2563EB),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        controller.unseenNotificationCount
                                            .toString(),
                                        style: robotoBold.copyWith(
                                          fontSize: 8,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 55);
}
