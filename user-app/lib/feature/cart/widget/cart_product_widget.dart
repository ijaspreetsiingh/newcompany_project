import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class CartServiceWidget extends StatelessWidget {
  final CartModel cart;
  final int cartIndex;
  const CartServiceWidget({super.key, required this.cart, required this.cartIndex});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? const Color(0xFFF1F1F1) : const Color(0xFF111111);
    final muted = dark ? const Color(0xFFB3B3B3) : const Color(0xFF777777);
    final line = dark ? const Color(0xFF333333) : const Color(0xFFE2E2E2);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Slidable(
        key: ValueKey(cart.id),
        endActionPane: ActionPane(motion: const ScrollMotion(), extentRatio: .22, children: [
          CustomSlidableAction(
            onPressed: (_) async => Get.find<CartController>().removeCartFromServer(cart),
            backgroundColor: Colors.transparent,
            child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
          ),
        ]),
        child: Container(
          height: 148,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: dark ? const Color(0xFF171717) : Colors.white,
            border: Border.all(color: line), borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(14), child: CustomImage(
              image: cart.service?.thumbnailFullPath ?? '', width: 104, height: 124,
              fit: BoxFit.cover, placeholder: Images.placeholder)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(cart.service?.category?.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: muted, fontSize: 11)),
              Text(cart.service?.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: ink, fontSize: 15, fontWeight: FontWeight.w700)),
              Text(cart.variantKey.replaceAll('-', ' '), maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: muted, fontSize: 11)),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(PriceConverter.convertPrice(cart.totalCost.toDouble()),
                  style: TextStyle(color: ink, fontSize: 15, fontWeight: FontWeight.w800)),
                Container(decoration: BoxDecoration(border: Border.all(color: line), borderRadius: BorderRadius.circular(30)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    _quantityButton(context, Icons.remove, () {
                      if (cart.quantity <= 1) { Get.find<CartController>().removeCartFromServer(cart); }
                      else { Get.find<CartController>().updateCartQuantityToApi(cart.id, cart.quantity - 1); }
                    }),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('${cart.quantity}', style: TextStyle(color: ink, fontWeight: FontWeight.w600))),
                    _quantityButton(context, Icons.add, () => Get.find<CartController>().updateCartQuantityToApi(cart.id, cart.quantity + 1)),
                  ])),
              ]),
            ])),
          ]),
        ),
      ),
    );
  }

  Widget _quantityButton(BuildContext context, IconData icon, VoidCallback action) => InkWell(
    onTap: action, borderRadius: BorderRadius.circular(24),
    child: SizedBox(width: 32, height: 32, child: Icon(icon, size: 17, color: Theme.of(context).textTheme.bodyLarge?.color)));
}


