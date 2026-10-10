import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class BookingHelper{
  /// Service address + home details (house / floor / street / zip).
  /// Details empty hone par bilkul wahi base address (legacy) return hota hai.
  static String composeServiceAddress(ServiceAddress? address, {String fallback = ''}) {
    if (address == null) return fallback;

    String clean(String? value) {
      final String text = (value ?? '').trim();
      return (text.isEmpty || text == 'null') ? '' : text;
    }

    final String base = clean(address.address);
    final List<String> details = [
      if (clean(address.house).isNotEmpty) '${'house'.tr} ${clean(address.house)}',
      if (clean(address.floor).isNotEmpty) '${'floor'.tr} ${clean(address.floor)}',
      if (clean(address.street).isNotEmpty) '${'street'.tr} ${clean(address.street)}',
      if (clean(address.zipCode).isNotEmpty) clean(address.zipCode),
    ];

    if (base.isEmpty && details.isEmpty) return fallback;
    return <String>[
      if (base.isNotEmpty) base,
      ...details,
    ].join(', ');
  }

  static double getSubTotalCost(BookingDetailsContent booking) {
    double subTotal = 0;
    for (var element in booking.details!) {
      subTotal = subTotal + ((element.serviceCost ?? 1) * (element.quantity ?? 1));
    }
    return subTotal;
  }

  static double getBookingServiceUnitConst(ItemService? item) {
    return  (item?.serviceCost ?? 0) * (item?.quantity ?? 1);
  }

}