import 'package:demandium_provider/feature/custom_post/model/post_model.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class RecentActivityListView extends StatelessWidget {
  const RecentActivityListView({super.key});

  void _openBooking(DashboardRecentActivityModel booking) {
    if (booking.isRepeatBooking == 1) {
      Get.toNamed(
        RouteHelper.getRepeatBookingDetailsRoute(bookingId: booking.id),
      );
    } else {
      Get.toNamed(RouteHelper.getBookingDetailsRoute(bookingId: booking.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        if (dashboardController.showNormalBooking) {
          final List<DashboardRecentActivityModel> bookings = dashboardController
              .dashboardRecentActivityList
              .take(3)
              .toList();

          if (bookings.isEmpty) {
            return const _CenteredMessage(text: 'you_have_no_normal_request');
          }

          return Column(
            children: [
              for (int i = 0; i < bookings.length; i++)
                RecentActivityCardItem(
                  dashboardRecentActivityModel: bookings[i],
                  showDivider: i != bookings.length - 1,
                  onTap: () => _openBooking(bookings[i]),
                ),
            ],
          );
        }

        final List<PostData> posts = dashboardController.dashboardCustomizedPostList;
        if (posts.isEmpty) {
          return const _CenteredMessage(text: 'you_have_no_customizes_request');
        }

        return Column(
          children: [
            for (int i = 0; i < posts.length; i++)
              _CustomPostRow(post: posts[i], showDivider: i != posts.length - 1),
          ],
        );
      },
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final String text;
  const _CenteredMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Text(
        text.tr,
        textAlign: TextAlign.center,
        style: robotoRegular.copyWith(
          fontSize: 13,
          height: 1.5,
          color: InkColors.mutedForeground,
        ),
      ),
    );
  }
}

class _CustomPostRow extends StatelessWidget {
  final PostData post;
  final bool showDivider;

  const _CustomPostRow({required this.post, required this.showDivider});

  Future<void> _placeOffer() async {
    final bool isTrial = await Get.find<BusinessSubscriptionController>()
        .openTrialEndBottomSheet();
    if (!isTrial) return;

    final bool hasFeature = Get.find<UserProfileController>()
        .checkAvailableFeatureInSubscriptionPlan(featureType: 'bidding');
    if (hasFeature) {
      await Get.to(
        () => CustomerPostDetailsScreen(
          postData: post,
          fromNotification: true,
          fromDashboard: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String serviceName = post.service?.name ?? '';
    final String subCategoryName = post.subCategory?.name ?? '';
    final DateTime? createdAt = post.createdAt == null
        ? null
        : DateConverter.isoUtcStringToLocalDate(post.createdAt!);
    final String dateLabel = createdAt == null
        ? ''
        : DateConverter.dateStringMonthYear(createdAt, format: 'd MMM');
    final String meta = [
      if (subCategoryName.isNotEmpty) subCategoryName,
      if (dateLabel.isNotEmpty) dateLabel,
    ].join(' · ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _placeOffer,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: showDivider
                ?  Border(bottom: BorderSide(color: InkColors.border))
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkAvatar(name: serviceName, size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      serviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoSemiBold.copyWith(
                        fontSize: 13.5,
                        height: 1.3,
                        color: InkColors.foreground,
                      ),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(
                          fontSize: 11.5,
                          height: 1.3,
                          color: InkColors.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: InkColors.foreground,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  'place_offer'.tr,
                  style: robotoSemiBold.copyWith(
                    fontSize: 11,
                    color: InkColors.background,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
