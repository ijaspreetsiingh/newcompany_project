import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/nest_shared.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';

/// nest. style booking success screen (reference: designnew SuccessScreen)
/// Black check mark â†’ BOOKING CONFtrMED â†’ bold headline â†’ booking ticket card
/// â†’ Track booking (black) + Back to home (outline)
class OrderSuccessfulScreen extends StatelessWidget {
  final int? status;
  final String? bookingId;
  const OrderSuccessfulScreen({super.key, this.status, this.bookingId}) ;

  @override
  Widget build(BuildContext context) {
    final bool isSuccess = status == 1;
    final bool isDark = Get.isDarkMode;

    return CustomPopWidget(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
        drawer: ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,
        endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
        body: FooterBaseView(
          isCenter: true,
          child: WebShadowWrap(
            child: Center(child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [

                  /// nest. success mark : black circle + white check
                  Container(
                    height: 84, width: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSuccess
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
                    child: Icon(
                      isSuccess ? Icons.check_rounded : Icons.close_rounded,
                      size: 42,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  /// Eyebrow
                  Text(
                    isSuccess ? 'BOOKING CONFtrMED' : 'BOOKING FAILED',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      letterSpacing: 1.6,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  /// Bold headline
                  Text(
                    isSuccess ? 'You placed the booking successfully!'.tr : 'your_bookings_is_failed_to_place'.tr,
                    textAlign: TextAlign.center,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeOverLarge + 4,
                      height: 1.2,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text(
                    isSuccess ? 'your_order_is_placed_successfully'.tr : 'you_can_try_again_later'.tr,
                    textAlign: TextAlign.center,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  /// AUTO-ASSIGN: provider find hone tak polling card (API logic intact)
                  if (isSuccess && bookingId != null && bookingId!.isNotEmpty) ...[
                    BookingFindingProviderWidget(bookingId: bookingId!),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],

                  /// nest. booking ticket card
                  if (isSuccess && bookingId != null && bookingId!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorLight,
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('BOOKING ID', style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          letterSpacing: 1.2,
                          color: Theme.of(context).hintColor,
                        )),
                        const SizedBox(height: 4),
                        Text('#$bookingId', style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        )),
                      ]),
                    ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  /// Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    child: NestButton(
                      label: 'back_to_home'.tr,
                      icon: Icons.home_outlined,
                      onTap: () {
                        Get.offAllNamed(RouteHelper.getMainRoute("home"));
                      },
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    child: NestButton(
                      label: 'bookings'.tr,
                      isOutlined: true,
                      onTap: () {
                        Get.offAllNamed(RouteHelper.getBookingScreenRoute(true));
                      },
                    ),
                  ),
                ]),
              ),
            ))),
          ),
        ),
    );
  }
}

