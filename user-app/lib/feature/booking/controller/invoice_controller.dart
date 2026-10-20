import 'dart:typed_data';
import 'package:jdds/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:jdds/helper/date_converter.dart';
import 'package:jdds/feature/booking/controller/booking_details_controller.dart';
import 'package:jdds/feature/booking/model/booking_details_model.dart';
import 'package:jdds/feature/booking/model/invoice.dart';
import 'package:jdds/feature/splash/controller/splash_controller.dart';
import 'package:jdds/util/dimensions.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:http/http.dart' as http;

// ---------------------------------------------------------------------------
// Admin controls invoice design via config key "invoice_template":
//   template_1  →  Classic Grey   (original)
//   template_2  →  Modern Dark / Teal
//   template_3  →  Clean Minimal / Green
// ---------------------------------------------------------------------------

class _T1 {
  static final headerBg  = PdfColors.grey400;
  static final rowAlt    = PdfColors.grey300;
  static final footerBg  = PdfColors.grey100;
}

class _T2 {
  static final header    = PdfColor.fromHex('1a1a2e');
  static final headerTxt = PdfColor.fromHex('00d4aa');
  static final rowAlt    = PdfColor.fromHex('f0faf8');
  static final footerBg  = PdfColor.fromHex('1a1a2e');
  static final accent    = PdfColor.fromHex('00d4aa');
}

class _T3 {
  static final header   = PdfColor.fromHex('2e7d32');
  static final rowAlt   = PdfColor.fromHex('f1f8f2');
  static final accent   = PdfColor.fromHex('2e7d32');
  static final titleTxt = PdfColor.fromHex('1b5e20');
}

class InvoiceController {

  // -------------------------------------------------------------------------
  // Public entry — reads invoiceTemplate from config
  // -------------------------------------------------------------------------
  static Future<Uint8List> generateUint8List(
    BookingDetailsContent bookingDetailsContent,
    List<InvoiceItem> items,
    BookingDetailsController controller,
  ) async {
    final pdf = Document();
    ImageProvider? imageProvider;

    try {
      imageProvider = await downloadImage(
        Get.find<SplashController>().configModel.content!.logoFullPath ?? '',
      );
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }

    final template =
        Get.find<SplashController>().configModel.content?.invoiceTemplate ?? 'template_1';

    var invoice = Invoice(
      provider: Provider(
        name:    bookingDetailsContent.provider?.companyName  ?? '',
        address: bookingDetailsContent.provider?.companyAddress ?? '',
        phone:   bookingDetailsContent.provider?.companyPhone   ?? '',
      ),
      serviceman: ServicemanInvoice(
        name:  bookingDetailsContent.serviceman != null
            ? '${bookingDetailsContent.serviceman!.user!.firstName!} ${bookingDetailsContent.serviceman!.user!.lastName!}'
            : '',
        phone: bookingDetailsContent.serviceman?.user?.phone ?? '',
      ),
      info: InvoiceInfo(
        date: bookingDetailsContent.serviceSchedule,
        description: 'Payment Status : ',
        number: bookingDetailsContent.readableId.toString(),
        paymentStatus: _payStatus(bookingDetailsContent),
      ),
      items: items,
    );

    pdf.addPage(MultiPage(
      build: (context) => [
        _buildLogoBar(imageProvider, bookingDetailsContent, template),
        SizedBox(height: 0.6 * PdfPageFormat.cm),
        _buildIdScheduleRow(invoice.info.number, invoice.info.date, template),
        _buildHeader(invoice, bookingDetailsContent, template),
        SizedBox(height: 0.8 * PdfPageFormat.cm),
        _buildTable(invoice, template),
        SizedBox(height: Dimensions.paddingSizeDefault),
        buildTotal(bookingDetailsContent, controller, invoice.info.paymentStatus),
      ],
      footer: (context) => _buildFooter(bookingDetailsContent, template),
    ));

    return pdf.save();
  }

  // =========================================================================
  // LOGO BAR
  // =========================================================================
  static Widget _buildLogoBar(
    ImageProvider? img,
    BookingDetailsContent content,
    String template,
  ) {
    if (template == 'template_2') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: _T2.header,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (img != null)
              Container(
                width: Dimensions.invoiceImageWidth,
                height: Dimensions.invoiceImageHeight,
                child: pw.Image(img),
              )
            else
              SizedBox(width: Dimensions.invoiceImageWidth, height: Dimensions.invoiceImageHeight),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('INVOICE',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: _T2.headerTxt)),
                Text('# ${content.readableId}',
                    style: TextStyle(color: _T2.headerTxt, fontSize: 12)),
              ],
            ),
          ],
        ),
      );
    }

    if (template == 'template_3') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (img != null)
            pw.Image(img, width: Dimensions.invoiceImageWidth, height: Dimensions.invoiceImageHeight)
          else
            SizedBox(width: Dimensions.invoiceImageWidth, height: Dimensions.invoiceImageHeight),
          SizedBox(height: 4),
          Container(height: 3, color: _T3.accent),
        ],
      );
    }

    // template_1 — original
    return Container(
      width:  Dimensions.invoiceImageWidth,
      height: Dimensions.invoiceImageHeight,
      child: img != null ? pw.Image(img) : SizedBox(),
    );
  }

  // =========================================================================
  // ID + SCHEDULE ROW
  // =========================================================================
  static Widget _buildIdScheduleRow(String number, String? schedule, String template) {
    final scheduleLabel = schedule != null
        ? DateConverter.dateMonthYearTimeTwentyFourFormat(DateTime.tryParse(schedule)!)
        : '';

    if (template == 'template_2') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Invoice # $number',
                style: pw.TextStyle(fontWeight: FontWeight.bold, color: _T2.header, fontSize: 12)),
            Text('Schedule: $scheduleLabel',
                style: TextStyle(fontSize: 9, color: PdfColors.grey700)),
          ],
        ),
      );
    }

    if (template == 'template_3') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Invoice # $number',
              style: pw.TextStyle(fontWeight: FontWeight.bold, color: _T3.titleTxt, fontSize: 12)),
          Text('Schedule: $scheduleLabel', style: TextStyle(fontSize: 9, color: PdfColors.grey700)),
        ],
      );
    }

    // template_1
    return invoiceIDSchedule(number, schedule);
  }

  // =========================================================================
  // HEADER
  // =========================================================================
  static Widget _buildHeader(
    Invoice invoice,
    BookingDetailsContent content,
    String template,
  ) {
    if (template == 'template_2') return _t2Header(invoice, content);
    if (template == 'template_3') return _t3Header(invoice, content);
    return buildHeader(invoice, content);
  }

  // ---- template_2 ---------------------------------------------------------
  static Widget _t2Header(Invoice invoice, BookingDetailsContent c) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Service Address',
              style: TextStyle(fontWeight: FontWeight.bold, color: _T2.header, fontSize: 10)),
          if (c.customer != null) ...[
            _sm('${c.customer!.firstName ?? ""} ${c.customer!.lastName ?? ""}'),
            if ((c.customer!.email ?? '').isNotEmpty) _sm(c.customer!.email!),
            if ((c.customer!.phone ?? '').isNotEmpty) _sm(c.customer!.phone!),
          ],
          if (c.serviceAddress?.address != null)
            SizedBox(
              width: Get.width * .35,
              child: Text(c.serviceAddress!.address!.replaceAll('null', ''),
                  style: TextStyle(fontSize: 9)),
            ),
          SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: _T2.accent, borderRadius: BorderRadius.circular(4)),
            child: Text(_payStatus(c),
                style: TextStyle(
                    color: PdfColors.white, fontSize: 9, fontWeight: FontWeight.bold)),
          ),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (invoice.serviceman.name.isNotEmpty) ...[
            Text('Serviceman',
                style: TextStyle(fontWeight: FontWeight.bold, color: _T2.header, fontSize: 10)),
            _sm(invoice.serviceman.name),
            if (invoice.serviceman.phone.isNotEmpty) _sm(invoice.serviceman.phone),
          ],
          SizedBox(height: 6),
          if (invoice.provider.name.isNotEmpty) ...[
            Text('Provider',
                style: TextStyle(fontWeight: FontWeight.bold, color: _T2.header, fontSize: 10)),
            _sm(invoice.provider.name),
            if (invoice.provider.phone.isNotEmpty) _sm(invoice.provider.phone),
          ],
        ]),
      ],
    );
  }

  // ---- template_3 ---------------------------------------------------------
  static Widget _t3Header(Invoice invoice, BookingDetailsContent c) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: _T3.accent, width: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Bill To',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: _T3.accent, fontSize: 10)),
            if (c.customer != null) ...[
              Text('${c.customer!.firstName ?? ""} ${c.customer!.lastName ?? ""}',
                  style: TextStyle(fontSize: 9)),
              if ((c.customer!.email ?? '').isNotEmpty)
                Text(c.customer!.email!, style: TextStyle(fontSize: 9)),
              if ((c.customer!.phone ?? '').isNotEmpty)
                Text(c.customer!.phone!, style: TextStyle(fontSize: 9)),
            ],
            if (c.serviceAddress?.address != null)
              SizedBox(
                width: Get.width * .35,
                child: Text(c.serviceAddress!.address!.replaceAll('null', ''),
                    style: TextStyle(fontSize: 9)),
              ),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(_payStatus(c),
                style: TextStyle(
                    color: _T3.accent, fontWeight: FontWeight.bold, fontSize: 10)),
            SizedBox(height: 8),
            if (invoice.serviceman.name.isNotEmpty) ...[
              Text('Serviceman',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: _T3.titleTxt, fontSize: 10)),
              Text(invoice.serviceman.name, style: TextStyle(fontSize: 9)),
              if (invoice.serviceman.phone.isNotEmpty)
                Text(invoice.serviceman.phone, style: TextStyle(fontSize: 9)),
            ],
            SizedBox(height: 4),
            if (invoice.provider.name.isNotEmpty) ...[
              Text('Provider',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: _T3.titleTxt, fontSize: 10)),
              Text(invoice.provider.name, style: TextStyle(fontSize: 9)),
              if (invoice.provider.phone.isNotEmpty)
                Text(invoice.provider.phone, style: TextStyle(fontSize: 9)),
            ],
          ]),
        ],
      ),
    );
  }

  // =========================================================================
  // TABLE
  // =========================================================================
  static Widget _buildTable(Invoice invoice, String template) {
    final headers = ['Description', 'Unit Price', 'Quantity', 'Discount', 'Tax', 'Total'];
    final data = invoice.items.map((item) => [
          item.serviceName, item.unitPrice, item.quantity,
          item.discountAmount, item.tax, item.unitAllTotal,
        ]).toList();

    if (template == 'template_2') {
      return TableHelper.fromTextArray(
        headers: headers,
        data: data,
        border: null,
        headerPadding: const EdgeInsets.symmetric(horizontal: 10),
        headerStyle: TextStyle(fontWeight: FontWeight.bold, color: _T2.headerTxt, fontSize: 9),
        rowDecoration: BoxDecoration(color: _T2.rowAlt),
        headerDecoration: BoxDecoration(
          color: _T2.header,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6), topRight: Radius.circular(6)),
        ),
        cellHeight: 28,
        columnWidths: {
          0: kIsWeb ? FixedColumnWidth(Get.width / 12) : FixedColumnWidth(Get.width / 4),
        },
        cellAlignments: {
          0: Alignment.centerLeft,
          1: Alignment.center, 2: Alignment.center,
          3: Alignment.center, 4: Alignment.center, 5: Alignment.centerRight,
        },
      );
    }

    if (template == 'template_3') {
      return TableHelper.fromTextArray(
        headers: headers,
        data: data,
        border: pw.TableBorder.all(color: _T3.rowAlt, width: 0.5),
        headerPadding: const EdgeInsets.symmetric(horizontal: 10),
        headerStyle: TextStyle(fontWeight: FontWeight.bold, color: PdfColors.white, fontSize: 9),
        rowDecoration: BoxDecoration(color: PdfColors.white),
        oddRowDecoration: BoxDecoration(color: _T3.rowAlt),
        headerDecoration: BoxDecoration(color: _T3.header),
        cellHeight: 26,
        columnWidths: {
          0: kIsWeb ? FixedColumnWidth(Get.width / 12) : FixedColumnWidth(Get.width / 4),
        },
        cellAlignments: {
          0: Alignment.centerLeft,
          1: Alignment.center, 2: Alignment.center,
          3: Alignment.center, 4: Alignment.center, 5: Alignment.centerRight,
        },
      );
    }

    // template_1 — original
    return buildInvoice(invoice);
  }

  // =========================================================================
  // FOOTER
  // =========================================================================
  static Widget _buildFooter(BookingDetailsContent content, String template) {
    final splash = Get.find<SplashController>().configModel.content;
    final phone  = splash?.businessPhone ?? '';
    final email  = splash?.businessEmail ?? '';
    final footer = splash?.footerText    ?? '';

    if (template == 'template_2') {
      return Container(
        color: _T2.footerBg,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(phone,  style: TextStyle(color: _T2.accent, fontSize: 8)),
            Text(email,  style: TextStyle(color: _T2.accent, fontSize: 8)),
            Text(AppConstants.baseUrl, style: TextStyle(color: _T2.accent, fontSize: 8)),
          ],
        ),
      );
    }

    if (template == 'template_3') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1, color: _T3.accent),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$phone  |  $email  |  ${AppConstants.baseUrl}',
                  style: TextStyle(
                      fontSize: 8, color: _T3.titleTxt, fontWeight: FontWeight.bold)),
            ],
          ),
          if (footer.isNotEmpty) ...[
            SizedBox(height: 2),
            Text(footer,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 7, color: PdfColors.grey700)),
          ],
        ],
      );
    }

    // template_1 — original
    return buildFooter(content);
  }

  // =========================================================================
  // ORIGINAL template_1 helpers — unchanged
  // =========================================================================
  static Widget invoiceIDSchedule(String invoiceID, String? invoiceSchedule) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Invoice # $invoiceID',
              style: pw.TextStyle(fontWeight: FontWeight.bold)),
          Text(
              'Service Schedule : ${DateConverter.dateMonthYearTimeTwentyFourFormat(DateTime.tryParse(invoiceSchedule ?? '')!)}'),
        ],
      );

  static Widget buildHeader(Invoice invoice, BookingDetailsContent content) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              serviceAddress(
                name:    '${content.customer?.firstName ?? ""} ${content.customer?.lastName ?? ""}',
                address: content.serviceAddress!.address?.replaceAll('null', '') ?? '',
                email:   content.customer?.email  ?? '',
                phone:   content.customer?.phone  ?? '',
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: Dimensions.paddingSizeSmall),
                  buildProviderSection(invoice.provider, invoice.serviceman),
                ],
              ),
            ],
          ),
        ],
      );

  static Widget serviceAddress({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Service Address', style: TextStyle(fontWeight: FontWeight.bold)),
          buildSimpleText(title: 'Customer Name', value: name),
          if (email != '') buildSimpleText(title: 'Email', value: email),
          if (phone != '') buildSimpleText(title: 'Phone', value: phone),
          if (address != '')
            SizedBox(width: Get.width * .4, child: Text('Address: $address')),
        ],
      );

  static Widget buildProviderSection(Provider provider, ServicemanInvoice serviceman) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (serviceman.name != '' && serviceman.phone != '')
            Text('Serviceman Details', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(serviceman.name),
          Text(serviceman.phone),
          SizedBox(height: Dimensions.paddingSizeDefault),
          if (provider.name != '' && provider.phone != '')
            Text('Provider Details', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(provider.name),
          Text(provider.phone),
        ],
      );

  static Widget buildServiceManSection(Serviceman serviceman) =>
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: []);

  static Widget buildInvoiceInfo(InvoiceInfo info) {
    final titles = <String>['Invoice Number:', 'Invoice Date:', 'Payment Status:'];
    final data   = <String?>[info.number, info.date, info.paymentStatus];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(titles.length, (index) {
        return buildText(title: titles[index], value: data[index], width: 200);
      }),
    );
  }

  static Widget buildSupplierAddress(Supplier supplier) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(supplier.name, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text(supplier.address),
        ],
      );

  static Widget buildTitle(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('INVOICE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  static Widget buildInvoice(Invoice invoice) {
    final headers = ['Description', 'Unit Price', 'Quantity', 'Discount', 'Tax', 'Total'];
    final data = invoice.items.map((item) => [
          item.serviceName, item.unitPrice, item.quantity,
          item.discountAmount, item.tax, item.unitAllTotal,
        ]).toList();

    return ClipRRect(
      horizontalRadius: Dimensions.paddingSizeExtraSmall,
      verticalRadius:   Dimensions.paddingSizeExtraSmall,
      child: Container(
        color: _T1.rowAlt,
        child: TableHelper.fromTextArray(
          headers: headers,
          data: data,
          columnWidths: {
            0: kIsWeb ? FixedColumnWidth(Get.width / 12) : FixedColumnWidth(Get.width / 4),
          },
          border: null,
          headerStyle:     TextStyle(fontWeight: FontWeight.bold),
          headerDecoration: BoxDecoration(color: _T1.headerBg),
          cellHeight: 30,
          cellAlignments: {
            0: Alignment.centerLeft,
            1: Alignment.center, 2: Alignment.center,
            3: Alignment.center, 4: Alignment.center, 5: Alignment.centerRight,
          },
        ),
      ),
    );
  }

  static Widget buildTotal(
    BookingDetailsContent bookingDetailsContent,
    BookingDetailsController controller,
    String paymentStatus,
  ) {
    double serviceDiscount = 0;
    bookingDetailsContent.bookingDetails?.forEach((s) {
      serviceDiscount += s.discountAmount ?? 0;
    });

    double paidAmount = 0;
    double totalBookingAmount = bookingDetailsContent.totalBookingAmount ?? 0;
    bool isPartialPayment = bookingDetailsContent.partialPayments != null &&
        bookingDetailsContent.partialPayments!.isNotEmpty;

    if (isPartialPayment) {
      bookingDetailsContent.partialPayments?.forEach((el) {
        paidAmount += el.paidAmount ?? 0;
      });
    } else {
      paidAmount = totalBookingAmount - (bookingDetailsContent.additionalCharge ?? 0);
    }
    double dueAmount = totalBookingAmount - paidAmount;

    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment Status', style: pw.TextStyle(fontWeight: FontWeight.bold)),
              Text(paymentStatus),
            ],
          ),
          Spacer(flex: 3),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText(
                    title: 'Service discount',
                    value: '(-) ${serviceDiscount.toString()}',
                    unite: true),
                buildText(
                    title: 'Coupon discount',
                    value: '(-) ${bookingDetailsContent.totalCouponDiscountAmount}',
                    unite: true),
                buildText(
                    title: 'Campaign discount',
                    value: '(-) ${bookingDetailsContent.totalCampaignDiscountAmount}',
                    unite: true),
                if (bookingDetailsContent.totalReferralDiscountAmount != null &&
                    bookingDetailsContent.totalReferralDiscountAmount! > 0)
                  buildText(
                      title: 'Referral discount',
                      value: '(-) ${bookingDetailsContent.totalReferralDiscountAmount}',
                      unite: true),
                if (bookingDetailsContent.extraFee != null &&
                    bookingDetailsContent.extraFee! > 0)
                  buildText(
                    title: Get.find<SplashController>().configModel.content?.additionalChargeLabelName ?? '',
                    value: '(+) ${bookingDetailsContent.extraFee?.toStringAsFixed(2)}',
                    unite: true,
                  ),
                buildText(
                    title: 'Tax',
                    value: '(+) ${bookingDetailsContent.totalTaxAmount!.toStringAsFixed(2)}',
                    unite: true),
                Divider(),
                if (isPartialPayment)
                  Column(children: [
                    buildText(
                      title: 'Grand Total',
                      titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      value: double.tryParse(
                              controller.bookingDetailsContent!.totalBookingAmount.toString())!
                          .toStringAsFixed(2),
                      unite: true,
                    ),
                    ListView.builder(
                      itemCount: bookingDetailsContent.partialPayments!.length,
                      itemBuilder: (context, index) {
                        final paidWith =
                            bookingDetailsContent.partialPayments?[index].paidWith ?? '';
                        return buildText(
                          title: '${paidWith == "digital" && bookingDetailsContent.paymentMethod == "offline_payment" ? "" : (paidWith == "wallet" || paidWith == "digital") ? "Paid by " : ""}${paidWith == "digital" && bookingDetailsContent.paymentMethod == "offline_payment" ? "Offline Payment" : paidWith == "digital" ? bookingDetailsContent.paymentMethod : paidWith == "wallet" ? "wallet" : "Cash After Service"}',
                          value: bookingDetailsContent.partialPayments?[index].paidAmount?.toString() ?? '0',
                        );
                      },
                    ),
                    if (bookingDetailsContent.partialPayments?.length == 1 && dueAmount > 0)
                      buildText(title: 'Due amount (Cash after service)', value: '$dueAmount'),
                    if (bookingDetailsContent.additionalCharge != 0 &&
                        bookingDetailsContent.paymentMethod != 'cash_after_service')
                      buildText(
                        title: bookingDetailsContent.additionalCharge != null &&
                                bookingDetailsContent.additionalCharge! > 0
                            ? (bookingDetailsContent.bookingStatus == 'pending' ||
                                    bookingDetailsContent.bookingStatus == 'accepted' ||
                                    bookingDetailsContent.bookingStatus == 'ongoing')
                                ? 'Due Amount (Cash after service)'
                                : 'Paid Amount (Cash after service)'
                            : 'Refund amount',
                        titleStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                        value: (bookingDetailsContent.additionalCharge ?? 0).toStringAsFixed(2),
                        unite: true,
                      ),
                  ])
                else
                  Column(children: [
                    buildText(
                      title: 'Grand Total',
                      titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      value: controller.bookingDetailsContent!.totalBookingAmount!
                          .toStringAsFixed(2),
                      unite: true,
                    ),
                    if (bookingDetailsContent.additionalCharge != null &&
                        bookingDetailsContent.additionalCharge! > 0 &&
                        bookingDetailsContent.paymentMethod != 'cash_after_service')
                      Column(children: [
                        buildText(
                          title: 'Paid Amount (${bookingDetailsContent.paymentMethod == "offline_payment" ? "Offline" : bookingDetailsContent.paymentMethod == "wallet_payment" ? "Wallet" : bookingDetailsContent.paymentMethod == "cash_after_service" ? "Cash After Service" : bookingDetailsContent.paymentMethod})',
                          titleStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                          value: ((bookingDetailsContent.totalBookingAmount ?? 0) -
                                  (bookingDetailsContent.additionalCharge ?? 0))
                              .toStringAsFixed(2),
                          unite: true,
                        ),
                        if (bookingDetailsContent.additionalCharge! > 0)
                          buildText(
                            title: (bookingDetailsContent.bookingStatus == 'pending' ||
                                    bookingDetailsContent.bookingStatus == 'accepted' ||
                                    bookingDetailsContent.bookingStatus == 'ongoing')
                                ? 'Due Amount (Cash after service)'
                                : 'Paid Amount (Cash after service)',
                            titleStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                            value: (bookingDetailsContent.additionalCharge ?? 0).toStringAsFixed(2),
                            unite: true,
                          ),
                      ]),
                  ]),
                SizedBox(height: 2 * PdfPageFormat.mm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildFooter(BookingDetailsContent bookingDetailsContent) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'If you require any assistance or have feedback or suggestions about our site, you can call or email us.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            color: _T1.footerBg,
            width: double.infinity,
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(Get.find<SplashController>().configModel.content?.businessPhone ?? ''),
                    SizedBox(width: 20),
                    Text(Get.find<SplashController>().configModel.content?.businessEmail ?? ''),
                  ],
                ),
                SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Text(AppConstants.baseUrl),
                SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Text(
                  Get.find<SplashController>().configModel.content?.footerText ?? '',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );

  // =========================================================================
  // SHARED HELPERS
  // =========================================================================
  static Row buildSimpleText({required String title, required String value}) {
    final style = TextStyle(fontWeight: FontWeight.bold);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        SizedBox(width: Get.width * .4, child: Text(value)),
      ],
    );
  }

  static Container buildText({
    required String title,
    String? value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);
    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: unite ? style : null)),
          Text(value ?? '', style: unite ? style : null),
        ],
      ),
    );
  }

  static Widget buildInvoiceImage(
    ImageProvider? netImage,
    BookingDetailsContent bookingDetailsContent,
    Invoice invoice,
  ) {
    return Container(
      width:  Dimensions.invoiceImageWidth,
      height: Dimensions.invoiceImageHeight,
      child: netImage != null ? pw.Image(netImage) : SizedBox(),
    );
  }

  static Future<ImageProvider> downloadImage(String imageUrl) async {
    http.Response response = await http.get(Uri.parse(imageUrl));
    return MemoryImage(response.bodyBytes);
  }

  // =========================================================================
  // UTILITY
  // =========================================================================
  static String _payStatus(BookingDetailsContent c) {
    if (c.partialPayments != null && c.partialPayments!.isNotEmpty && c.isPaid == 0) {
      return 'Partially paid';
    }
    return c.isPaid == 0 ? 'Unpaid' : 'Paid';
  }

  static Widget _sm(String text) =>
      Text(text, style: TextStyle(fontSize: 9, color: PdfColors.grey800));
}
