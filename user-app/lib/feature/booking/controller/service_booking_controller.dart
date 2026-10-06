import 'package:get/get.dart';
import 'package:jdds/common/models/popup_menu_model.dart';
import 'package:jdds/feature/booking/model/service_availability_model.dart';
import 'package:jdds/feature/booking/widget/provider_available_bottom_sheet.dart';
import 'package:jdds/feature/booking/widget/service_unavailable_dialog.dart';
import 'package:jdds/util/core_export.dart';

enum BookingStatusTabs { all, ongoing, completed, cancelled }

class ServiceBookingController extends GetxController {
  final ServiceBookingRepo serviceBookingRepo;

  ServiceBookingController({required this.serviceBookingRepo});

  List<BookingModel>? bookingList;
  BookingContent? bookingContent;

  BookingStatusTabs selectedBookingStatus = BookingStatusTabs.all;
  ServiceType selectedServiceType = ServiceType.all;

  bool isLoading = false;
  bool isTabLoading = false;
  int rebookIndex = -1;

  String get selectedBookingStatusApiValue => _statusApiValue(selectedBookingStatus);

  String _statusApiValue(BookingStatusTabs status) =>
      status == BookingStatusTabs.cancelled ? 'canceled' : status.name.toLowerCase();

  ServiceAvailabilityModel? serviceAvailability;
  bool isNotAvailable = false;
  bool isPriceChanged = false;

  Future<void> getAllBookingService({
    required int offset,
    required String bookingStatus,
    required bool isFromPagination,
    required String serviceType,
  }) async {
    if (!isFromPagination) {
      isLoading = true;
    }
    update();

    try {
      Response response = await serviceBookingRepo.getBookingList(
        offset: offset,
        bookingStatus: bookingStatus,
        serviceType: serviceType,
      );

      if (response.statusCode == 200 && response.body is Map) {
        final Map<String, dynamic> body = Map<String, dynamic>.from(response.body as Map);

        if (body['content'] is Map || body['content'] is List) {
          final rawContent = body['content'];
          final normalizedBody = Map<String, dynamic>.from(body);
          if (rawContent is List) {
            normalizedBody['content'] = <String, dynamic>{'data': rawContent, 'total': rawContent.length, 'current_page': offset};
          }
          ServiceBookingList serviceBookingList = ServiceBookingList.fromJson(normalizedBody);
          BookingContent? content = serviceBookingList.content;

          if (content != null) {
            content.total ??= content.bookingModel?.length ?? 0;
            content.currentPage ??= offset;
            bookingContent = content;

            List<BookingModel> fetchedBookings = content.bookingModel ?? [];
            if (isFromPagination && bookingList != null) {
              bookingList!.addAll(fetchedBookings);
            } else {
              bookingList = fetchedBookings;
            }
          }
        } else {
          bookingList ??= [];
        }
      } else {
        bookingList ??= [];
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print('getAllBookingService error: $e');
      }
      bookingList ??= [];
    }

    isLoading = false;
    isTabLoading = false;
    update();
  }

  void updateBookingStatusTabs(BookingStatusTabs status, {bool firstTimeCall = true}) {
    selectedBookingStatus = status;
    update();

    if (firstTimeCall) {
      getAllBookingService(
        offset: 1,
        bookingStatus: _statusApiValue(status),
        isFromPagination: false,
        serviceType: selectedServiceType.name,
      );
    }
  }

  void updateSelectedServiceType({ServiceType? type}) {
    selectedServiceType = type ?? ServiceType.all;
    update();

    if (type != null) {
      getAllBookingService(
        offset: 1,
        bookingStatus: selectedBookingStatusApiValue,
        isFromPagination: false,
        serviceType: selectedServiceType.name,
      );
    }
  }

  Future<void> checkCartSubcategory(String bookingId, String subCategoryId) async {
    isLoading = true;
    update();

    final CartController cartController = Get.find<CartController>();
    try {
      await cartController.getCartListFromServer(shouldUpdate: false);
    } catch (e) {
      if (kDebugMode) {
        print('checkCartSubcategory cart fetch error: $e');
      }
    }

    if (cartController.cartList.isNotEmpty &&
        cartController.cartList.first.subCategoryId != subCategoryId) {
      isLoading = false;
      update();

      Get.dialog(ConfirmationDialog(
        icon: Images.warning,
        title: "are_you_sure_to_reset".tr,
        description: 'you_have_service_from_other_sub_category'.tr,
        onYesPressed: () async {
          Get.back();
          Get.dialog(const CustomLoader(), barrierDismissible: false);
          await cartController.removeAllCartItem();
          Get.back();
          await _checkAvailabilityAndRebook(bookingId);
        },
      ));
      return;
    }

    await _checkAvailabilityAndRebook(bookingId);
  }

  Future<void> _checkAvailabilityAndRebook(String bookingId) async {
    isLoading = true;
    update();

    try {
      Response response = await serviceBookingRepo.rebookCheck(bookingId);

      if (response.statusCode == 200 && response.body is Map) {
        serviceAvailability = ServiceAvailabilityModel.fromJson(
          Map<String, dynamic>.from(response.body as Map),
        );

        final content = serviceAvailability?.content;
        final List<Services> services = content?.services ?? [];

        isNotAvailable = services.any((s) => s.isAvailable == 0);
        isPriceChanged = services.any((s) => s.isPriceChanged == 1);
        if (!isNotAvailable && !isPriceChanged && (content?.isServiceInfoUnchanged ?? 1) == 0) {
          isPriceChanged = true;
        }

        isLoading = false;
        update();

        if ((content?.isProviderAvailable ?? 1) == 0) {
          _showRebookWarningSheet(bookingId);
        } else if (isNotAvailable || isPriceChanged) {
          _showServiceIssueDialog(bookingId);
        } else {
          await rebook(bookingId);
        }
        return;
      }

      isLoading = false;
      update();

      if (response.statusCode == 401 || response.statusCode == 403 || response.statusCode == 204) {
        ApiChecker.checkApi(response);
      } else {
        // Availability API unavailable - attempt rebook dtrectly so user is not stuck.
        await rebook(bookingId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('rebook availability check error: $e');
      }
      isLoading = false;
      update();
      await rebook(bookingId);
    }
  }

  void _showRebookWarningSheet(String bookingId) {
    if (ResponsiveHelper.isDesktop(Get.context!)) {
      Get.dialog(Center(child: RebookWarningBottomSheet(bookingId: bookingId)));
    } else {
      Get.bottomSheet(
        RebookWarningBottomSheet(bookingId: bookingId),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
      );
    }
  }

  void _showServiceIssueDialog(String bookingId) {
    final Widget dialog = ServiceUnavailableDialog(
      bookingId: bookingId,
      isPriceChanged: isPriceChanged,
      isNotAvailable: isNotAvailable,
      isAllNotAvailable: checkAllServiceAvailable(serviceAvailability?.content?.services),
    );

    if (ResponsiveHelper.isDesktop(Get.context!)) {
      Get.dialog(Center(child: dialog));
    } else {
      Get.bottomSheet(
        dialog,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
      );
    }
  }

  Future<void> rebook(String bookingId, {bool isBack = false}) async {
    if (isBack) {
      Get.back();
    }

    isLoading = true;
    update();

    try {
      Response response = await serviceBookingRepo.addRebookToServer(bookingId);
      isLoading = false;

      if (response.statusCode == 200) {
        update();
        customSnackBar("successfully_added_to_cart".tr, type: ToasterMessageType.success);
        await Get.find<CartController>().getCartListFromServer();
        Get.toNamed(RouteHelper.getCheckoutRoute('cart', 'orderDetails', 'null'));
      } else {
        update();
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print('rebook error: $e');
      }
      isLoading = false;
      update();
      customSnackBar('error_loading'.tr, type: ToasterMessageType.error);
    }
  }

  bool checkAllServiceAvailable(List<Services>? services) {
    if (services == null || services.isEmpty) return false;
    return services.every((service) => service.isAvailable == 0);
  }

  List<PopupMenuModel> getPopupMenuList({
    required String status,
    required bool isRepeatBooking,
    required bool isCustomizeBooking,
  }) {
    if (status == "completed" || status == "canceled" || status == "cancelled") {
      return [
        PopupMenuModel(title: "booking_details", icon: Icons.remove_red_eye),
        PopupMenuModel(title: "rebook", icon: Icons.repeat),
        PopupMenuModel(title: "download_invoice", icon: Icons.file_download_outlined),
      ];
    }

    return [
      PopupMenuModel(title: "booking_details", icon: Icons.remove_red_eye),
      PopupMenuModel(title: "download_invoice", icon: Icons.file_download_outlined),
      PopupMenuModel(title: "cancel", icon: Icons.cancel_outlined),
    ];
  }

  void updateRebookIndex(int index) {
    rebookIndex = index;
    update();
  }
}



