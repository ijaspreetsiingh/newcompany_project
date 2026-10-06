import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/nest_shared.dart';
import 'package:jdds/feature/cart/widget/cart_product_widget.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';
import 'package:google_fonts/google_fonts.dart';


class CartScreen extends StatefulWidget {
  final bool fromNav;
  const CartScreen({super.key, required this.fromNav});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  ConfigModel configModel = Get.find<SplashController>().configModel;

  ProviderData? provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CartController>().getCartListFromServer().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          Get.find<CartController>().setLoadingfalse();
        },
      ).then((value) {

        Future.delayed(const Duration(milliseconds: 500)).then((value) {
          Get.find<CartController>().showMintmumAndMaximumOrderValueToaster();
          if(Get.find<CartController>().checkProviderUnavailability() && Get.currentRoute.contains(RouteHelper.cart)){
            showModalBottomSheet(
              useRootNavigator: true,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              context: Get.context!, builder: (context) =>  AvailableProviderWidget(
              subcategoryId:Get.find<CartController>().cartList.first.subCategoryId,
              showUnavailableError: true,
            ),);
          }

        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);

    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,

        endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer():null,
        /// nest. page header : back circle + bold "Your cart"
        appBar: AppBar(
          automaticallyImplyLeading: (ResponsiveHelper.isDesktop(context) || !widget.fromNav),
          leading: (ResponsiveHelper.isDesktop(context) || !widget.fromNav) ? IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor),
            onPressed: (){
              if(Navigator.canPop(context)){
                Get.back();
              }else{
                Get.offAllNamed(RouteHelper.getMainRoute("home"));
              }
            },
          ) : null,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('your_cart'.tr,
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
          ),
        ),
        body: SafeArea(child: GetBuilder<CartController>(builder: (cartController){

          provider = Get.find<CartController>().cartList.isNotEmpty ? Get.find<CartController>().cartList[0].provider : null;

          return Column( children: [
            Expanded(
              child: FooterBaseView(
                isCenter: (cartController.cartList.isEmpty),
                child: WebShadowWrap(
                  child: SizedBox( width: Dimensions.webMaxWidth,
                    child: GetBuilder<CartController>(
                      builder: (cartController) {

                        if (cartController.isLoading) {
                          return SizedBox(
                            height: ResponsiveHelper.isMobile(context) ? MediaQuery.of(context).size.height * 0.8 : MediaQuery.of(context).size.height * 0.6,
                              child: const Center(child: CustomLoader())
                          );
                        } else {
                          if (cartController.cartList.isNotEmpty) {
                            return ResponsiveHelper.isDesktop(context) ?
                            Row( spacing : 20,crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Expanded(child:  WebShadowWrap(
                                child: _CartListWidget(),
                              )),
                              Expanded(child: WebShadowWrap(
                                child: Column(children: [
                                  Get.find<SplashController>().configModel.content?.dtrectProviderBooking == 1
                                      ? _ProviderInfoWidget(provider: provider) : const SizedBox(),
                                  _PriceButtonWidget(cartController: cartController)
                                ]),
                              ))
                            ]) : Column(
                              children: [

                                Get.find<SplashController>().configModel.content?.dtrectProviderBooking == 1
                                    ? _ProviderInfoWidget(provider: provider) : const SizedBox(),

                                _CartListWidget(),

                              ],
                            );
                          } else {
                            return NoDataScreen(
                              text: "cart_is_empty".tr,
                              type: NoDataType.cart,
                            );
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            if((ResponsiveHelper.isTab(context) || ResponsiveHelper.isMobile(context) )&& cartController.cartList.isNotEmpty )
              _PriceButtonWidget(cartController: cartController)
          ]);},
        )),
      ),
    );
  }
}


class _CartListWidget extends StatelessWidget {
  const _CartListWidget();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);

    final cartController = Get.find<CartController>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Text(
          "${cartController.cartList.length} ${cartController.cartList.length == 1 ? 'service'.tr : 'services'.tr}",
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: mutedColor,
          ),
        ),
      ),
      ...List.generate(cartController.cartList.length, (index) => cartController.cartList[index].service != null
          ? CartServiceWidget(cart: cartController.cartList[index], cartIndex: index) : const SizedBox()),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: OutlinedButton.icon(
        onPressed: () => Get.find<BottomNavController>().changePage(BnbItem.offers),
        icon: const Icon(Icons.add, size: 20), label: Text('add_more_services'.tr),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54), foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
          side: BorderSide(color: Theme.of(context).dividerColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      )),
      const SizedBox(height: Dimensions.paddingSizeSmall),
    ]);
  }
}



class _PriceButtonWidget extends StatelessWidget {
  final CartController cartController;
  const _PriceButtonWidget({required this.cartController});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);

    final subtotal = cartController.cartList.fold<double>(0, (sum, item) => sum + item.totalCost.toDouble());
    final tax = cartController.cartList.fold<double>(0, (sum, item) => sum + item.taxAmount.toDouble());
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: TextField(
        readOnly: true, onTap: () => Get.toNamed(RouteHelper.getVoucherRoute(fromPage: 'cart')),
        decoration: InputDecoration(prefixIcon: const Icon(Icons.sell_outlined), hintText: 'enter_coupon_code'.tr,
          suffixText: 'view_offers'.tr, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
      )),
      Container(margin: const EdgeInsets.fromLTRB(16, 16, 16, 12), padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF202020) : const Color(0xFFF4F4F4), borderRadius: BorderRadius.circular(22)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('payment_summary'.tr, style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w600, color: primaryColor)),
          const SizedBox(height: 16),
          _priceLine(context, 'item_total'.tr, subtotal),
          const SizedBox(height: 10),
          _priceLine(context, 'taxes_and_fee'.tr, tax),
          const Divider(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('amount_to_pay'.tr, style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: primaryColor)),
            Text(PriceConverter.convertPrice(cartController.totalPrice), style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: primaryColor)),
          ]),
        ])),
      Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 10), child: NestButton(
          label: '${'checkout'.tr} Â· ${PriceConverter.convertPrice(cartController.totalPrice)}',
          onTap: cartController.checkProviderUnavailability() ? (){
            customSnackBar("your_selected_provider_is_unavailable_right_now".tr);
          }: (Get.find<SplashController>().configModel.content?.minBookingAmount ?? 0) >  cartController.totalPrice ? (){
            cartController.showMintmumAndMaximumOrderValueToaster();
          } : () {
            Get.find<CheckOutController>().updateState(PageState.orderDetails);
            Get.toNamed(RouteHelper.getCheckoutFinalRoute());
          },
        ),
      ),
    ]);
  }

  Widget _priceLine(BuildContext context, String label, double amount) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: GoogleFonts.dmSans(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color)),
    Text(PriceConverter.convertPrice(amount), style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
  ]);
}


class _ProviderInfoWidget extends StatelessWidget {
  final ProviderData? provider;
  const _ProviderInfoWidget({this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);
    final bgColor = isDark ? const Color(0xFF171717) : Colors.white;
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);

    return GetBuilder<CartController>(builder: (cartController){

      bool timeSlotAvailable;
      if(  cartController.cartList[0].provider!= null && cartController.cartList[0].provider!.timeSchedule != null ){
        String? startTime = cartController.cartList[0].provider?.timeSchedule?.startTime;
        String? endTime = cartController.cartList[0].provider?.timeSchedule?.endTime;
        final weekends = cartController.cartList[0].provider?.weekends ?? [];
        String currentTime = DateConverter.convertStringTimeToDate(DateTime.now());

        String dayOfWeek = DateConverter.dateToWeek(DateTime.now());

        if(startTime!=null && endTime !=null){
          timeSlotAvailable = _isUnderTime(currentTime, startTime, endTime) && (!weekends.contains(dayOfWeek.toLowerCase()));
        }else{
          timeSlotAvailable = false;
        }
      }else{
        timeSlotAvailable = false;
      }

      return Container(
        width: ResponsiveHelper.isDesktop(context) ? 600 : Dimensions.webMaxWidth,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('provider_info'.tr, style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          )),
          const SizedBox(height: 16),
          Row(spacing: 12, children: [

            provider != null ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomImage(
                height: 60, width: 60,
                image: "${provider?.logoFullPath}",
              ),
            ) : const UnselectedProductWidget(),

            provider != null ? Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 4 ,children: [
                Text(provider?.companyName ?? "" , style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                )),

                Text(cartController.maskNumberWithoutCountryCode(provider?.contactPersonPhone ?? ''), style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: mutedColor,
                )),
                RichText(
                  text: TextSpan(
                    text: timeSlotAvailable && cartController.cartList[0].provider?.serviceAvailability == 1 ? 'available_from'.tr : "provider_is_currently_on_a_break".tr,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: mutedColor,
                    ),
                    children: <TextSpan>[
                      if(timeSlotAvailable && cartController.cartList[0].provider?.serviceAvailability == 1)
                        TextSpan(
                          text: " : ${DateConverter.convertStringDateTimeToTime(cartController.cartList[0].provider!.timeSchedule!.startTime!)} ${'to'.tr} ${DateConverter.convertStringDateTimeToTime(cartController.cartList[0].provider!.timeSchedule!.endTime!)}",
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: primaryColor,
                          ),
                        )
                    ],
                  ),
                )
              ]),
            ) :  Expanded(
              child: Text('${'let'.tr} ${AppConstants.appName} \n${'choose_for_you'.tr}'.tr,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: mutedColor,
                ),
              ),
            ),
            InkWell(
              onTap: () => showModalBottomSheet(
                useRootNavigator: true,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                context: context, builder: (context) => AvailableProviderWidget(
                  subcategoryId: cartController.subcategoryId,
                )),
              child: Image.asset(Images.editButton,width: 20.0,height: 20.0,
              ),
            )
          ]),
        ]),
      );
    });
  }

  bool _isUnderTime(String time, String startTime, String? endTime) {
    return DateConverter.convertTimeToDateTime(time).isAfter(DateConverter.convertTimeToDateTime(startTime))
        && DateConverter.convertTimeToDateTime(time).isBefore(DateConverter.convertTimeToDateTime(endTime!));
  }
}



