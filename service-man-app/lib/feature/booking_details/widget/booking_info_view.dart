import 'package:demandium_serviceman/feature/booking_details/widget/booking_service_location.dart';
import 'package:demandium_serviceman/helper/booking_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class BookingInformationView extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final bool isSubBooking;
  const BookingInformationView({super.key, required this.bookingDetails, required this.isSubBooking});

  @override
  Widget build(BuildContext context) {

    String createdAtText = '';
    if (bookingDetails.createdAt != null) {
      createdAtText = DateConverter.dateMonthYearTime(
          DateConverter.isoUtcStringToLocalDate(bookingDetails.createdAt!));
    }

    String serviceName = '';
    if (bookingDetails.details != null && bookingDetails.details!.isNotEmpty) {
      serviceName = bookingDetails.details!.first.service?.name ??
          bookingDetails.details!.first.serviceName ??
          '';
    }

    final String contactPersonName = bookingDetails.serviceAddress?.contactPersonName ??
        bookingDetails.subBooking?.serviceAddress?.contactPersonName ??
        "${bookingDetails.customer?.firstName ?? ""} ${bookingDetails.customer?.lastName ?? ""}";
    final String contactPersonNumber = bookingDetails.serviceAddress?.contactPersonNumber ??
        bookingDetails.subBooking?.serviceAddress?.contactPersonNumber ??
        bookingDetails.customer?.phone ??
        bookingDetails.customer?.email ??
        "";

    final DateTime? scheduleAt = bookingDetails.serviceSchedule != null
        ? DateTime.tryParse(bookingDetails.serviceSchedule!)
        : null;
    final String scheduleText = scheduleAt != null
        ? DateConverter.dateMonthYearTime(scheduleAt)
        : createdAtText;

    final String address = bookingDetails.serviceLocation == "customer"
        ? BookingHelper.composeServiceAddress(
            bookingDetails.serviceAddress ?? bookingDetails.subBooking?.serviceAddress,
            fallback: 'address_not_found'.tr,
          )
        : bookingDetails.provider?.companyAddress ??
            bookingDetails.subBooking?.provider?.companyAddress ??
            'address_not_found'.tr;

    final bool isPartial = bookingDetails.partialPayments != null &&
        bookingDetails.partialPayments!.isNotEmpty;
    final String paidLabel = isPartial && bookingDetails.isPaid == 0
        ? "partially_paid".tr
        : bookingDetails.isPaid == 0
            ? "unpaid".tr
            : "paid".tr;

    final List<InfoRow> paymentRows = [
      InfoRow(
        Icons.account_balance_wallet_outlined,
        "${bookingDetails.paymentMethod?.tr ?? ""}${isPartial ? " &_wallet_balance".tr : ""}",
      ),
      InfoRow(
        Icons.currency_rupee_rounded,
        "${PriceConverter.convertPrice(bookingDetails.totalBookingAmount ?? 0, isShowLongPrice: true)} · $paidLabel",
      ),
      if (bookingDetails.paymentMethod != "cash_after_service" &&
          bookingDetails.paymentMethod != "offline_payment")
        InfoRow(Icons.receipt_long_outlined,
            "${'transaction_id'.tr} : ${bookingDetails.transactionId}"),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.kPrimary,
            borderRadius: BorderRadius.circular(kRadiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusBadge(status: bookingDetails.bookingStatus ?? ""),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: Text(
                    serviceName.isNotEmpty ? serviceName : '${'booking'.tr} # ${bookingDetails.readableId}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(
                        fontSize: 20, color: context.kPrimaryForeground),
                  ),
                ),
                if (isSubBooking) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(color: context.kSuccess, shape: BoxShape.circle),
                    child: const Icon(Icons.repeat_rounded, size: 12, color: Colors.white),
                  ),
                ],
              ]),
              const SizedBox(height: 4),
              Text(
                createdAtText.isNotEmpty
                    ? "${'booking_date'.tr} : $createdAtText"
                    : '-',
                textDirection: TextDirection.ltr,
                style: robotoRegular.copyWith(
                    fontSize: 14,
                    color: context.kPrimaryForeground.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        InfoCard(
          title: 'customer_info'.tr,
          rows: [
            InfoRow(Icons.person_outline_rounded, contactPersonName),
            InfoRow(Icons.call_outlined, contactPersonNumber),
          ],
        ),

        const SizedBox(height: 16),

        InfoCard(
          title: 'schedule_address'.tr,
          rows: [
            InfoRow(Icons.schedule_rounded, scheduleText),
            InfoRow(Icons.location_on_outlined, address),
          ],
        ),

        const SizedBox(height: 16),

        InfoCard(title: 'payment'.tr, rows: paymentRows),

        const SizedBox(height: 16),

        Row(children: [
          Expanded(
            child: KButton(
              label: 'call_customer'.tr,
              icon: Icons.call_outlined,
              outline: true,
              onTap: contactPersonNumber.isNotEmpty
                  ? () => launchUrl(Uri.parse('tel:$contactPersonNumber'))
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: KButton(
              label: 'directions'.tr,
              icon: Icons.directions,
              onTap: () => BookingServiceLocation.openDirections(bookingDetails),
            ),
          ),
        ]),

        const SizedBox(height: 16),

        BookingServiceLocation(bookingDetails: bookingDetails, isSubBooking: isSubBooking),
      ],
    );
  }
}
