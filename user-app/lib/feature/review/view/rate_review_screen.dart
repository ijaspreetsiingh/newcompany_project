import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:jdds/common/widgets/ldashed_line_printer.dart';
import 'package:get/get.dart';
import 'package:jdds/feature/review/controller/submit_review_controller.dart';
import 'package:jdds/feature/review/widgets/select_rating.dart';
import 'package:jdds/util/core_export.dart';
import 'package:readmore/readmore.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';

class RateReviewScreen extends StatefulWidget {
  final String? id;
  const RateReviewScreen({super.key, this.id});

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> {
  bool _isPageLoading = true;
  bool _bookingLoadFailed = false;

  Future<void> _loadData() async {
    if (widget.id == null) {
      if (mounted) setState(() => _isPageLoading = false);
      return;
    }

    if (mounted) {
      setState(() {
        _isPageLoading = true;
        _bookingLoadFailed = false;
      });
    }

    try {
      await Future.wait<void>([
        Get.find<BookingDetailsController>().getBookingDetails(
          bookingId: widget.id!,
          reload: true,
        ),
        Get.find<SubmitReviewController>().getReviewList(widget.id!),
      ]);
      _bookingLoadFailed =
          Get.find<BookingDetailsController>().bookingDetailsContent == null;
    } catch (error, stackTrace) {
      debugPrint('Review page load failed (${widget.id}): $error\n$stackTrace');
      _bookingLoadFailed = true;
    } finally {
      if (mounted) setState(() => _isPageLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,
        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(title: 'review'.tr),
        body: GetBuilder<BookingDetailsController>(
          builder: (bookingController) {
            if (widget.id == null) {
              return const NoDataScreen(
                text: "no_data_found",
                type: NoDataType.bookings,
              );
            } else if (_isPageLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (_bookingLoadFailed ||
                bookingController.bookingDetailsContent == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('error_loading'.tr, textAlign: TextAlign.center),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      TextButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: Text('retry'.tr),
                      ),
                    ],
                  ),
                ),
              );
            } else if (bookingController.bookingDetailsContent != null) {
              return GetBuilder<SubmitReviewController>(
                builder: (submitReviewController) {
                  if (submitReviewController.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return FooterBaseView(
                      child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Booking details card — no banner image above it
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  Dimensions.paddingSizeDefault,
                                  Dimensions.paddingSizeLarge,
                                  Dimensions.paddingSizeDefault,
                                  0,
                                ),
                                child: ReviewBookingDetailsCard(
                                  bookingDetailsContent:
                                      bookingController.bookingDetailsContent!,
                                ),
                              ),

                              const SizedBox(
                                height: Dimensions.paddingSizeLarge,
                              ),

                              // Per-service review items
                              ListView.builder(
                                itemCount:
                                    submitReviewController
                                        .serviceReviewList
                                        ?.length ??
                                    0,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  List<String> variationList = [];
                                  Get.find<BookingDetailsController>()
                                      .bookingDetailsContent!
                                      .bookingDetails
                                      ?.forEach((bookingDetailsItem) {
                                        if (submitReviewController
                                                .serviceReviewList?[index]
                                                .id ==
                                            bookingDetailsItem.serviceId) {
                                          variationList.add(
                                            bookingDetailsItem.variantKey ?? "",
                                          );
                                        }
                                      });
                                  String variations = variationList
                                      .toString()
                                      .replaceAll('[', '')
                                      .replaceAll(']', '');

                                  final Service? serviceItem =
                                      submitReviewController
                                          .serviceReviewList?[index];
                                  if (serviceItem == null)
                                    return const SizedBox();
                                  final bool editable =
                                      submitReviewController
                                          .isEditable[serviceItem.id] ??
                                      true;

                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          ResponsiveHelper.isDesktop(context)
                                          ? 0
                                          : Dimensions.paddingSizeDefault,
                                    ),
                                    child: editable
                                        ? EditableReview(
                                            serviceReview: serviceItem,
                                            index: index,
                                            variations: variations,
                                            bookingId: widget.id,
                                          )
                                        : NonEditableReview(
                                            serviceReview: serviceItem,
                                            index: index,
                                            variations: variations,
                                          ),
                                  );
                                },
                              ),

                              const SizedBox(
                                height: Dimensions.paddingSizeExtraLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

// ─── Booking details card ──────────────────────────────────────────────────────

class ReviewBookingDetailsCard extends StatelessWidget {
  const ReviewBookingDetailsCard({
    super.key,
    required this.bookingDetailsContent,
  });
  final BookingDetailsContent bookingDetailsContent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E5E5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Booking number + total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'booking_no'.tr} # ${bookingDetailsContent.readableId}',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  PriceConverter.convertPrice(
                    bookingDetailsContent.totalBookingAmount!.toDouble(),
                  ),
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          // Date + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateConverter.formatDate(
                  DateConverter.isoUtcStringToLocalDate(
                    bookingDetailsContent.createdAt!,
                  ),
                ),
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.color!.withValues(alpha: 0.5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${bookingDetailsContent.bookingStatus}'.tr,
                  style: robotoMedium.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Editable review card ──────────────────────────────────────────────────────

class EditableReview extends StatefulWidget {
  final Service? serviceReview;
  final int index;
  final String variations;
  final String? bookingId;
  const EditableReview({
    super.key,
    this.serviceReview,
    required this.index,
    required this.variations,
    this.bookingId,
  });

  @override
  State<EditableReview> createState() => _EditableReviewState();
}

class _EditableReviewState extends State<EditableReview> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetBuilder<SubmitReviewController>(
      builder: (submitReviewController) {
        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E5E5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service name
              Text(
                widget.serviceReview?.name ?? '',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),

              // Variation / sub-type
              if (widget.variations.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  widget.variations,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.color!.withValues(alpha: 0.5),
                  ),
                ),
              ],

              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Star rating (left-aligned)
              SelectRating(revivedId: widget.serviceReview!.id!),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              // Review text field
              TextFormField(
                maxLines: 4,
                controller: submitReviewController
                    .textControllers[widget.serviceReview!.id!],
                decoration: InputDecoration(
                  hintText: 'write_your_review'.tr,
                  hintStyle: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Submit button — full width, theme primary color
              SizedBox(
                width: double.maxFinite,
                child: CustomButton(
                  height: 50,
                  radius: 16,
                  isLoading:
                      submitReviewController.selectedIndex == widget.index &&
                      submitReviewController.isLoading,
                  buttonText: 'submit'.tr,
                  onPressed: () {
                    final review = submitReviewController
                        .textControllers[widget.serviceReview!.id!]!
                        .value
                        .text;
                    if (isRedundentClick(DateTime.now())) return;
                    submitReviewController.setIndex(widget.index);
                    final reviewBody = ReviewBody(
                      bookingID: widget.bookingId ?? '',
                      serviceID: widget.serviceReview!.id!,
                      rating: submitReviewController
                          .selectedRating[widget.serviceReview!.id!]
                          .toString(),
                      comment: review,
                    );
                    submitReviewController.submitReview(
                      reviewBody,
                      widget.serviceReview!.id!,
                      review,
                      widget.index,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Non-editable (submitted) review card ─────────────────────────────────────

class NonEditableReview extends StatelessWidget {
  final Service? serviceReview;
  final int index;
  final String variations;
  const NonEditableReview({
    super.key,
    this.serviceReview,
    required this.index,
    required this.variations,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String? reviewReply;
    String updatedAt = '';
    if (serviceReview != null &&
        serviceReview!.review != null &&
        serviceReview!.review!.isNotEmpty &&
        serviceReview!.review!.first.reviewReply != null) {
      reviewReply = serviceReview?.review?.first.reviewReply?.reply;
      updatedAt = serviceReview!.review!.first.reviewReply!.updatedAt!;
    }

    return GetBuilder<SubmitReviewController>(
      builder: (submitReviewController) {
        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E5E5),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service name + checkmark
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          serviceReview?.name ?? '',
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Image.asset(Images.accepted, width: 16),
                    ],
                  ),

                  // Variation
                  if (variations.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      variations,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.color!.withValues(alpha: 0.5),
                      ),
                    ),
                  ],

                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  // Star rating (read-only)
                  SelectRating(revivedId: serviceReview!.id!, clickable: false),

                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  // Submitted review comment
                  if (submitReviewController
                          .reviewComments[serviceReview!.id]
                          ?.isNotEmpty ==
                      true) ...[
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(
                        Dimensions.paddingSizeDefault,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isDark
                            ? const Color(0xFF1E1E1E)
                            : const Color(0xFFF6F6F6),
                      ),
                      child: ReadMoreText(
                        submitReviewController.reviewComments[serviceReview!
                                .id] ??
                            '',
                        trimCollapsedText: 'see_more'.tr,
                        trimExpandedText: '  ${"see_less".tr}',
                        trimMode: TrimMode.Line,
                        trimLines: 3,
                        style: robotoRegular.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyLarge!.color!.withValues(alpha: 0.7),
                          fontSize: Dimensions.fontSizeDefault,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.start,
                        moreStyle: robotoMedium.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        lessStyle: robotoMedium.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),

                    // Provider reply
                    if (reviewReply != null) ...[
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: Dimensions.paddingSizeEight),
                          CustomPaint(
                            size: const Size(20, 50),
                            painter: LDashedLinePainter(),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF2E2E2E)
                                      : const Color(0xFFE5E5E5),
                                ),
                              ),
                              padding: const EdgeInsets.all(
                                Dimensions.paddingSizeDefault,
                              ),
                              margin: const EdgeInsets.only(
                                top: Dimensions.paddingSizeSmall,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            Images.reviewReply,
                                            width: 22,
                                          ),
                                          const SizedBox(
                                            width: Dimensions.paddingSizeSmall,
                                          ),
                                          Text(
                                            'replied_by_provider'.tr,
                                            style: robotoRegular,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        DateConverter.dateStringMonthYear(
                                          DateConverter.isoUtcStringToLocalDate(
                                            updatedAt,
                                          ),
                                        ),
                                        style: robotoRegular.copyWith(
                                          color: Theme.of(context).hintColor,
                                          fontSize:
                                              Dimensions.fontSizeSmall + 1,
                                        ),
                                        textDirection: TextDirection.ltr,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  ReadMoreText(
                                    reviewReply,
                                    trimCollapsedText: 'see_more'.tr,
                                    trimExpandedText: '  ${"see_less".tr}',
                                    trimMode: TrimMode.Line,
                                    trimLines: 3,
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withValues(alpha: 0.6),
                                      fontSize: Dimensions.fontSizeSmall,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.start,
                                    moreStyle: robotoMedium.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    lessStyle: robotoMedium.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],

                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],
              ),

              // Edit button (top-right / top-left based on locale)
              Positioned(
                right: Get.find<LocalizationController>().isLtr ? 0 : null,
                left: Get.find<LocalizationController>().isLtr ? null : 0,
                top: 0,
                child: IconButton(
                  onPressed: () {
                    Get.find<SubmitReviewController>().updateEditableValue(
                      serviceReview!.id!,
                      true,
                      isUpdate: true,
                    );
                  },
                  icon: Image.asset(Images.edit, width: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
