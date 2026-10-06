// ignore_for_file: deprecated_member_use
import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';
import 'package:google_fonts/google_fonts.dart';


class CheckoutScreen extends StatefulWidget {
  final String pageState;
  final String addressId;
  final bool? reload;
  final String? token;
  const CheckoutScreen(this.pageState, this.addressId, {super.key,this.reload = true, this.token}) ;
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();}

class _CheckoutScreenState extends State<CheckoutScreen> {

  final tooltipController = JustTheController();

  @override
  void initState() {
    if(widget.pageState == 'complete') {
      Get.find<CheckOutController>().updateState(PageState.complete,shouldUpdate: false);
    }

    Get.find<CheckOutController>().changePaymentMethod(shouldUpdate: false);

    if(widget.pageState == 'orderDetails'){
      Get.find<CartController>().getCartListFromServer(shouldUpdate: false).then((value){
        if(Get.find<CartController>().cartList.isEmpty) {
          Get.offAllNamed(RouteHelper.home);
        }
      });
      Get.find<ScheduleController>().resetScheduleData(shouldUpdate: false);
      Get.find<CheckOutController>().resetCreateAccountWithExistingInfo();
      Get.find<CheckOutController>().toggleTerms(value: false, shouldUpdate: false);
      Get.find<ScheduleController>().resetSchedule();
      Get.find<LocationController>().updateSelectedServiceLocationType();
    }else{
      Get.find<CheckOutController>().toggleTerms(value: true, shouldUpdate: false);
    }
    if(widget.token !=null && widget.token != "null" && widget.token != ""){
      Get.find<CheckOutController>().parseToken(widget.token!);
    }
    Get.find<CartController>().updateWalletPaymentStatus(false, shouldUpdate: false);

    Get.find<CouponController>().getCouponList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);

    return WillPopScope(
      onWillPop: ()  => _exitApp(),
      child: GetBuilder<CheckOutController>(builder: (checkoutController){
        return Scaffold(
          resizeToAvoidBottomInset: false,
          drawer: ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,

          endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
          appBar: AppBar(
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor),
              onPressed: () {
                if(widget.pageState == 'payment' || checkoutController.currentPageState == PageState.payment) {
                  checkoutController.changePaymentMethod();
                  checkoutController.updateState(PageState.orderDetails);
                  if(ResponsiveHelper.isWeb()) {
                    Get.toNamed(RouteHelper.getCheckoutRoute('cart','orderDetails','null'));
                  }
                } else if(widget.pageState == 'complete' || Get.find<CheckOutController>().currentPageState == PageState.complete){
                  Get.offAllNamed(RouteHelper.getMainRoute('home'));
                } else {
                  checkoutController.updateState(PageState.orderDetails);
                  Get.back();
                }
              },
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('checkout'.tr,
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
            ),
          ),
          body: SafeArea(child: FooterBaseView( child: WebShadowWrap(
            child: SizedBox(width: Dimensions.webMaxWidth, child:  Column(mainAxisAlignment: MainAxisAlignment.start, children: [

              const SizedBox(height: Dimensions.paddingSizeDefault,),
              CheckoutHeaderWidget(pageState: widget.pageState,),

              checkoutController.currentPageState == PageState.orderDetails  && PageState.orderDetails.name == widget.pageState ? ResponsiveHelper.isDesktop(context) ?
              OrderDetailsPageWeb(pageState: widget.pageState,addressId: widget.addressId) :  const OrderDetailsPage() : checkoutController.currentPageState == PageState.payment || PageState.payment.name == widget.pageState ?
              PaymentPage(addressId: widget.addressId, tooltipController: tooltipController,fromPage: "checkout",) :
              CompletePage(token: widget.token,),


              ResponsiveHelper.isDesktop(context)  &&  (checkoutController.currentPageState == PageState.payment || widget.pageState == 'payment') ?
              ProceedToCheckoutButtonWidget(pageState: widget.pageState,addressId: widget.addressId,) : const SizedBox(height: 120,)

            ]))
          ))),

          bottomSheet:  !(ResponsiveHelper.isDesktop(context)) ? SafeArea( child: SizedBox( height: checkoutController.currentPageState.name=="complete"? 70 : 100,
            child: (checkoutController.currentPageState == PageState.complete || widget.pageState == 'complete') ?
            const SizedBox() : ProceedToCheckoutButtonWidget(pageState: widget.pageState,addressId: widget.addressId,),
          )): const SizedBox(),
        );
      }),
    );
  }


  Future<bool> _exitApp() async {
    if(widget.pageState == 'payment' || Get.find<CheckOutController>().currentPageState == PageState.payment) {
      Get.find<CheckOutController>().changePaymentMethod();
      Get.find<CheckOutController>().updateState(PageState.orderDetails);
      Get.find<CheckOutController>().getOfflinePaymentMethod(true);
      Get.find<CheckOutController>().changePaymentMethod(shouldUpdate: true);
      if(ResponsiveHelper.isWeb()) {
        Get.toNamed(RouteHelper.getCheckoutRoute('cart','orderDetails','null',reload: false));
      }
      return false;
    } else if(widget.pageState == 'complete' || Get.find<CheckOutController>().currentPageState == PageState.complete){
      Get.offAllNamed(RouteHelper.getMainRoute('home'));
      return false;
    }else {
      return true;
    }
  }
}





