import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/feature/review/controller/submit_review_controller.dart';
import 'package:jdds/feature/review/repo/submit_review_repo.dart';
import 'package:jdds/feature/service/model/service_review_model.dart';
import 'package:google_fonts/google_fonts.dart';

/// Booking details ke andar har service ke reviews dikhata hai:
/// provider name, serviceman name, rating aur comment.
class BookingReviewsSection extends StatefulWidget {
  final String bookingId;
  final String fallbackProviderName;
  final String fallbackServicemanName;

  const BookingReviewsSection({
    super.key,
    required this.bookingId,
    this.fallbackProviderName = '',
    this.fallbackServicemanName = '',
  });

  @override
  State<BookingReviewsSection> createState() => _BookingReviewsSectionState();
}

class _BookingReviewsSectionState extends State<BookingReviewsSection> {
  @override
  void initState() {
    super.initState();
    _ensureReviewController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.bookingId.isEmpty) return;
      final reviewController = Get.find<SubmitReviewController>();
      if (reviewController.loadedBookingId != widget.bookingId) {
        reviewController.getReviewList(widget.bookingId);
      }
    });
  }

  void _ensureReviewController() {
    if (Get.isRegistered<SubmitReviewController>()) return;
    Get.put(
      SubmitReviewController(
        submitReviewRepo: SubmitReviewRepo(
          apiClient: Get.find(),
          sharedPreferences: Get.find(),
        ),
      ),
      permanent: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);
    final bgColor = isDark ? const Color(0xFF171717) : Colors.white;
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);
    final iconBgColor = isDark ? const Color(0xFF262626) : const Color(0xFFF6F6F6);

    return GetBuilder<SubmitReviewController>(
      builder: (reviewController) {
        if (reviewController.loadedBookingId != widget.bookingId) {
          return const SizedBox();
        }

        final services = (reviewController.serviceReviewList ?? [])
            .where((service) => (service.review ?? []).isNotEmpty)
            .toList();

        if (services.isEmpty) {
          return const SizedBox();
        }

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Container(
                    height: 32,
                    width: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: iconBgColor,
                    ),
                    child: Icon(Icons.reviews_rounded, size: 16, color: primaryColor),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'reviews'.tr,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              ...services.map(
                (service) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name ?? '',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(service.review ?? []).map(
                        (review) => _ReviewTile(
                          review: review,
                          fallbackProviderName: widget.fallbackProviderName,
                          fallbackServicemanName: widget.fallbackServicemanName,
                          primaryColor: primaryColor,
                          mutedColor: mutedColor,
                          borderColor: borderColor,
                          iconBgColor: iconBgColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;
  final String fallbackProviderName;
  final String fallbackServicemanName;
  final Color primaryColor;
  final Color mutedColor;
  final Color borderColor;
  final Color iconBgColor;

  const _ReviewTile({
    required this.review,
    required this.fallbackProviderName,
    required this.fallbackServicemanName,
    required this.primaryColor,
    required this.mutedColor,
    required this.borderColor,
    required this.iconBgColor,
  });

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    final int rating = review.reviewRating ?? 0;
    final String providerName =
        (review.provider?.companyName ?? '').isNotEmpty
            ? review.provider?.companyName ?? fallbackProviderName
            : fallbackProviderName;
    final String servicemanName =
        (review.servicemanName ?? '').isNotEmpty
            ? review.servicemanName ?? fallbackServicemanName
            : fallbackServicemanName;
    final String date = _formatDate(review.createdAt);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB900)),
                  const SizedBox(width: 4),
                  Text(
                    '$rating/5',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              if (date.isNotEmpty)
                Text(
                  date,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: mutedColor,
                  ),
                ),
            ],
          ),
          if ((review.reviewComment ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              review.reviewComment?.trim() ?? '',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: primaryColor,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (providerName.isNotEmpty || servicemanName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    height: 22,
                    width: 22,
                    child: (review.servicemanImage ?? '').isNotEmpty
                        ? Image.network(
                            review.servicemanImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.person_rounded, size: 22, color: Color(0xFF7D7D7D)),
                          )
                        : const Icon(Icons.person_rounded, size: 22, color: Color(0xFF7D7D7D)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    [
                      if (providerName.isNotEmpty) '${'provider'.tr}: $providerName',
                      if (servicemanName.isNotEmpty) '${'serviceman'.tr}: $servicemanName',
                    ].join('  •  '),
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: mutedColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
