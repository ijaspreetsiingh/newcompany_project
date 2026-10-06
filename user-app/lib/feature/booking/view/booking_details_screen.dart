import 'dart:convert';
import 'package:jdds/common/models/popup_menu_model.dart';
import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:jdds/feature/booking/view/web_booking_details_screen.dart';
import 'package:jdds/feature/checkout/model/payment_response_model.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdds/feature/booking/widget/booking_tracking_details_view.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String? bookingID;
  final String? subBookingId;
  final String? phone;
  final String? fromPage;
  final String? token;
  const BookingDetailsScreen({
    super.key,
    this.bookingID,
    this.fromPage,
    this.phone,
    this.subBookingId,
    this.token,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen>
    with SingleTickerProviderStateMixin {
  final scaffoldState = GlobalKey<ScaffoldState>();
  TabController? tabController;
  bool isSubBooking = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: BookingDetailsTabs.values.length,
      vsync: this,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    if (_isValidToken(widget.token)) {
      String transactionId = _extractTransactionId(widget.token!);
      PaymentResponseModel? paymentResponse =
          await Get.find<CheckOutController>().getDigitalPaymentResponse(
            transactionId: transactionId,
          );

      if (_hasBookingRepeatId(paymentResponse) != null) {
        Get.find<BookingDetailsController>().getSubBookingDetails(
          bookingId: _hasBookingRepeatId(paymentResponse) ?? "",
        );
        setState(() {
          isSubBooking = true;
        });
      } else if (_hasBookingId(paymentResponse) != null) {
        Get.find<BookingDetailsController>().getBookingDetails(
          bookingId: _hasBookingId(paymentResponse) ?? "",
        );
        setState(() {
          isSubBooking = false;
        });
      }
    } else {
      if (_hasValidBookingId(widget.bookingID, widget.subBookingId)) {
        isSubBooking =
            widget.subBookingId != null && widget.subBookingId != "null";

        if (widget.fromPage == "track-booking") {
          Get.find<BookingDetailsController>().trackBookingDetails(
            widget.bookingID ?? "",
            "+${widget.phone?.trim()}",
            reload: false,
          );
        } else if (isSubBooking) {
          Get.find<BookingDetailsController>().getSubBookingDetails(
            bookingId: widget.subBookingId ?? "",
          );
        } else {
          Get.find<BookingDetailsController>().getBookingDetails(
            bookingId: widget.bookingID ?? "",
          );
        }
      }
    }
  }

  bool _isValidToken(String? token) {
    if (token == null || token == "null" || token.isEmpty) return false;
    String transactionReference = StringParser.parseString(
      utf8.decode(base64Url.decode(token)),
      "transaction_reference",
    );
    return transactionReference.isNotEmpty;
  }

  String _extractTransactionId(String token) {
    return StringParser.parseString(
      utf8.decode(base64Url.decode(token)),
      "transaction_reference",
    );
  }

  String? _hasBookingRepeatId(PaymentResponseModel? response) {
    return response?.content?.bookingRepeatId;
  }

  String? _hasBookingId(PaymentResponseModel? response) {
    return response?.content?.bookingId;
  }

  bool _hasValidBookingId(String? bookingID, String? subBookingId) {
    return bookingID != null || subBookingId != null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? const Color(0xFFF1F1F1)
        : const Color(0xFF141414);
    final mutedColor = isDark
        ? const Color(0xFFB3B3B3)
        : const Color(0xFF7D7D7D);
    final bgColor = isDark ? const Color(0xFF0D0D0D) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF333333)
        : const Color(0xFFE5E5E5);

    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor),
            onPressed: () {
              if (widget.fromPage == 'fromNotification') {
                Get.offAllNamed(RouteHelper.getinitialRoute());
              } else {
                if (Navigator.canPop(context)) {
                  Get.back();
                } else {
                  Get.offAllNamed(RouteHelper.getinitialRoute());
                }
              }
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "booking_details".tr,
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
          ),
          actions: [
            GetBuilder<BookingDetailsController>(
              builder: (bookingDetailsController) {
                BookingDetailsContent? bookingDetailsContent = isSubBooking
                    ? bookingDetailsController.subBookingDetailsContent
                    : bookingDetailsController.bookingDetailsContent;

                if (bookingDetailsContent != null) {
                  return bookingDetailsContent.bookingStatus == "pending"
                      ? PopupMenuButton<PopupMenuModel>(
                          shape: RoundedRectangleBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16),
                            ),
                            side: BorderSide(color: borderColor),
                          ),
                          surfaceTintColor: bgColor,
                          position: PopupMenuPosition.under,
                          elevation: 8,
                          shadowColor: mutedColor.withValues(alpha: 0.3),
                          padding: EdgeInsets.zero,
                          menuPadding: EdgeInsets.zero,
                          itemBuilder: (BuildContext context) {
                            return bookingDetailsController
                                .getPopupMenuList(
                                  bookingDetailsContent.bookingStatus ?? "",
                                )
                                .map((PopupMenuModel option) {
                                  return PopupMenuItem<PopupMenuModel>(
                                    value: option,
                                    padding: EdgeInsets.zero,
                                    height: 45,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        option.title.tr,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      if (option.title == "download_invoice") {
                                        String languageCode =
                                            Get.find<LocalizationController>()
                                                .locale
                                                .languageCode;
                                        String uri =
                                            "${AppConstants.baseUrl}${isSubBooking ? AppConstants.singleRepeatBookingInvoiceUrl : AppConstants.regularBookingInvoiceUrl}${bookingDetailsContent.id}/$languageCode";
                                        if (kDebugMode) {
                                          print("Uri : $uri");
                                        }
                                        await _launchUrl(Uri.parse(uri));
                                      } else if (option.title == "cancel") {
                                        Get.dialog(
                                          ConfirmationDialog(
                                            icon: Images.deleteProfile,
                                            title:
                                                'are_you_sure_to_cancel_this_full_booking'
                                                    .tr,
                                            description:
                                                'once_cancel_full_booking'.tr,
                                            noButtonText: "yes_cancel".tr,
                                            noButtonColor: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            noTextColor: Colors.white,
                                            yesButtonText: "not_now".tr,
                                            yesButtonColor: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                            yesTextColor: Colors.white,
                                            onYesPressed: () {
                                              Get.back();
                                            },
                                            onNoPressed: () async {
                                              Get.back();
                                              Get.dialog(
                                                const CustomLoader(),
                                                barrierDismissible: false,
                                              );
                                              if (isSubBooking) {
                                                await bookingDetailsController
                                                    .subBookingCancel(
                                                      subBookingId:
                                                          bookingDetailsContent
                                                              .id ??
                                                          "",
                                                    );
                                              } else {
                                                await bookingDetailsController
                                                    .bookingCancel(
                                                      bookingId:
                                                          bookingDetailsContent
                                                              .id ??
                                                          "",
                                                    );
                                              }

                                              Get.back();
                                            },
                                          ),
                                          useSafeArea: false,
                                        );
                                      }
                                    },
                                  );
                                })
                                .toList();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(
                              Icons.more_vert_sharp,
                              color: mutedColor,
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: () async {
                            String languageCode =
                                Get.find<LocalizationController>()
                                    .locale
                                    .languageCode;
                            String uri =
                                "${AppConstants.baseUrl}${isSubBooking ? AppConstants.singleRepeatBookingInvoiceUrl : AppConstants.regularBookingInvoiceUrl}${bookingDetailsContent.id}/$languageCode";
                            if (kDebugMode) {
                              print("Uri : $uri");
                            }
                            await _launchUrl(Uri.parse(uri));
                          },
                          icon: Icon(
                            Icons.file_download_outlined,
                            color: mutedColor,
                          ),
                        );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ],
        ),

        body:
            widget.bookingID == null &&
                widget.subBookingId == null &&
                widget.token == null
            ? const NoDataScreen(
                text: "no_data_found",
                type: NoDataType.bookings,
              )
            : ResponsiveHelper.isDesktop(context)
            ? WebBookingDetailsScreen(
                isSubBooking: isSubBooking,
                id: isSubBooking ? widget.subBookingId : widget.bookingID,
                tabController: tabController,
              )
            : BookingTrackingDetailsView(
                bookingId: isSubBooking
                    ? widget.subBookingId
                    : widget.bookingID,
                isSubBooking: isSubBooking,
              ),
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}

class BookingTabBar extends StatelessWidget {
  final TabController? tabController;
  final bool isSubBooking;
  const BookingTabBar({
    super.key,
    this.tabController,
    required this.isSubBooking,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      builder: (bookingDetailsTabsController) {
        return Container(
          width: Dimensions.webMaxWidth,
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Row(
            children: [
              Expanded(
                child: GetBuilder<BookingDetailsController>(
                  builder: (segmentController) {
                    Widget segmentedControl(int selectedIndex) {
                      return Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Get.isDarkMode
                              ? Theme.of(context).scaffoldBackgroundColor
                              : Theme.of(
                                  context,
                                ).hintColor.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusExtraLarge,
                          ),
                        ),
                        child: Row(
                          children: [
                            _BookingSegmentItem(
                              title: 'booking_details'.tr,
                              isSelected: selectedIndex == 0,
                              onTap: () {
                                if (tabController != null) {
                                  tabController!.animateTo(0);
                                }
                                bookingDetailsTabsController
                                    .updateBookingStatusTabs(
                                      BookingDetailsTabs.bookingDetails,
                                    );
                              },
                            ),
                            const SizedBox(width: 4),
                            _BookingSegmentItem(
                              title: 'status'.tr,
                              isSelected: selectedIndex == 1,
                              onTap: () {
                                if (tabController != null) {
                                  tabController!.animateTo(1);
                                }
                                bookingDetailsTabsController
                                    .updateBookingStatusTabs(
                                      BookingDetailsTabs.status,
                                    );
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    final TabController? tc = tabController;
                    return tc == null
                        ? segmentedControl(0)
                        : AnimatedBuilder(
                            animation: tc,
                            builder: (context, _) => segmentedControl(tc.index),
                          );
                  },
                ),
              ),

              !ResponsiveHelper.isDesktop(context)
                  ? const SizedBox()
                  : GetBuilder<BookingDetailsController>(
                      builder: (bookingDetailsController) {
                        BookingDetailsContent? bookingDetailsContent =
                            isSubBooking
                            ? bookingDetailsTabsController
                                  .subBookingDetailsContent
                            : bookingDetailsTabsController
                                  .bookingDetailsContent;

                        return bookingDetailsContent != null
                            ? Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: InkWell(
                                        onTap: () async {
                                          String languageCode =
                                              Get.find<LocalizationController>()
                                                  .locale
                                                  .languageCode;
                                          String uri =
                                              "${AppConstants.baseUrl}${isSubBooking ? AppConstants.singleRepeatBookingInvoiceUrl : AppConstants.regularBookingInvoiceUrl}${bookingDetailsContent.id}/$languageCode";
                                          if (kDebugMode) {
                                            print("Uri : $uri");
                                          }
                                          await _launchUrl(Uri.parse(uri));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeSmall,
                                            vertical:
                                                Dimensions.paddingSizeEight,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusDefault,
                                            ),
                                            border: Border.all(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                "invoice".tr,
                                                style: robotoMedium.copyWith(
                                                  color: Get.isDarkMode
                                                      ? Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.color
                                                      : Theme.of(
                                                          context,
                                                        ).colorScheme.primary,
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                ),
                                              ),
                                              const SizedBox(
                                                width:
                                                    Dimensions.paddingSizeSmall,
                                              ),

                                              SizedBox(
                                                height: 15,
                                                width: 15,
                                                child: Image.asset(
                                                  Images.downloadImage,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      width: Dimensions.paddingSizeSmall,
                                    ),

                                    Get.find<AuthController>().isLoggedIn() &&
                                            ((bookingDetailsContent
                                                            .bookingStatus ==
                                                        "completed" &&
                                                    !isSubBooking &&
                                                    !(bookingDetailsContent
                                                            .isCustomizeBooking ??
                                                        false)) ||
                                                bookingDetailsContent
                                                        .bookingStatus ==
                                                    "pending")
                                        ? GetBuilder<ServiceBookingController>(
                                            builder: (serviceBookingController) {
                                              return InkWell(
                                                onTap: () {
                                                  if (bookingDetailsContent
                                                          .bookingStatus ==
                                                      "completed") {
                                                    serviceBookingController
                                                        .checkCartSubcategory(
                                                          bookingDetailsContent
                                                              .id!,
                                                          bookingDetailsContent
                                                              .subCategoryId!,
                                                        );
                                                  } else {
                                                    Get.dialog(
                                                      ConfirmationDialog(
                                                        icon: Images.warning,
                                                        title:
                                                            'are_you_sure_to_cancel_your_order'
                                                                .tr,
                                                        description:
                                                            'your_order_will_be_cancel'
                                                                .tr,
                                                        noButtonText:
                                                            "yes_cancel".tr,
                                                        noButtonColor: Theme.of(
                                                          context,
                                                        ).colorScheme.primary,
                                                        noTextColor:
                                                            Colors.white,
                                                        yesButtonText:
                                                            "not_now".tr,
                                                        yesButtonColor:
                                                            Theme.of(
                                                              context,
                                                            ).colorScheme.error,
                                                        yesTextColor:
                                                            Colors.white,
                                                        buttonFontSize:
                                                            Dimensions
                                                                .fontSizeSmall +
                                                            1,
                                                        onNoPressed: () async {
                                                          Get.back();
                                                          Get.dialog(
                                                            const CustomLoader(),
                                                            barrierDismissible:
                                                                false,
                                                          );
                                                          if (isSubBooking) {
                                                            await bookingDetailsController
                                                                .subBookingCancel(
                                                                  subBookingId:
                                                                      bookingDetailsContent
                                                                          .id ??
                                                                      "",
                                                                );
                                                          } else {
                                                            await bookingDetailsController
                                                                .bookingCancel(
                                                                  bookingId:
                                                                      bookingDetailsContent
                                                                          .id ??
                                                                      "",
                                                                );
                                                          }
                                                          Get.back();
                                                        },
                                                        onYesPressed: () =>
                                                            Get.back(),
                                                      ),
                                                      useSafeArea: false,
                                                    );
                                                  }
                                                },

                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Dimensions
                                                              .radiusDefault,
                                                        ),
                                                    border: Border.all(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                    ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: Dimensions
                                                            .paddingSizeEight,
                                                        horizontal: Dimensions
                                                            .paddingSizeLarge,
                                                      ),
                                                  child:
                                                      (serviceBookingController
                                                          .isLoading)
                                                      ? Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: Dimensions
                                                                .paddingSizeDefault,
                                                          ),
                                                          child: SizedBox(
                                                            height: 15,
                                                            width: 15,
                                                            child: CircularProgressIndicator(
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .onPrimary,
                                                            ),
                                                          ),
                                                        )
                                                      : Text(
                                                          bookingDetailsContent
                                                                      .bookingStatus ==
                                                                  "completed"
                                                              ? "rebook".tr
                                                              : "cancel_booking"
                                                                    .tr,
                                                          style: robotoMedium.copyWith(
                                                            color:
                                                                Get.isDarkMode
                                                                ? Theme.of(
                                                                        context,
                                                                      )
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color
                                                                : Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .onPrimary,
                                                          ),
                                                        ),
                                                ),
                                              );
                                            },
                                          )
                                        : const SizedBox(),

                                    bookingDetailsContent.bookingStatus ==
                                                "completed" &&
                                            !isSubBooking &&
                                            Get.find<AuthController>()
                                                .isLoggedIn()
                                        ? InkWell(
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                useRootNavigator: true,
                                                isScrollControlled: true,
                                                backgroundColor:
                                                    Colors.transparent,
                                                builder: (context) =>
                                                    ReviewRecommendationDialog(
                                                      id: bookingDetailsContent
                                                          .id!,
                                                    ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimensions.radiusDefault,
                                                    ),
                                                border: Border.all(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                              ),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .paddingSizeSmall,
                                                  ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: Dimensions
                                                        .paddingSizeEight,
                                                    horizontal: Dimensions
                                                        .paddingSizeLarge,
                                                  ),
                                              child: Text(
                                                "review".tr,
                                                style: robotoMedium.copyWith(
                                                  color: Get.isDarkMode
                                                      ? Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.color
                                                      : Theme.of(
                                                          context,
                                                        ).colorScheme.onPrimary,
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              )
                            : const SizedBox();
                      },
                    ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}

class _BookingSegmentItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  const _BookingSegmentItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Theme.of(context).colorScheme.primary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: isSelected
              ? BoxDecoration(
                  /// nest. style : flat black active segment
                  color: activeColor,
                  borderRadius: BorderRadius.circular(
                    Dimensions.radiusExtraLarge,
                  ),
                )
              : BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    Dimensions.radiusExtraLarge,
                  ),
                ),
          child: Text(
            title,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: isSelected ? Colors.white : Theme.of(context).hintColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}



