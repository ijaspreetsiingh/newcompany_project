import 'dart:io';
import 'package:jassdbx_provider/util/app_constants.dart';
import 'package:jassdbx_provider/util/dimensions.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jassdbx_provider/helper/date_converter.dart';
import 'package:jassdbx_provider/feature/booking_details/controller/pdf_controller.dart';
import 'package:jassdbx_provider/feature/booking_details/controller/booking_details_controller.dart';
import 'package:jassdbx_provider/feature/booking_details/model/bookings_details_model.dart';
import 'package:jassdbx_provider/feature/booking_details/model/invoice.dart';
import 'package:jassdbx_provider/feature/booking_details/model/supplier.dart';
import 'package:jassdbx_provider/feature/splash/controller/splash_controller.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:jassdbx_provider/feature/booking_details/model/provider.dart' as provider;
import 'package:http/http.dart' as http;

// ---------------------------------------------------------------------------
// Template colour tokens — admin picks one via config key "invoice_template"
// ---------------------------------------------------------------------------
//  template_1 → Classic Blue  (original design)
//  template_2 → Modern Dark / Teal
//  template_3 → Clean Minimal / Green
// ---------------------------------------------------------------------------

class _T1 {
  static final header    = PdfColor.fromHex('4153b3');
  static final headerTxt = PdfColors.white;
  static final rowAlt    = PdfColors.grey100;
  static final accent    = PdfColor.fromHex('4153b3');
  static final footerBg  = PdfColor.fromHex('f2f2f2');
  static final titleTxt  = PdfColors.black;
}

class _T2 {
  static final header    = PdfColor.fromHex('1a1a2e');
  static final headerTxt = PdfColor.fromHex('00d4aa');
  static final rowAlt    = PdfColor.fromHex('f0faf8');
  static final accent    = PdfColor.fromHex('00d4aa');
  static final footerBg  = PdfColor.fromHex('1a1a2e');
  static final footerTxt = PdfColor.fromHex('00d4aa');
  static final titleTxt  = PdfColor.fromHex('1a1a2e');
}

class _T3 {
  static final header    = PdfColor.fromHex('2e7d32');
  static final headerTxt = PdfColors.white;
  static final rowAlt    = PdfColor.fromHex('f1f8f2');
  static final accent    = PdfColor.fromHex('2e7d32');
  static final footerBg  = PdfColor.fromHex('e8f5e9');
  static final titleTxt  = PdfColor.fromHex('1b5e20');
}

class PdfInvoiceApi {

  // -------------------------------------------------------------------------
  // Public entry point – reads invoiceTemplate from SplashController config
  // -------------------------------------------------------------------------
  static Future<File> generate(
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

    final date = DateTime.now();

    var invoice = Invoice(
      provider: provider.Provider(
        name: bookingDetailsContent.provider?.companyName ?? '',
        address: bookingDetailsContent.provider?.companyAddress ?? '',
      ),
      info: InvoiceInfo(
        date: date,
        description: 'Payment Status : ',
        number: bookingDetailsContent.readableId.toString(),
        paymentStatus: bookingDetailsContent.isPaid == 0 ? 'Unpaid' : 'Paid',
      ),
      items: items,
    );

    pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginBottom: 1.5 * PdfPageFormat.cm,
        marginLeft:   1.5 * PdfPageFormat.cm,
        marginRight:  1.5 * PdfPageFormat.cm,
      ),
      build: (context) => [
        _buildLogoBar(imageProvider, bookingDetailsContent, template),
        SizedBox(height: 0.8 * PdfPageFormat.cm),
        _buildHeader(invoice, bookingDetailsContent, template),
        SizedBox(height: 1 * PdfPageFormat.cm),
        _buildTable(invoice, template),
        SizedBox(height: 0.4 * PdfPageFormat.cm),
        buildTotal(bookingDetailsContent, controller),
      ],
      footer: (context) => _buildFooter(bookingDetailsContent, template),
    ));

    return PdfApi.saveDocument(
      name: 'invoice_${bookingDetailsContent.readableId}.pdf',
      pdf: pdf,
    );
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
      // Dark banner behind logo
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
                width:  Dimensions.invoiceImageWidth  * PdfPageFormat.cm,
                height: Dimensions.invoiceImageHeight * PdfPageFormat.cm,
                child:  pw.Image(img),
              )
            else
              SizedBox(
                width:  Dimensions.invoiceImageWidth  * PdfPageFormat.cm,
                height: Dimensions.invoiceImageHeight * PdfPageFormat.cm,
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('INVOICE',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _T2.headerTxt,
                    )),
                Text('# ${content.readableId}',
                    style: TextStyle(color: _T2.headerTxt, fontSize: 12)),
              ],
            ),
          ],
        ),
      );
    }

    if (template == 'template_3') {
      // Clean minimal — left-aligned logo with a coloured underline
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (img != null)
            pw.Image(img,
              width:  Dimensions.invoiceImageWidth  * PdfPageFormat.cm,
              height: Dimensions.invoiceImageHeight * PdfPageFormat.cm,
            )
          else
            SizedBox(
              width:  Dimensions.invoiceImageWidth  * PdfPageFormat.cm,
              height: Dimensions.invoiceImageHeight * PdfPageFormat.cm,
            ),
          SizedBox(height: 4),
          Container(height: 3, color: _T3.accent),
        ],
      );
    }

    // template_1 — original plain logo
    return Container(
      width:  Dimensions.invoiceImageWidth  * PdfPageFormat.cm,
      height: Dimensions.invoiceImageHeight * PdfPageFormat.cm,
      child: img != null ? pw.Image(img) : SizedBox(),
    );
  }

  // =========================================================================
  // HEADER (customer info left / provider info right)
  // =========================================================================
  static Widget _buildHeader(
    Invoice invoice,
    BookingDetailsContent content,
    String template,
  ) {
    if (template == 'template_2') {
      return _t2Header(invoice, content);
    }
    if (template == 'template_3') {
      return _t3Header(invoice, content);
    }
    // template_1
    return buildHeader(invoice, content);
  }

  // ---- template_2 header --------------------------------------------------
  static Widget _t2Header(Invoice invoice, BookingDetailsContent c) {
    final dateStr = DateConverter.dateStringMonthYear(invoice.info!.date);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left — customer
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _t2Label('Service Address'),
          if (c.customer != null) ...[
            _t2Value('${c.customer!.firstName} ${c.customer!.lastName ?? ""}'),
            if (c.customer!.email != null) _t2Value(c.customer!.email!),
            if (c.customer!.phone != null) _t2Value(c.customer!.phone!),
          ],
          if (c.serviceAddress != null)
            SizedBox(
              width: Get.width * .35,
              child: Text(c.serviceAddress!.address ?? '',
                  style: TextStyle(fontSize: 9)),
            ),
          SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _T2.accent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _paymentStatusLabel(c),
              style: TextStyle(
                  color: PdfColors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ]),
        // Right — serviceman + provider + date
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _t2Value('Date: $dateStr'),
          SizedBox(height: 4),
          if (c.serviceman != null) ...[
            _t2Label('Serviceman'),
            if (c.serviceman!.user != null)
              _t2Value(
                  '${c.serviceman!.user!.firstName} ${c.serviceman!.user!.lastName ?? ""}'),
            if (c.serviceman?.user?.phone != null)
              _t2Value(c.serviceman!.user!.phone!),
          ],
          SizedBox(height: 4),
          _t2Label('Provider'),
          if (c.provider?.companyName != null) _t2Value(c.provider!.companyName!),
          if (c.provider?.companyPhone != null) _t2Value(c.provider!.companyPhone!),
        ]),
      ],
    );
  }

  static Widget _t2Label(String text) => Text(text,
      style: TextStyle(
          fontWeight: FontWeight.bold, color: _T2.titleTxt, fontSize: 10));
  static Widget _t2Value(String text) => Text(text,
      style: TextStyle(fontSize: 9, color: PdfColors.grey800));

  // ---- template_3 header --------------------------------------------------
  static Widget _t3Header(Invoice invoice, BookingDetailsContent c) {
    final dateStr = DateConverter.dateStringMonthYear(invoice.info!.date);
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
            Text('INVOICE # ${c.readableId}',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _T3.titleTxt)),
            Text('Date: $dateStr',
                style: TextStyle(fontSize: 9, color: PdfColors.grey700)),
            SizedBox(height: 8),
            Text('Bill To',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _T3.accent,
                    fontSize: 10)),
            if (c.customer != null) ...[
              Text(
                  '${c.customer!.firstName} ${c.customer!.lastName ?? ""}',
                  style: TextStyle(fontSize: 9)),
              if (c.customer!.email != null)
                Text(c.customer!.email!,
                    style: TextStyle(fontSize: 9)),
              if (c.customer!.phone != null)
                Text(c.customer!.phone!,
                    style: TextStyle(fontSize: 9)),
            ],
            if (c.serviceAddress != null)
              SizedBox(
                width: Get.width * .35,
                child: Text(c.serviceAddress!.address ?? '',
                    style: TextStyle(fontSize: 9)),
              ),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(_paymentStatusLabel(c),
                style: TextStyle(
                    color: _T3.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 10)),
            SizedBox(height: 8),
            if (c.serviceman != null) ...[
              Text('Serviceman',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _T3.titleTxt,
                      fontSize: 10)),
              if (c.serviceman!.user != null)
                Text(
                    '${c.serviceman!.user!.firstName} ${c.serviceman!.user!.lastName ?? ""}',
                    style: TextStyle(fontSize: 9)),
              if (c.serviceman?.user?.phone != null)
                Text(c.serviceman!.user!.phone!,
                    style: TextStyle(fontSize: 9)),
            ],
            SizedBox(height: 4),
            Text('Provider',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _T3.titleTxt,
                    fontSize: 10)),
            if (c.provider?.companyName != null)
              Text(c.provider!.companyName!,
                  style: TextStyle(fontSize: 9)),
            if (c.provider?.companyPhone != null)
              Text(c.provider!.companyPhone!,
                  style: TextStyle(fontSize: 9)),
          ]),
        ],
      ),
    );
  }

  // =========================================================================
  // TABLE
  // =========================================================================
  static Widget _buildTable(Invoice invoice, String template) {
    final headers = [
      'Description', 'Unit Price', 'Quantity', 'Discount', 'Tax', 'Total',
    ];
    final data = invoice.items?.map((item) => [
      item.serviceName, item.unitPrice, item.quantity,
      item.discountAmount, item.tax, item.unitAllTotal,
    ]).toList() ?? [];

    if (template == 'template_2') {
      return TableHelper.fromTextArray(
        headers: headers,
        data: data,
        border: null,
        headerPadding: const EdgeInsets.symmetric(horizontal: 10),
        headerStyle: TextStyle(
            fontWeight: FontWeight.bold, color: _T2.headerTxt, fontSize: 9),
        rowDecoration: BoxDecoration(color: _T2.rowAlt),
        headerDecoration: BoxDecoration(
          color: _T2.header,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6), topRight: Radius.circular(6)),
        ),
        cellHeight: 28,
        columnWidths: {0: FixedColumnWidth(Get.width / 4)},
        cellAlignments: {
          0: Alignment.centerLeft,
          1: Alignment.center,
          2: Alignment.center,
          3: Alignment.center,
          4: Alignment.center,
          5: Alignment.center,
        },
      );
    }

    if (template == 'template_3') {
      return TableHelper.fromTextArray(
        headers: headers,
        data: data,
        border: pw.TableBorder.all(color: _T3.rowAlt, width: 0.5),
        headerPadding: const EdgeInsets.symmetric(horizontal: 10),
        headerStyle: TextStyle(
            fontWeight: FontWeight.bold, color: _T3.headerTxt, fontSize: 9),
        rowDecoration: BoxDecoration(color: PdfColors.white),
        oddRowDecoration: BoxDecoration(color: _T3.rowAlt),
        headerDecoration: BoxDecoration(color: _T3.header),
        cellHeight: 26,
        columnWidths: {0: FixedColumnWidth(Get.width / 4)},
        cellAlignments: {
          0: Alignment.centerLeft,
          1: Alignment.center,
          2: Alignment.center,
          3: Alignment.center,
          4: Alignment.center,
          5: Alignment.center,
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
    final phone    = Get.find<SplashController>().configModel.content?.businessPhone ?? '';
    final email    = Get.find<SplashController>().configModel.content?.businessEmail ?? '';
    final footer   = Get.find<SplashController>().configModel.content?.footerText ?? '';

    if (template == 'template_2') {
      return Container(
        color: _T2.header,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(phone,
                style: TextStyle(color: _T2.footerTxt, fontSize: 8)),
            Text(email,
                style: TextStyle(color: _T2.footerTxt, fontSize: 8)),
            Text(AppConstants.baseUrl,
                style: TextStyle(color: _T2.footerTxt, fontSize: 8)),
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
                      fontSize: 8,
                      color: _T3.titleTxt,
                      fontWeight: FontWeight.bold)),
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
  // ORIGINAL template_1 helpers (kept as-is so existing behaviour unchanged)
  // =========================================================================
  static Widget buildHeader(Invoice invoice, BookingDetailsContent bookingDetailsContent) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildCustomerAddress(bookingDetailsContent),
              buildInvoiceInfo(invoice.info, bookingDetailsContent),
            ],
          ),
        ],
      );

  static Widget buildCustomerAddress(BookingDetailsContent bookingDetailsContent) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Invoice Number # ${bookingDetailsContent.readableId!}',
              style: TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
          SizedBox(height: 0.5 * PdfPageFormat.cm),
          if (bookingDetailsContent.customer != null)
            Text('Service Address',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          SizedBox(height: 2 * PdfPageFormat.mm),
          if (bookingDetailsContent.customer != null)
            Text(
                'Customer Name: ${bookingDetailsContent.customer!.firstName} ${bookingDetailsContent.customer!.lastName!}'),
          SizedBox(height: 1 * PdfPageFormat.mm),
          if (bookingDetailsContent.customer != null &&
              bookingDetailsContent.customer!.email != null)
            Text('Email: ${bookingDetailsContent.customer!.email}'),
          SizedBox(height: 1 * PdfPageFormat.mm),
          if (bookingDetailsContent.customer != null &&
              bookingDetailsContent.customer!.phone != null)
            Text('Phone: ${bookingDetailsContent.customer!.phone}'),
          SizedBox(height: 1 * PdfPageFormat.mm),
          if (bookingDetailsContent.serviceAddress != null)
            Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: Get.width * .4,
                  child: Text(
                      'Address: ${bookingDetailsContent.serviceAddress?.address ?? ""}'),
                ),
              ],
            ),
          SizedBox(height: 4 * PdfPageFormat.mm),
          Text(
            'Payment Status: ${_paymentStatusLabel(bookingDetailsContent)}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      );

  static Widget buildInvoiceInfo(
      InvoiceInfo? info, BookingDetailsContent bookingDetailsContent) {
    final data = <String>[
      DateConverter.dateStringMonthYear(info!.date),
      info.paymentStatus,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('Booking Date: ${data[0]}'),
        SizedBox(height: 0.5 * PdfPageFormat.cm),
        if (bookingDetailsContent.serviceman != null)
          Text('Serviceman Details',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        if (bookingDetailsContent.serviceman != null)
          SizedBox(height: 1 * PdfPageFormat.mm),
        if (bookingDetailsContent.serviceman != null &&
            bookingDetailsContent.serviceman!.user != null)
          Text(
              '${bookingDetailsContent.serviceman!.user!.firstName} ${bookingDetailsContent.serviceman!.user!.lastName!}'),
        SizedBox(height: 1 * PdfPageFormat.mm),
        if (bookingDetailsContent.serviceman != null &&
            bookingDetailsContent.serviceman!.user!.phone != null)
          Text('${bookingDetailsContent.serviceman!.user!.phone}'),
        SizedBox(height: 0.5 * PdfPageFormat.cm),
        Text('Provider Details',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        SizedBox(height: 1 * PdfPageFormat.mm),
        if (bookingDetailsContent.provider?.companyName != null)
          Text('${bookingDetailsContent.provider!.companyName}'),
        SizedBox(height: 1 * PdfPageFormat.mm),
        if (bookingDetailsContent.provider?.companyPhone != null)
          Text('${bookingDetailsContent.provider!.companyPhone}'),
        SizedBox(height: 1 * PdfPageFormat.mm),
        if (bookingDetailsContent.provider?.companyAddress != null)
          Text('${bookingDetailsContent.provider!.companyAddress}'),
      ],
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
          Text('INVOICE',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 1 * PdfPageFormat.cm),
        ],
      );

  static Widget buildInvoice(Invoice invoice) {
    final headers = [
      'Description', 'Unit Price', 'Quantity', 'Discount', 'Tax', 'Total',
    ];
    final data = invoice.items?.map((item) => [
          item.serviceName, item.unitPrice, item.quantity,
          item.discountAmount, item.tax, item.unitAllTotal,
        ]).toList() ?? [];

    return TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerPadding: const EdgeInsets.symmetric(horizontal: 10),
      headerStyle:
          TextStyle(fontWeight: FontWeight.bold, color: PdfColor.fromHex('f2f2f2')),
      rowDecoration: const BoxDecoration(color: PdfColors.grey100),
      headerDecoration: BoxDecoration(
        color: _T1.header,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      cellHeight: 30,
      columnWidths: {0: FixedColumnWidth(Get.width / 4)},
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.center,
        2: Alignment.center,
        3: Alignment.center,
        4: Alignment.center,
        5: Alignment.center,
        6: Alignment.centerRight,
      },
    );
  }

  static Widget buildTotal(
      BookingDetailsContent bookingDetailsContent, BookingDetailsController controller) {
    double paidAmount = 0;
    double totalBookingAmount = bookingDetailsContent.totalBookingAmount ?? 0;
    bool isPartialPayment = bookingDetailsContent.partialPayments != null &&
        bookingDetailsContent.partialPayments!.isNotEmpty;

    if (isPartialPayment) {
      bookingDetailsContent.partialPayments?.forEach((element) {
        paidAmount = paidAmount + (element.paidAmount ?? 0);
      });
    } else {
      paidAmount = totalBookingAmount - (bookingDetailsContent.additionalCharge ?? 0);
    }
    double dueAmount = totalBookingAmount - paidAmount;

    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Spacer(flex: 4),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bookingDetailsContent.totalReferralDiscountAmount != null &&
                    bookingDetailsContent.totalReferralDiscountAmount! > 0)
                  buildText(
                    title: 'Referral discount',
                    value:
                        '(-) ${bookingDetailsContent.totalReferralDiscountAmount}',
                    unite: true,
                  ),
                if (bookingDetailsContent.extraFee != null &&
                    bookingDetailsContent.extraFee! > 0)
                  buildText(
                    title: Get.find<SplashController>()
                            .configModel
                            .content
                            ?.additionalChargeLabelName ??
                        '',
                    value:
                        '(+) ${bookingDetailsContent.extraFee?.toStringAsFixed(2)}',
                    unite: true,
                  ),
                buildText(
                  title: 'Tax',
                  value:
                      '(+) ${bookingDetailsContent.totalTaxAmount?.toStringAsFixed(2)}',
                  unite: true,
                ),
                Divider(),
                if (isPartialPayment)
                  Column(children: [
                    buildText(
                      title: 'Grand Total',
                      titleStyle: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      value: double.tryParse(controller
                                  .bookingDetails!
                                  .content!
                                  .totalBookingAmount
                                  .toString())!
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
                          value: bookingDetailsContent.partialPayments?[index].paidAmount.toString() ?? '0',
                        );
                      },
                    ),
                    if (bookingDetailsContent.partialPayments?.length == 1 &&
                        dueAmount > 0)
                      buildText(
                          title: 'Due amount (Cash after service)',
                          value: '$dueAmount'),
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
                        titleStyle: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.normal),
                        value:
                            (bookingDetailsContent.additionalCharge ?? 0).toStringAsFixed(2),
                        unite: true,
                      ),
                  ])
                else
                  Column(children: [
                    buildText(
                      title: 'Grand Total',
                      titleStyle: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      value: controller.bookingDetails!.content!.totalBookingAmount!
                          .toStringAsFixed(2),
                      unite: true,
                    ),
                    if (bookingDetailsContent.additionalCharge != null &&
                        bookingDetailsContent.additionalCharge! > 0 &&
                        bookingDetailsContent.paymentMethod != 'cash_after_service')
                      Column(children: [
                        buildText(
                          title:
                              'Paid Amount (${bookingDetailsContent.paymentMethod == "offline_payment" ? "Offline" : bookingDetailsContent.paymentMethod == "wallet_payment" ? "Wallet" : bookingDetailsContent.paymentMethod == "cash_after_service" ? "Cash After Service" : bookingDetailsContent.paymentMethod})',
                          titleStyle: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.normal),
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
                            titleStyle: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.normal),
                            value:
                                (bookingDetailsContent.additionalCharge ?? 0).toStringAsFixed(2),
                            unite: true,
                          ),
                      ]),
                  ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildFooter(BookingDetailsContent bookingDetailsContent) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'If you require any assistance or have feedback or suggestions about our site, you\n can email us or call us.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.5 * PdfPageFormat.cm),
          Container(
            decoration:
                BoxDecoration(color: _T1.footerBg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(),
                SizedBox(height: 1 * PdfPageFormat.mm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildSimpleText(
                        title: '',
                        value: Get.find<SplashController>()
                                .configModel
                                .content
                                ?.businessPhone ??
                            ''),
                    SizedBox(height: 6 * PdfPageFormat.mm),
                    buildSimpleText(
                        title: '',
                        value: Get.find<SplashController>()
                                .configModel
                                .content
                                ?.businessEmail ??
                            ''),
                  ],
                ),
                SizedBox(height: 1 * PdfPageFormat.mm),
                Text(AppConstants.baseUrl),
                SizedBox(height: 1 * PdfPageFormat.mm),
                buildSimpleText(
                    title: '',
                    value: Get.find<SplashController>()
                            .configModel
                            .content
                            ?.footerText ??
                        ''),
                SizedBox(height: 4 * PdfPageFormat.mm),
              ],
            ),
          ),
        ],
      );

  // =========================================================================
  // SHARED HELPERS
  // =========================================================================
  static pw.Row buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(value),
      ],
    );
  }

  static pw.Container buildText({
    required String title,
    required String value,
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
          Text(value, style: unite ? style : null),
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
      width:  Dimensions.invoiceImageWidth  * PdfPageFormat.cm,
      height: Dimensions.invoiceImageHeight * PdfPageFormat.cm,
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
  static String _paymentStatusLabel(BookingDetailsContent c) {
    if (c.partialPayments != null &&
        c.partialPayments!.isNotEmpty &&
        c.isPaid == 0) {
      return 'Partially Paid';
    }
    return c.isPaid == 0 ? 'Unpaid' : 'Paid';
  }
}
