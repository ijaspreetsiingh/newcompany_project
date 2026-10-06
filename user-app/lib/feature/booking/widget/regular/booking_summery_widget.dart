import 'package:jdds/helper/booking_helper.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingSummeryWidget extends StatelessWidget{
  final BookingDetailsContent bookingDetails;
  const BookingSummeryWidget({super.key, required this.bookingDetails}) ;

  @override
  Widget build(BuildContext context){
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);
    final bgColor = isDark ? const Color(0xFF171717) : Colors.white;
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);
    final iconBgColor = isDark ? const Color(0xFF262626) : const Color(0xFFF6F6F6);

    double paidAmount = 0;

    double totalBookingAmount = bookingDetails.totalBookingAmount ?? 0;
    bool isPartialPayment = bookingDetails.partialPayments !=null && bookingDetails.partialPayments!.isNotEmpty;
    double subTotal = BookingHelper.getSubTotalCost(bookingDetails);
    if(isPartialPayment) {
      bookingDetails.partialPayments?.forEach((element) {
        paidAmount = paidAmount + (element.paidAmount ?? 0);
      });
    }else{
      paidAmount  = totalBookingAmount - (bookingDetails.additionalCharge ?? 0);
    }

    double dueAmount = totalBookingAmount - paidAmount;
    double additionalCharge = isPartialPayment ? totalBookingAmount - paidAmount : bookingDetails.additionalCharge ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [

        const SizedBox(height: 16),
        Padding(padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(horizontal: 24) : const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Container(
                height: 32, width: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: iconBgColor,
                ),
                child: Icon(Icons.receipt_long_rounded, size: 16, color: primaryColor),
              ),
              const SizedBox(width: 10),
              Text( 'booking_summery'.tr,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  )),
            ])),
        const SizedBox(height: 16),

        Container(
          padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(horizontal: 24) : const EdgeInsets.symmetric(horizontal: 16),
          color: iconBgColor,
          child: SizedBox(
            height: 36,
            child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('service_info'.tr, style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              )),
              Text('price'.tr, style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              )),
            ]),
          ),
        ),

        Padding(
          padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(horizontal: 8) : EdgeInsets.zero,
          child: Column(children: [
            ListView.builder(itemBuilder: (context, index){
              return _ServiceInfoItem(
                bookingService : bookingDetails.bookingDetails?[index],
                index: index,
              );
            },
              itemCount: bookingDetails.bookingDetails?.length,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
            ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: borderColor),
            ),
            const SizedBox(height: 8),

            Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('sub_total'.tr,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: mutedColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    PriceConverter.convertPrice(subTotal,isShowLongPrice: true),
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: primaryColor,
                    ),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'service_discount'.tr,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: mutedColor,
                      ),
                      overflow: TextOverflow.ellipsis
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                        "(-) ${PriceConverter.convertPrice(bookingDetails.totalDiscountAmount ?? 0)}",
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: primaryColor,
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'coupon_discount'.tr,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: mutedColor,
                    ),
                    overflow: TextOverflow.ellipsis,),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text('(-) ${PriceConverter.convertPrice(bookingDetails.totalCouponDiscountAmount ?? 0)}',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: primaryColor,
                      )),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'campaign_discount'.tr,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: mutedColor,
                    ),
                    overflow: TextOverflow.ellipsis,),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text('(-) ${PriceConverter.convertPrice(bookingDetails.totalCampaignDiscountAmount ?? 0)}',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: primaryColor,
                        )),
                  ),
                ],
              ),
            ),

            if(bookingDetails.totalReferralDiscountAmount != null && bookingDetails.totalReferralDiscountAmount! > 0)
              const SizedBox(height: 8),

            if(bookingDetails.totalReferralDiscountAmount != null && bookingDetails.totalReferralDiscountAmount! > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'referral_discount'.tr,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: mutedColor,
                      ),
                      overflow: TextOverflow.ellipsis,),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text('(-) ${PriceConverter.convertPrice(bookingDetails.totalReferralDiscountAmount ?? 0)}',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: primaryColor,
                          )),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'service_vat'.tr,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: mutedColor,
                    ),
                    overflow: TextOverflow.ellipsis,),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text('(+) ${PriceConverter.convertPrice(bookingDetails.totalTaxAmount!.toDouble(),isShowLongPrice: true)}',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: primaryColor,
                        )),
                  ),
                ],
              ),
            ),

            if(bookingDetails.extraFee != null && bookingDetails.extraFee! > 0)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(Get.find<SplashController>().configModel.content?.additionalChargeLabelName ?? "",
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: mutedColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text("(+) ${PriceConverter.convertPrice(bookingDetails.extraFee ?? 0, isShowLongPrice: true)}",
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

            if(bookingDetails.additionalCharge != null && additionalCharge < 0 && (bookingDetails.paymentMethod != "cash_after_service" || bookingDetails.partialPayments!.isNotEmpty ))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("refund".tr,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: mutedColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(PriceConverter.convertPrice(additionalCharge, isShowLongPrice: true),
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: borderColor),
            ),
            const SizedBox(height: 8),

            !isPartialPayment && bookingDetails.paymentMethod != "wallet_payment" ? (additionalCharge == 0) || bookingDetails.paymentMethod == "cash_after_service" ?
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('grand_total'.tr,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    PriceConverter.convertPrice(bookingDetails.totalBookingAmount!.toDouble(),isShowLongPrice: true),
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    )),
                ),
              ],),
            ) : Padding(padding: const EdgeInsets.all(8),
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  dashPattern: const [8, 4],
                  strokeWidth: 1.1,
                  color: primaryColor,
                  radius: const Radius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.02),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('grand_total'.tr,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            PriceConverter.convertPrice(totalBookingAmount, isShowLongPrice: true),
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                            )),
                        ),
                      ],),

                      const SizedBox(height: 8),

                      additionalCharge > 0 ?
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text("${(bookingDetails.bookingStatus == "pending" || bookingDetails.bookingStatus == "accepted" || bookingDetails.bookingStatus == "ongoing")
                            ? "due_amount".tr : "paid_amount".tr} (${"cash_after_service".tr})",
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: mutedColor,
                          ),
                          overflow: TextOverflow.ellipsis,),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(PriceConverter.convertPrice(additionalCharge, isShowLongPrice: true),
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: primaryColor,
                            )),
                        )]
                      ): const SizedBox()
                    ],
                  ),
                ),
              ),
            ) :

            !isPartialPayment && bookingDetails.paymentMethod == "wallet_payment" ?
            Padding(padding: const EdgeInsets.all(8),
              child: Column(children: [

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('grand_total'.tr,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                        PriceConverter.convertPrice(bookingDetails.totalBookingAmount!.toDouble(),isShowLongPrice: true),
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        )),
                  ),
                ],),

                const SizedBox(height: 8),

                DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    dashPattern: const [8, 4],
                    strokeWidth: 1.1,
                    color: primaryColor,
                    radius: const Radius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.02),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Text((bookingDetails.additionalCharge! <= 0) ? 'total_order_amount_has_been_paid_by_customer'.tr : "has_been_paid_by_customer".tr,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Row(children: [
                          Image.asset(Images.walletSmall, width: 17),
                          const SizedBox(width: 4),
                          Text('via_wallet'.tr,
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: mutedColor,
                            ),
                            overflow: TextOverflow.ellipsis,),
                        ],),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            PriceConverter.convertPrice(paidAmount, isShowLongPrice: true),
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: primaryColor,
                            )),
                        )]
                      ),

                      if(additionalCharge > 0)
                        Padding(padding: const EdgeInsets.only(top: 8),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text("${(bookingDetails.bookingStatus == "pending" || bookingDetails.bookingStatus == "accepted" || bookingDetails.bookingStatus == "ongoing")
                                ? "due_amount".tr : "paid_amount".tr} (${"cash_after_service".tr})",
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: mutedColor,
                              ),
                              overflow: TextOverflow.ellipsis,),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                PriceConverter.convertPrice(additionalCharge, isShowLongPrice: true),
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: primaryColor,
                                )),
                            )]
                          ),
                        )

                    ]),
                  ),
                ),
              ]),
            ) :

            isPartialPayment ?
            Padding(padding: const EdgeInsets.all(8),
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  dashPattern: const [8, 4],
                  strokeWidth: 1.1,
                  color: primaryColor,
                  radius: const Radius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.02),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    children: [

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('grand_total'.tr,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            PriceConverter.convertPrice(totalBookingAmount, isShowLongPrice: true),
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                            )),
                        ),
                      ],),

                      const SizedBox(height: 8),

                      ListView.builder(itemBuilder: (context, index){
                        String payWith = bookingDetails.partialPayments?[index].paidWith ?? "";

                        return Padding(padding: const EdgeInsets.only(bottom: 4),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Row(children: [
                              Image.asset(Images.walletSmall, width: 15),
                              const SizedBox(width: 4),
                              Text('${payWith == "cash_after_service" ? "paid_amount".tr : payWith == "digital" && bookingDetails.paymentMethod == "offline_payment" ? "" : 'paid_by'.tr} ''${payWith == "digital" ? "${bookingDetails.paymentMethod}".tr : (payWith == "cash_after_service" ? "(${'cash_after_service'.tr})" : payWith).tr }',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: mutedColor,
                                ),
                                overflow: TextOverflow.ellipsis,),
                            ],),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                PriceConverter.convertPrice(bookingDetails.partialPayments?[index].paidAmount ?? 0, isShowLongPrice: true),
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: primaryColor,
                                )),
                            )]),
                        );
                      },itemCount: bookingDetails.partialPayments?.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                      ),

                      bookingDetails.partialPayments?.length == 1 && dueAmount > 0 ?
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text("${(bookingDetails.bookingStatus == "pending" || bookingDetails.bookingStatus == "accepted" || bookingDetails.bookingStatus == "ongoing")
                            ? "due_amount".tr : "paid_amount".tr} (${"cash_after_service".tr})",
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: mutedColor,
                          ),
                          overflow: TextOverflow.ellipsis,),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            PriceConverter.convertPrice(dueAmount, isShowLongPrice: true),
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: primaryColor,
                          )),
                        )]) : const SizedBox(),

                    ],
                  ),
                ),
              ),
            ) : Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('grand_total'.tr,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    PriceConverter.convertPrice(totalBookingAmount, isShowLongPrice: true),
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    )),
                ),
              ]),
            )],
          ),
        ),

        const SizedBox(height: 16),
      ],
      ),
    );
  }
}


class _ServiceInfoItem extends StatelessWidget {
  final int index;
  final ItemService? bookingService;
  const _ServiceInfoItem({
    required this.bookingService,
    required this.index
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Text(bookingService?.serviceName??"",
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: primaryColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(PriceConverter.convertPrice(BookingHelper.getBookingServiceUnitConst(bookingService), isShowLongPrice: true),
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: primaryColor,
            ),
          ),
        ],
        ),
        const SizedBox(height: 4),
        if(bookingService?.variantKey!=null)
          Padding(padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Text(bookingService?.variantKey?.replaceAll("-", " ").capitalizeFirst ?? "",
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: mutedColor,
                ),
              ),
              Container(
                height: 10, width: 0.5,
                color: borderColor,
                margin: const EdgeInsets.only(left: 8, right: 8, top: 5),
              ),
              Row(children: [
                Text("${"qty".tr} : ${bookingService?.quantity}",
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: mutedColor,
                  ),
                ),
              ]),
            ]),
          ),

        _ServiceItemText(title: "unit_price".tr, amount: bookingService?.serviceCost ?? 0),



        // const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
        // (bookingService?.discountAmount ?? 0) > 0 ? _ServiceItemText(title: "discount".tr,
        //     amount: bookingService?.discountAmount ?? 0)
        //     : const SizedBox(),
        //
        // (bookingService?.campaignDiscountAmount ?? 0) > 0
        //     ? _ServiceItemText(title: "campaign".tr,
        //     amount: bookingService?.campaignDiscountAmount ?? 0)
        //     : const SizedBox(),
        //
        // (bookingService?.overallCouponDiscountAmount ?? 0) > 0
        //     ? _ServiceItemText(title: "coupon".tr, amount: bookingService?.overallCouponDiscountAmount?? 0)
        //     : const SizedBox(),
        //
        // bookingService?.service != null && (bookingService?.service?.tax??0) > 0
        //     ? _ServiceItemText(
        //   title: "tax".tr, amount: bookingService?.taxAmount?? 0,)
        //     : const SizedBox(),
      ]),
    );
  }
}


class _ServiceItemText extends StatelessWidget {
  final String title;
  final double amount;

  const _ServiceItemText({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text("$title : ",
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: mutedColor,
            ),
          ),
          Text(PriceConverter.convertPrice(amount, isShowLongPrice: true),
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}


