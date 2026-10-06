import 'package:jdds/helper/analytics/analytics_helper.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdds/util/core_export.dart';


class ServiceCenterDialog extends StatefulWidget {
  final Service? service;
  final CartModel? cart;
  final int? cartIndex;
  final bool? isFromDetails;
  final ProviderData? providerData;

  const ServiceCenterDialog({
    super.key,
    required this.service,
    this.cart,
    this.cartIndex,
    this.isFromDetails = false, this.providerData});

  @override
  State<ServiceCenterDialog> createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<ServiceCenterDialog> {
  /// nest. customize sheet : ek hi package select + uski quantity
  int _selected = 0;
  int _quantity = 0;

  @override
  void initState() {
    final CartController cartController = Get.find<CartController>();
    cartController.setinttialCartList(widget.service!);
    cartController.updatePreselectedProvider(null, shouldUpdate: false);
    Get.find<AllSearchController>().searchFocus.unfocus();

    final List<CartModel> variations = cartController.inttialCartList;
    if (variations.isNotEmpty) {
      final int existing = variations.indexWhere((element) => element.quantity > 0);
      _selected = existing < 0 ? 0 : existing;
      _quantity = existing < 0 ? 1 : variations[existing].quantity;
      _syncQuantities();
    }
    super.initState();
  }

  /// single-select : strf selected package ki quantity > 0 rakho
  void _syncQuantities() {
    final List<CartModel> variations = Get.find<CartController>().inttialCartList;
    for (int i = 0; i < variations.length; i++) {
      variations[i].quantity = i == _selected ? _quantity : 0;
    }
  }

  void _selectPackage(int index) {
    if (index == _selected) return;
    setState(() {
      _selected = index;
      _syncQuantities();
    });
  }

  void _changeQuantity(int delta) {
    int value = _quantity + delta;
    if (value < 0) value = 0;
    if (value > 99) value = 99;
    setState(() {
      _quantity = value;
      _syncQuantities();
    });
  }

  double _totalPrice(List<CartModel> variations) {
    double total = 0;
    for (final CartModel item in variations) {
      if (item.quantity > 0) total += item.price.toDouble() * item.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if(ResponsiveHelper.isDesktop(context)) {
      return  Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: pointerInterceptor(),
    );
    }
    return pointerInterceptor();
  }

  Padding pointerInterceptor(){
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final Color mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);
    final Color subtleColor = isDark ? const Color(0xFF262626) : const Color(0xFFF6F6F6);
    final Color sheetColor = isDark ? const Color(0xFF171717) : Colors.white;

    return Padding(
      padding: EdgeInsets.only(top: ResponsiveHelper.isWeb()? 0 :Dimensions.cartDialogPadding),
      child: PointerInterceptor(
        child: Container(
          width:ResponsiveHelper.isDesktop(context)? Dimensions.webMaxWidth/2:Dimensions.webMaxWidth,
          padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, Dimensions.paddingSizeSmall, Dimensions.paddingSizeLarge, Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            /// nest. sheet : card bg + rounded top
            color: sheetColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
          ),
          child:  GetBuilder<CartController>(builder: (cartControllerintt) {
              return GetBuilder<ServiceController>(builder: (serviceController) {
                if(widget.service!.variationsAppFormat?.zoneWiseVariations != null) {
                  final List<CartModel> variations = cartControllerintt.inttialCartList;
                  final double total = _totalPrice(variations);
                  final bool canAdd = total > 0 && !cartControllerintt.isLoading;
                  final String totalText = PriceConverter.convertPrice(total, isShowLongPrice: true);
                  final String unitPriceText = variations.isNotEmpty
                      ? PriceConverter.convertPrice(variations[_selected].price.toDouble(), isShowLongPrice: true)
                      : PriceConverter.convertPrice(0, isShowLongPrice: true);

                  return Column(mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// grabber handle
                      Center(child: Container(
                        height: 4, width: 44,
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      )),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      /// title + close
                      Row(children: [
                        Expanded(child: Text(
                          'customize_service'.tr,
                          style: GoogleFonts.manrope(
                            fontSize: 26, height: 1.1,
                            fontWeight: FontWeight.w800, letterSpacing: -0.4,
                            color: primaryColor,
                          ),
                        )),
                        InkWell(
                          onTap: () => Get.back(),
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            height: 40, width: 40, alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: borderColor),
                            ),
                            child: Icon(Icons.close_rounded, size: 19,
                              color: primaryColor),
                          ),
                        ),
                      ]),

                      /// sab kuch scrollable (choti screen pe overflow na ho)
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: Get.height * 0.58),
                        child: SingleChildScrollView(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, children: [

                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          /// service summary : image + category + name + price
                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                              child: CustomImage(
                                image: '${widget.service!.thumbnailFullPath}',
                                height: 64, width: 64,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeDefault),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(
                                (widget.service?.category?.name ?? '').toUpperCase(),
                                style: GoogleFonts.dmSans(
                                  fontSize: 10, fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1, color: mutedColor,
                                ),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.service?.name ?? '',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16, fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(unitPriceText,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 15, fontWeight: FontWeight.w700,
                                    color: primaryColor,
                                  )),
                              ),
                            ])),
                          ]),
                          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                          /// Choose package
                          Text('choose_package'.tr,
                            style: GoogleFonts.manrope(
                              fontSize: 22, fontWeight: FontWeight.w800,
                              letterSpacing: -0.3, color: primaryColor,
                            )),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          ...variations.asMap().entries.map((entry) {
                            final int index = entry.key;
                            final CartModel item = entry.value;
                            final bool isSelected = index == _selected;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                              child: InkWell(
                                onTap: () => _selectPackage(index),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault,
                                    vertical: Dimensions.paddingSizeDefault,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sheetColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? primaryColor : borderColor,
                                      width: isSelected ? 1.4 : 1,
                                    ),
                                  ),
                                  child: Row(children: [
                                    Container(
                                      height: 26, width: 26,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected ? primaryColor : Colors.transparent,
                                        border: isSelected ? null : Border.all(color: borderColor, width: 1.5),
                                      ),
                                      child: isSelected ? Icon(Icons.check_rounded, size: 15,
                                        color: isDark ? const Color(0xFF0D0D0D) : Colors.white) : null,
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeDefault),
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(item.variantKey.replaceAll('-', ' '),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 15, fontWeight: FontWeight.w700,
                                          color: primaryColor,
                                        ),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 3),
                                      Text('professional_tools_included'.tr,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12, fontWeight: FontWeight.w400,
                                          color: mutedColor,
                                        ),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ])),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),
                                    Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Text(
                                        PriceConverter.convertPrice(item.price.toDouble(), isShowLongPrice: true),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 15, fontWeight: FontWeight.w700,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          /// Quantity + stepper
                          Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('quantity'.tr,
                                style: GoogleFonts.dmSans(
                                  fontSize: 16, fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                )),
                                const SizedBox(height: 3),
                                Text('number_of_units'.tr,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12, fontWeight: FontWeight.w400,
                                    color: mutedColor,
                                  )),
                              ]),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: borderColor),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                _stepButton(
                                  icon: Icons.remove_rounded,
                                  enabled: _quantity > 0,
                                  onTap: () => _changeQuantity(-1),
                                  color: primaryColor,
                                  disabledColor: subtleColor,
                                  borderColor: borderColor,
                                ),
                                SizedBox(width: 22, child: Text('$_quantity',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 15, fontWeight: FontWeight.w700,
                                    color: primaryColor,
                                  ))),
                                _stepButton(
                                  icon: Icons.add_rounded,
                                  enabled: _quantity < 99,
                                  onTap: () => _changeQuantity(1),
                                  color: primaryColor,
                                  disabledColor: subtleColor,
                                  borderColor: borderColor,
                                ),
                              ]),
                            ),
                          ]),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                        ])),
                      ),

                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      GetBuilder<CartController>(builder: (cartController) {
                        bool addToCart = true;
                        final bool canAddNow = _totalPrice(cartController.inttialCartList) > 0 && !cartController.isLoading;
                        final String label = (cartController.cartList.isNotEmpty && cartController.cartList.elementAt(0).serviceId == widget.service!.id)
                            ? 'update_cart'.tr : 'add_to_cart'.tr;
                        final double totalNow = _totalPrice(cartController.inttialCartList);

                        return cartController.isLoading ? const Center(child: Padding(
                          padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                          child: CircularProgressIndicator(),
                        )) :

                        Row(spacing: Dimensions.paddingSizeSmall, children: [
                          if(Get.find<SplashController>().configModel.content?.dtrectProviderBooking==1 && (widget.providerData !=null || cartController.selectedProvider !=null))

                          GestureDetector(
                            onTap: (){
                            },
                            child:  SelectedProductWidget(providerData: widget.providerData ?? cartController.selectedProvider,),
                          ),

                          if(Get.find<SplashController>().configModel.content?.biddingStatus==1)
                          GestureDetector(
                            onTap: (){
                              Get.back();
                              showModalBottomSheet(
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              context: Get.context!,
                              builder: (BuildContext context){
                                return const BottomCreatePostDialog();
                              });
                              if(widget.service!=null){
                                Get.find<CreatePostController>().resetCreatePostValue(removeService: false);
                                Get.find<CreatePostController>().updateSelectedService(widget.service!);

                              }
                            },
                            child: Container(
                              height:  ResponsiveHelper.isDesktop(context)? 50 : 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),width: 0.7),
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                              child: Center(child: Hero(tag: 'provide_image',
                                child: Image.asset(Images.customPostIcon,height: 30,width: 30,),
                              )),
                            ),
                          ),

                          Expanded(child: CustomButton(
                            height: ResponsiveHelper.isDesktop(context)? 55 : 52,
                            radius: 16,
                            backgroundColor: canAddNow ? primaryColor : subtleColor,
                            onPressed: canAddNow ? () async{
                              if(addToCart) {
                                addToCart = false;
                                await _addToCart(cartController);
                                await cartController.getCartListFromServer(shouldUpdate: true);
                              }
                            }: null,
                            buttonText: totalNow > 0 ? '$label Â· $totalText' : label,
                            textStyle: GoogleFonts.dmSans(
                              fontSize: 13, fontWeight: FontWeight.w800,
                              color: canAddNow
                                  ? (isDark ? const Color(0xFF0D0D0D) : Colors.white)
                                  : mutedColor,
                            ),
                            ),
                          )
                        ]);
                      }),
                    ],
                  );
                }
                return Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 20,
                      child: Container(
                        height: 40, width: 40, alignment: Alignment.center,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white70.withValues(alpha: 0.6),
                            boxShadow:[BoxShadow(
                              color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]!, blurRadius: 2, spreadRadius: 1,
                            )]
                        ),
                        child: InkWell(
                            onTap: () => Get.back(),
                            child: const Icon(Icons.close)),
                      ),
                    ),
                    SizedBox(
                        height: Get.height / 7,
                        child: Center(child: Text('no_variation_is_available'.tr,style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),)))
                  ],
                );
              });
            }
          ),
        ),
      ),
    );
  }

  Widget _stepButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    required Color color,
    required Color disabledColor,
    required Color borderColor,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        height: 32, width: 32, alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon, size: 16,
          color: enabled ? color : disabledColor),
      ),
    );
  }

  Future<void> _addToCart(CartController cartController) async {
    await cartController.addMultipleCartToServer(
        providerId: cartController.selectedProvider?.id ?? widget.providerData?.id ??"");

    try {
      for (CartModel item in cartController.inttialCartList) {
        if (item.quantity > 0) {
          AnalyticsHelper.logAddToCart(
            itemId: widget.service?.id ?? '',
            itemName: widget.service?.name ?? '',
            price: item.price.toDouble(),
            quantity: item.quantity,
            currency: Get.find<SplashController>().configModel.content?.currencyCode ?? '\$'
          );
        }
      }
      if (kDebugMode) {
        print("====================== Analytics Success =========================");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Analytics Error: $e");
      }
    }
  }

}



