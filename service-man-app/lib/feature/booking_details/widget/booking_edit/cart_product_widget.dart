import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';


class CartServiceWidget extends StatelessWidget {
  final CartModel? cart;
  final int cartIndex;
  final bool disableQuantityButton;
  final bool isSubBooking;

  const CartServiceWidget({
    super.key,
    required this.cart,
    required this.cartIndex, required this.disableQuantityButton, required this.isSubBooking,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingEditController>(builder: (bookingEditController){

      final Widget item = CartItemView(
        bookingEditController: bookingEditController,
        cart: cart,
        cartIndex: cartIndex,
        disableQuantityButton: disableQuantityButton,
        isSubBooking: isSubBooking,
      );

      if(bookingEditController.cartList.length > 1 && !isSubBooking){
        final bool isLtr = Get.find<LocalizationController>().isLtr;
        return Dismissible(
          key: UniqueKey(),
          onDismissed: (DismissDirection direction) => bookingEditController.removeCartItem(cartIndex),
          background: Container(
            alignment: isLtr ? Alignment.centerRight : Alignment.centerLeft,
            padding: EdgeInsets.only(right: isLtr ? 20 : 0, left: isLtr ? 0 : 20),
            decoration: BoxDecoration(
              color: context.kDestructive.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(kRadiusMd),
            ),
            child: Icon(Icons.delete_outline_rounded, color: context.kDestructive, size: 22),
          ),
          child: item,
        );
      }
      return item;
    });
  }
}

class CartItemView extends StatelessWidget {
  final BookingEditController bookingEditController;
  final CartModel? cart;
  final int cartIndex;
  final bool disableQuantityButton;
  final bool isSubBooking;
  const CartItemView({super.key, required this.bookingEditController, this.cart, required this.cartIndex, required this.disableQuantityButton, required this.isSubBooking});

  @override
  Widget build(BuildContext context) {

    final bool canRemove = bookingEditController.cartList.length > 1 && !isSubBooking;
    final String variant = cart?.variantKey ?? '';
    final String price = PriceConverter.convertPrice(double.tryParse(cart?.totalCost?.toString() ?? "0"));
    final String subtitle = variant.isNotEmpty ? '$variant · $price' : price;

    return KCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text( cart?.serviceName ?? "",
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: context.kForeground),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text( subtitle,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: context.kMutedForeground),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
        ),

        if(!disableQuantityButton) ...[
          const SizedBox(height: 16),
          Row(children: [
            QuantityButton(
              isIncrement: false,
              onTap: (cart?.quantity ?? 0) > 1 ? () {
                bookingEditController.updateCartItemQuantity( cart!, cartIndex, increment: false);
              } : null,
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 24,
              child: Text(cart?.quantity.toString() ?? "1",
                textAlign: TextAlign.center,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: context.kForeground),
              ),
            ),
            const SizedBox(width: 12),
            QuantityButton(
              isIncrement: true,
              onTap: () {
                bookingEditController.updateCartItemQuantity( cart!, cartIndex, increment: true);
              },
            ),
            const Spacer(),
            if (canRemove)
              InkWell(
                onTap: () {
                  Get.dialog(
                    ConfirmationDialog(icon: Images.servicemanDelete, description: 'are_you_sure_to_delete_this_service'.tr,
                        isLogOut: true,
                        onYesPressed: () {
                          bookingEditController.removeCartItem(cartIndex);
                          Get.back();
                        }),
                    useSafeArea: false,
                  );
                },
                borderRadius: BorderRadius.circular(kRadiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.close_rounded, size: 14, color: context.kDestructive),
                    const SizedBox(width: 4),
                    Text('remove'.tr, style: robotoMedium.copyWith(fontSize: 12, color: context.kDestructive)),
                  ]),
                ),
              ),
          ]),
        ],
      ]),
    );
  }
}
