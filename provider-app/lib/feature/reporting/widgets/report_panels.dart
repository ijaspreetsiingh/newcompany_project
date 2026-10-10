import 'package:jassdbx_provider/feature/reporting/model/booking_report_model.dart';
import 'package:jassdbx_provider/feature/reporting/model/transaction_report_model.dart';
import 'package:jassdbx_provider/util/core_export.dart' hide BookingsCount;
import 'package:get/get.dart';

 TextStyle _tableHeadStyle = TextStyle(
  fontSize: 10.5,
  height: 1.3,
  fontWeight: FontWeight.w700,
  letterSpacing: 1.2,
  color: InkColors.mutedForeground,
);

 TextStyle _titleStyle = TextStyle(
  fontSize: 13,
  height: 1.3,
  fontWeight: FontWeight.w600,
  color: InkColors.foreground,
);

 TextStyle _metaStyle = TextStyle(
  fontSize: 11,
  height: 1.3,
  color: InkColors.mutedForeground,
);

 TextStyle _sectionTitleStyle = TextStyle(
  fontSize: 15,
  height: 1.2,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.2,
  color: InkColors.foreground,
);

 TextStyle _moneyStyle = TextStyle(
  fontFamily: 'SpaceGrotesk',
  fontSize: 13,
  height: 1.2,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.2,
  color: InkColors.foreground,
);

/// Indian digit grouping + configured currency symbol (mirrors `InkMoney`).
String inkMoney(num value) {
  final bool negative = value.isNegative;
  final double absValue = value.abs().toDouble();
  final bool isInt = absValue == absValue.roundToDouble();
  final String raw = absValue.toStringAsFixed(2);
  final int dot = raw.indexOf('.');
  String whole = raw.substring(0, dot);
  final String dec = raw.substring(dot);

  String grouped;
  if (whole.length <= 3) {
    grouped = whole;
  } else {
    final String last3 = whole.substring(whole.length - 3);
    String rest = whole.substring(0, whole.length - 3);
    final List<String> parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    grouped = '${parts.join(',')},$last3';
  }

  return '${negative ? '-' : ''}${PriceConverter.getCurrency()}$grouped${isInt ? '' : dec}';
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}

/// ---------------------------------------------------------------------------
/// Section header — same layout as [InkSection] but with a custom action widget.
/// ---------------------------------------------------------------------------
class ReportSectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  const ReportSectionHeader({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: _sectionTitleStyle),
            if (action != null) action!,
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Booking report — the booking / status / amount table.
/// ---------------------------------------------------------------------------
class BookingReportPanel extends StatelessWidget {
  const BookingReportPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingReportController>(builder: (bookingReportController) {

      if (bookingReportController.bookingReportModel == null) {
        return const SingleChildScrollView(child: BookingReportShimmer());
      }

      final List<BookingFilterData> bookings = bookingReportController.bookingReportFilterData;

      return ListView(
        controller: bookingReportController.scrollController,
        padding: const EdgeInsets.only(top: 4, bottom: 40),
        children: [

          InkSection(
            title: 'booking_report'.tr,
            child: bookings.isEmpty ?
            InkEmptyState('no_data_found'.tr) :
            InkCard(
              padding: EdgeInsets.zero,
              child: Column(children: [

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration:  BoxDecoration(
                    color: InkColors.secondary,
                    border: Border(bottom: BorderSide(color: InkColors.border)),
                  ),
                  child: Row(children: [
                    Expanded(child: Text('booking'.tr.toUpperCase(), style: _tableHeadStyle)),
                    const SizedBox(width: 12),
                    SizedBox(width: 76, child: Text('status'.tr.toUpperCase(), style: _tableHeadStyle)),
                    const SizedBox(width: 12),
                    SizedBox(width: 84, child: Text('amount'.tr.toUpperCase(), textAlign: TextAlign.right, style: _tableHeadStyle)),
                  ]),
                ),

                for (int i = 0; i < bookings.length; i++)
                  _BookingTableRow(booking: bookings[i], isLast: i == bookings.length - 1),

                if (bookingReportController.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),

              ]),
            ),
          ),

        ],
      );
    });
  }
}

class _BookingTableRow extends StatelessWidget {
  final BookingFilterData booking;
  final bool isLast;
  const _BookingTableRow({required this.booking, required this.isLast});

  @override
  Widget build(BuildContext context) {

    final String customerName =
        "${booking.customer?.firstName ?? ""} ${booking.customer?.lastName ?? ""}".trim();
    final String title = customerName.isNotEmpty ? customerName : "Booking #${booking.readableId ?? ""}";

    final List<String> metaParts = [];
    if (booking.readableId != null) metaParts.add("#${booking.readableId}");
    if (booking.createdAt != null) {
      final DateTime? date = DateTime.tryParse(booking.createdAt!);
      if (date != null) metaParts.add(DateConverter.dateMonthYearLocalTime(date));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null :  Border(bottom: BorderSide(color: InkColors.border)),
      ),
      child: Row(children: [

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: _titleStyle),
            if (metaParts.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(metaParts.join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis, style: _metaStyle),
            ],
          ]),
        ),

        const SizedBox(width: 12),
        SizedBox(
          width: 76,
          child: Text(_capitalize(booking.bookingStatus ?? ""), maxLines: 1, overflow: TextOverflow.ellipsis, style: _metaStyle),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 84,
          child: Text(inkMoney(booking.totalBookingAmount ?? 0), textAlign: TextAlign.right, style: _moneyStyle),
        ),

      ]),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Business report — key stats + status distribution bars.
/// ---------------------------------------------------------------------------
class BusinessReportPanel extends StatelessWidget {
  const BusinessReportPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingReportController>(builder: (bookingReportController) {

      final BookingsCount? counts = bookingReportController.bookingReportModel?.content?.bookingsCount;

      if (counts == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final int total = counts.totalBookings ?? 0;
      final int completed = counts.completed ?? 0;
      final int accepted = counts.accepted ?? 0;
      final int ongoing = counts.ongoing ?? 0;
      final int canceled = counts.canceled ?? 0;
      final int pending = total - (completed + accepted + ongoing + canceled);

      final double totalBookingAmount =
          bookingReportController.bookingReportModel?.content?.bookingAmount?.totalBookingAmount ?? 0;

      final double avgTicket = total > 0 ? totalBookingAmount / total : 0;
      final double cancelRate = total > 0 ? (canceled / total) * 100 : 0;

      final List<_StatusDistributionItem> bars = [
        if (completed > 0) _StatusDistributionItem('completed'.tr, completed, InkColors.foreground),
        if (accepted > 0) _StatusDistributionItem('accepted'.tr, accepted, InkColors.inkSoft),
        if (ongoing > 0) _StatusDistributionItem('ongoing'.tr, ongoing, InkColors.mutedForeground),
        if (pending > 0) _StatusDistributionItem('pending'.tr, pending, InkColors.border),
        if (canceled > 0) _StatusDistributionItem('canceled'.tr, canceled, InkColors.destructive),
      ];

      return ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 40),
        children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                InkStat(label: 'total_bookings'.tr, value: '$total'),
                InkStat(label: 'avg_ticket'.tr, value: inkMoney(avgTicket)),
                InkStat(label: 'completed'.tr, value: '$completed'),
                InkStat(label: 'cancel_rate'.tr, value: '${cancelRate.toStringAsFixed(0)}%'),
              ],
            ),
          ),

          if (total > 0 && bars.isNotEmpty) ...[
            const SizedBox(height: 20),
            InkSection(
              title: 'status_distribution'.tr,
              child: InkCard(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  for (int i = 0; i < bars.length; i++)
                    _StatusDistributionRow(item: bars[i], total: total, isLast: i == bars.length - 1),
                ]),
              ),
            ),
          ],

        ],
      );
    });
  }
}

class _StatusDistributionItem {
  final String label;
  final int count;
  final Color color;
  _StatusDistributionItem(this.label, this.count, this.color);
}

class _StatusDistributionRow extends StatelessWidget {
  final _StatusDistributionItem item;
  final int total;
  final bool isLast;
  const _StatusDistributionRow({required this.item, required this.total, required this.isLast});

  @override
  Widget build(BuildContext context) {

    final double percent = (item.count / total) * 100;
    final String percentLabel = percent == percent.roundToDouble()
        ? percent.toInt().toString()
        : percent.toStringAsFixed(1);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(item.label, style:  TextStyle(fontSize: 12, height: 1.3, fontWeight: FontWeight.w600, color: InkColors.foreground)),
          Text('$percentLabel%', style:  TextStyle(fontSize: 12, height: 1.3, fontWeight: FontWeight.w600, color: InkColors.mutedForeground)),
        ]),

        const SizedBox(height: 6),

        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: InkColors.secondary,
            borderRadius: BorderRadius.circular(50),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (percent / 100).clamp(0.0, 1.0).toDouble(),
            child: Container(
              height: 8,
              decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(50)),
            ),
          ),
        ),

      ]),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Transaction report — credits / debits stats + transaction rows.
/// ---------------------------------------------------------------------------
class TransactionReportPanel extends StatelessWidget {
  const TransactionReportPanel({super.key});

  void _selectTab(TransactionReportController controller, int index) {
    if (controller.tabController?.index == index) return;
    controller.tabController?.index = index;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransactionReportController>(builder: (transactionReportController) {

      if (transactionReportController.transactionReportModel == null) {
        return const Center(child: TransactionReportListShimmer());
      }

      final TransactionReportAccountInfo accountInfo = transactionReportController.accountInfo ??
          TransactionReportAccountInfo(
            balancePending: 0,
            receivedBalance: 0,
            accountPayable: 0,
            accountReceivable: 0,
            totalWithdrawn: 0,
          );

      final int tabIndex = transactionReportController.tabController?.index ?? 0;
      final List<TransactionReportData> transactions = tabIndex == 0
          ? transactionReportController.allTransactionList
          : tabIndex == 1
              ? transactionReportController.debitTransactionList
              : transactionReportController.creditTransactionList;

      final List<String> tabLabels = ['all'.tr, 'debit'.tr, 'credit'.tr];

      return ListView(
        controller: transactionReportController.scrollController,
        padding: const EdgeInsets.only(top: 4, bottom: 40),
        children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                InkStat(label: 'credits'.tr, value: inkMoney(accountInfo.receivedBalance ?? 0)),
                InkStat(label: 'debits'.tr, value: inkMoney(accountInfo.totalWithdrawn ?? 0)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          ReportSectionHeader(
            title: 'transactions_report'.tr,
            action: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              onSelected: (value) => _selectTab(
                transactionReportController,
                value == 'all' ? 0 : value == 'debit' ? 1 : 2,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(value: 'all', child: Text('all'.tr, style: robotoRegular)),
                PopupMenuItem(value: 'debit', child: Text('debit'.tr, style: robotoRegular)),
                PopupMenuItem(value: 'credit', child: Text('credit'.tr, style: robotoRegular)),
              ],
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(tabLabels[tabIndex], style:  TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2, color: InkColors.mutedForeground)),
                 Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: InkColors.mutedForeground),
              ]),
            ),
          ),

          transactions.isEmpty ?
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkEmptyState('no_data_found'.tr),
          ) :
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                for (int i = 0; i < transactions.length; i++)
                  _TransactionTableRow(transaction: transactions[i], isLast: i == transactions.length - 1),
              ]),
            ),
          ),

          if (transactionReportController.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),

        ],
      );
    });
  }
}

class _TransactionTableRow extends StatelessWidget {
  final TransactionReportData transaction;
  final bool isLast;
  const _TransactionTableRow({required this.transaction, required this.isLast});

  @override
  Widget build(BuildContext context) {

    final double debit = transaction.debit ?? 0;
    final double credit = transaction.credit ?? 0;
    final bool isDebit = debit > 0;
    final double amount = isDebit ? debit : credit;

    final String toUserName = transaction.toUser?.userType == "provider-admin"
        ? Get.find<UserProfileController>().providerModel?.content?.providerInfo?.companyName ?? ""
        : "${transaction.toUser?.firstName ?? ""} ${transaction.toUser?.lastName ?? ""}".trim();

    final String title = toUserName.isNotEmpty ? toUserName : (transaction.trxType ?? "").tr;

    final String date = transaction.createdAt != null
        ? DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate(transaction.createdAt!))
        : "";

    final String meta = [transaction.trxType == null ? "" : transaction.trxType!.tr, date]
        .where((part) => part.isNotEmpty)
        .join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast ? null :  Border(bottom: BorderSide(color: InkColors.border)),
      ),
      child: Row(children: [

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: _titleStyle),
            if (meta.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis, style: _metaStyle),
            ],
          ]),
        ),

        Text(
          '${isDebit ? '−' : '+'}${inkMoney(amount)}',
          style: _moneyStyle.copyWith(color: isDebit ? InkColors.destructive : InkColors.foreground),
        ),

      ]),
    );
  }
}
