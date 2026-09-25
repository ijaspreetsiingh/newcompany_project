import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

/// AUTO-ASSIGN: booking place hone ke baad "Finding provider..." state,
/// aur provider milne par provider details card.
///
/// Usage:
///   Get.put(BookingStatusPollingController(bookingDetailsRepo: Get.find()));
///   BookingFindingProviderWidget(bookingId: bookingId)
class BookingFindingProviderWidget extends StatefulWidget {
  final String bookingId;
  const BookingFindingProviderWidget({super.key, required this.bookingId});

  @override
  State<BookingFindingProviderWidget> createState() => _BookingFindingProviderWidgetState();
}

class _BookingFindingProviderWidgetState extends State<BookingFindingProviderWidget> {
  @override
  void initState() {
    super.initState();

    final BookingStatusPollingController controller = Get.put(BookingStatusPollingController(
      bookingDetailsRepo: Get.find(),
    ));

    controller.onProviderFound((booking) {
      if (mounted) setState(() {});
    });
    controller.startPolling(widget.bookingId);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingStatusPollingController>(builder: (controller) {
      return controller.providerFound && controller.bookingDetails != null
          ? _ProviderFoundCard(bookingDetails: controller.bookingDetails!)
          : _FindingProviderCard(controller: controller);
    });
  }
}

class _FindingProviderCard extends StatelessWidget {
  final BookingStatusPollingController controller;
  const _FindingProviderCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        Text('finding_provider'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(
          'finding_provider_hint'.tr,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).hintColor,
          ),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}

class _ProviderFoundCard extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const _ProviderFoundCard({required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    final provider = bookingDetails.provider;

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.check_circle, color: Colors.green, size: 24),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Text('provider_found'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
        ]),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: CustomImage(
              height: 60, width: 60, fit: BoxFit.cover,
              image: provider?.logoFullPath ?? '',
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(provider?.companyName ?? '', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Row(children: [
                Icon(Icons.star, color: Colors.orange, size: 16),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text('${provider?.avgRating ?? 0} (${provider?.ratingCount ?? 0})', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
              ]),
            ]),
          ),
        ]),

        const SizedBox(height: Dimensions.paddingSizeDefault),

        Row(children: [
          Expanded(
            child: CustomButton(
              buttonText: 'view_booking'.tr,
              onPressed: () => Get.toNamed(RouteHelper.getBookingDetailsScreen(bookingID: bookingDetails.id ?? '')),
            ),
          ),
        ]),
      ]),
    );
  }
}
