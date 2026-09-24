import 'package:demandium_serviceman/feature/booking_details/widget/booking_details_widget.dart';
import 'package:demandium_serviceman/feature/booking_details/widget/timeline/connectors.dart';
import 'package:demandium_serviceman/feature/booking_details/widget/timeline/indicator_theme.dart';
import 'package:demandium_serviceman/feature/booking_details/widget/timeline/indicators.dart';
import 'package:demandium_serviceman/feature/booking_details/widget/timeline/timeline_theme.dart';
import 'package:demandium_serviceman/feature/booking_details/widget/timeline/timeline_tile_builder.dart';
import 'package:demandium_serviceman/feature/booking_details/widget/timeline/timelines.dart';
import 'package:demandium_serviceman/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class BookingStatus extends StatelessWidget {
  final String? bookingId;
  const BookingStatus({super.key, this.bookingId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(builder: (bookingDetailsController) {

      final bookingDetailsModel = bookingDetailsController.bookingDetails;
      final bookingDetails = bookingDetailsModel?.bookingContent?.bookingDetailsContent;

      if (bookingDetailsModel == null && bookingDetails == null) {
        return const Center(child: BookingDetailsShimmer());
      } else if (bookingDetailsModel != null && bookingDetails == null) {
        return SizedBox(height: Get.height * 0.7, child: BookingEmptyScreen(bookingId: bookingId));
      } else {
        final statusHistories = bookingDetails!.statusHistories ?? [];
        final scheduleHistories = bookingDetails.scheduleHistories ?? [];

        final bool hasScheduleHistory = scheduleHistories.length > 1;
        final bool hasStatusHistory = statusHistories.isNotEmpty;
        final int increment = (hasScheduleHistory && hasStatusHistory) ? 2 : 1;
        final int itemCount = statusHistories.length + increment;

        return Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: SingleChildScrollView(
            child: Column(children: [
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${'booking_date'.tr} : ',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                  Text(DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate(bookingDetails.createdAt!)),
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${'schedule_date'.tr} : ',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                  if (bookingDetails.serviceSchedule != null)
                    Text(DateConverter.dateMonthYearTime(DateTime.tryParse(bookingDetails.serviceSchedule!)),
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                      textDirection: TextDirection.ltr,
                    ),
                ],
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),
              RichText(
                text: TextSpan(
                  text: '${'payment_status'.tr} ',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge!.color),
                  children: [
                    TextSpan(
                      text: bookingDetails.isPaid == 1 ? 'paid'.tr : 'unpaid'.tr,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault,
                          color: bookingDetails.isPaid == 1 ? Colors.green : Theme.of(context).colorScheme.error,
                          decoration: TextDecoration.none),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),
              RichText(
                text: TextSpan(
                  text: '${'booking_status'.tr}:   ',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge!.color),
                  children: [
                    TextSpan(
                      text: bookingDetails.bookingStatus!.tr,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault,
                          color: context.customThemeColors.buttonTextColorMap[bookingDetails.bookingStatus],
                          decoration: TextDecoration.none),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),
              if (itemCount > 0 && statusHistories.isNotEmpty)
                Timeline1(
                  bookingDetailsContent: bookingDetails,
                  statusHistories: statusHistories,
                  scheduleHistories: scheduleHistories,
                  increment: increment,
                ),

              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            ]),
          ),
        );
      }
    });
  }
}


class Timeline1 extends StatelessWidget {
  final BookingDetailsContent? bookingDetailsContent;
  final List<StatusHistories> statusHistories;
  final List<ScheduleHistories> scheduleHistories;
  final int increment;
  const Timeline1({
    super.key,
    required this.statusHistories,
    required this.scheduleHistories,
    required this.increment,
    this.bookingDetailsContent,
  });

  @override
  Widget build(BuildContext context) {
    final int itemCount = statusHistories.length + increment;

    return Timeline.tileBuilder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      theme: TimelineThemeData(
        nodePosition: 0,
        indicatorTheme: const IndicatorThemeData(position: 0, size: 30.0),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 20.0,
        horizontal: Get.find<LocalizationController>().isLtr ? 0 : 10,
      ),
      builder: TimelineTileBuilder.connected(
        connectionDirection: ConnectionDirection.before,
        itemCount: itemCount,
        contentsBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 20.0, top: 7, right: 10),
            child: _buildContent(context, index, itemCount),
          );
        },
        connectorBuilder: (_, index, _) => SolidLineConnector(color: Theme.of(context).primaryColor),
        indicatorBuilder: (_, index) {
          return DotIndicator(
            color: Theme.of(context).primaryColor,
            child: Center(child: Icon(Icons.check, color: light.cardColor)),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, int index, int itemCount) {
    if (index == 0) {
      final hasSchedule = scheduleHistories.isNotEmpty;
      final user = hasSchedule ? scheduleHistories[0].user : null;
      final name = user != null
          ? "${user.firstName ?? ''} ${user.lastName ?? ''}".trim()
          : "customer".tr;
      final date = hasSchedule && scheduleHistories[0].createdAt != null
          ? DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate(scheduleHistories[0].createdAt!))
          : "";

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${'booking_placed_by'.tr} $name",
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          if (date.isNotEmpty)
            Text(date,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).secondaryHeaderColor,
              ),
              textDirection: TextDirection.ltr,
            ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        ],
      );
    } else if (index == 1 && statusHistories.isNotEmpty) {
      final history = statusHistories[index - 1];
      final isProviderAdmin = history.user?.userType == 'provider-admin';
      final name = isProviderAdmin
          ? (bookingDetailsContent?.provider?.companyName ?? bookingDetailsContent?.subBooking?.provider?.companyName ?? '')
          : "${history.user?.firstName ?? ''} ${history.user?.lastName ?? ''}".trim();
      final date = history.updatedAt != null
          ? DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate(history.updatedAt!))
          : "";

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${'booking'.tr} ${history.bookingStatus.toString().tr.toLowerCase()} ${'by'.tr} ${history.user?.userType.toString().tr} ",
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(name,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).secondaryHeaderColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          if (date.isNotEmpty)
            Text(date,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).secondaryHeaderColor),
              textDirection: TextDirection.ltr,
            ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],
      );
    } else if (index == 2 && scheduleHistories.length > 1) {
      return SizedBox(
        height: (scheduleHistories.length - 1) * 80,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: scheduleHistories.length - 1,
          itemBuilder: (_, listIndex) {
            final history = scheduleHistories[listIndex + 1];
            final isProviderAdmin = history.user?.userType == 'provider-admin';
            final name = isProviderAdmin
                ? (bookingDetailsContent?.provider?.companyName ?? '')
                : "${history.user?.firstName ?? ''} ${history.user?.lastName ?? ''}".trim();
            final date = history.schedule != null
                ? DateConverter.dateMonthYearTime(DateTime.tryParse(history.schedule!))
                : "";

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${'booking_schedule_changed_by'.tr} ${history.user?.userType.toString().tr}",
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Text(name,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).secondaryHeaderColor),
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                if (date.isNotEmpty)
                  Text(date,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).secondaryHeaderColor),
                    textDirection: TextDirection.ltr,
                  ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              ],
            );
          },
        ),
      );
    } else {
      final adjustedIndex = index - increment;
      if (adjustedIndex < 0 || adjustedIndex >= statusHistories.length) {
        return const SizedBox();
      }
      final history = statusHistories[adjustedIndex];
      final isProviderAdmin = history.user?.userType == 'provider-admin';
      final name = isProviderAdmin
          ? (bookingDetailsContent?.provider?.companyName ?? bookingDetailsContent?.subBooking?.provider?.companyName ?? '')
          : "${history.user?.firstName ?? ''} ${history.user?.lastName ?? ''}".trim();
      final date = history.updatedAt != null
          ? DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate(history.updatedAt!))
          : "";

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${'booking'.tr} ${history.bookingStatus.toString().tr.toLowerCase()} ${'by'.tr} ${history.user?.userType.toString().tr} ",
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(name,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).secondaryHeaderColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          if (date.isNotEmpty)
            Text(date,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).secondaryHeaderColor),
              textDirection: TextDirection.ltr,
            ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],
      );
    }
  }
}
