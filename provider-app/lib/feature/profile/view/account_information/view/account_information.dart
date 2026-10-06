import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class AccountInformation extends StatefulWidget {
  const AccountInformation({super.key});
  @override
  State<AccountInformation> createState() => _AccountInformationState();
}

class _AccountInformationState extends State<AccountInformation> {
  final JustTheController tooltipController = JustTheController();

  static String _indianGrouping(num value) {
    final bool negative = value.isNegative;
    final double v = value.abs().toDouble();
    final bool isInt = v == v.roundToDouble();
    final String s = isInt ? v.round().toString() : v.toStringAsFixed(2);

    String whole;
    String dec = '';
    if (isInt) {
      whole = s;
    } else {
      final int idx = s.indexOf('.');
      whole = s.substring(0, idx);
      dec = s.substring(idx);
    }

    String grouped;
    if (whole.length <= 3) {
      grouped = whole;
    } else {
      final String last3 = whole.substring(whole.length - 3);
      String rest = whole.substring(0, whole.length - 3);
      final List<String> buffer = <String>[];
      while (rest.length > 2) {
        buffer.insert(0, rest.substring(rest.length - 2));
        rest = rest.substring(0, rest.length - 2);
      }
      if (rest.isNotEmpty) buffer.insert(0, rest);
      grouped = '${buffer.join(',')},$last3';
    }
    return '${negative ? '-' : ''}$grouped$dec';
  }

  @override
  void initState() {
    super.initState();
    Get.find<UserProfileController>().getProviderInfo(reload: true);
    Get.find<UserProfileController>().updateNumberOfTimeShowingDialog();
    Get.find<TransactionReportController>().getAllTransactionReportData(1);
  }

  double _amountOf(String? value) => double.tryParse(value ?? "0") ?? 0;

  void _onRequestWithdraw() {
    final UserProfileController userProfileController = Get.find<UserProfileController>();
    final account = userProfileController.providerModel?.content?.providerInfo?.owner?.account;

    final double receivableAmount = _amountOf(account?.accountReceivable);
    final double payableAmount = _amountOf(account?.accountPayable);
    final TransactionType transactionType = userProfileController.getTransactionType(payableAmount, receivableAmount);

    if (transactionType == TransactionType.withdrawAble || transactionType == TransactionType.adjustWithdrawAble) {
      Get.to(() => WithdrawRequestScreen(amount: userProfileController.getTransactionAmountAmount(payableAmount, receivableAmount)));
    } else {
      Get.toNamed(RouteHelper.transactions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: InkColors.foreground,
          backgroundColor: InkColors.card,
          onRefresh: () async {
            await Get.find<UserProfileController>().getProviderInfo(reload: true);
            await Get.find<TransactionReportController>().getAllTransactionReportData(1);
          },
          child: GetBuilder<UserProfileController>(
            builder: (userProfileController) {
              final account = userProfileController.providerModel?.content?.providerInfo?.owner?.account;

              final double receivableAmount = _amountOf(account?.accountReceivable);
              final double payableAmount = _amountOf(account?.accountPayable);
              final double pendingAmount = _amountOf(account?.balancePending);
              final double withdrawnAmount = _amountOf(account?.totalWithdrawn);
              final double receivedAmount = _amountOf(account?.receivedBalance);
              final double totalEarning = withdrawnAmount + receivedAmount;

              final TransactionType transactionType = userProfileController.getTransactionType(payableAmount, receivableAmount);

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  InkTopBar(title: 'account_information'.tr, onBack: () => Get.back()),

                  if (account != null) ...[
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(children: [
                        Row(children: [
                          Expanded(child: InkStat(label: 'account_receivable'.tr, value: '₹${_indianGrouping(receivableAmount)}')),
                          const SizedBox(width: 12),
                          Expanded(child: InkStat(label: 'pending_withdrawn'.tr, value: '₹${_indianGrouping(pendingAmount)}')),
                        ]),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: InkStat(label: 'already_withdrawn'.tr, value: '₹${_indianGrouping(withdrawnAmount)}')),
                          const SizedBox(width: 12),
                          Expanded(child: InkStat(label: 'total_earning'.tr, value: '₹${_indianGrouping(totalEarning)}')),
                        ]),
                      ]),
                    ),
                  ],

                  const SizedBox(height: 24),
                  InkSection(title: "Booking breakdown", child: const TransactionPieChart()),

                  const SizedBox(height: 24),
                  InkSection(
                    title: 'collect_cash'.tr,
                    child: transactionType == TransactionType.none
                        ? InkEmptyState('empty_balance'.tr)
                        : CollectCashCard(tooltipController),
                  ),

                  const SizedBox(height: 24),
                  InkSection(title: "Transaction chart", child: const TransactionChart()),

                  const SizedBox(height: 24),
                  InkSection(
                    title: "Recent transactions",
                    action: 'withdraw'.tr,
                    onAction: () => Get.toNamed(RouteHelper.transactions),
                    child: _recentTransactionCard(),
                  ),

                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkPrimaryButton(label: "Request withdraw", onTap: _onRequestWithdraw),
                  ),

                  const SizedBox(height: 32),

                ]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _recentTransactionCard() {
    return GetBuilder<TransactionReportController>(
      builder: (transactionReportController) {
        final bool isFetching = transactionReportController.loading || transactionReportController.isLoading;

        if (transactionReportController.transactionReportModel == null && isFetching) {
          return InkCard(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: InkColors.foreground),
              ),
            ),
          );
        }

        final rows = transactionReportController.allTransactionList.take(5).toList();

        if (rows.isEmpty) {
          return InkEmptyState('no_transaction_history'.tr);
        }

        return InkCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (int i = 0; i < rows.length; i++) ...[
                if (i != 0)  SizedBox(height: 1, child: ColoredBox(color: InkColors.border)),
                _TransactionRow(
                  title: (rows[i].trxType ?? '').tr,
                  meta: "${rows[i].id ?? ''} · ${DateConverter.dateStringMonthYear(
                    DateConverter.isoUtcStringToLocalDate(rows[i].createdAt ?? ''),
                    format: 'd MMM',
                  )}",
                  amount: rows[i].credit != null && rows[i].credit! > 0 ? rows[i].credit! : (rows[i].debit ?? 0.0),
                  isCredit: rows[i].credit != null && rows[i].credit! > 0,
                ),
              ],
            ]),
          ),
        );
      },
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final String title;
  final String meta;
  final double amount;
  final bool isCredit;

  const _TransactionRow({required this.title, required this.meta, required this.amount, required this.isCredit});

  @override
  Widget build(BuildContext context) {
    final Color color = isCredit ? InkColors.foreground : InkColors.mutedForeground;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(
              title.isEmpty ? 'transaction'.tr : title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:  TextStyle(
                fontSize: 13.5,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: InkColors.foreground,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              meta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:  TextStyle(fontSize: 11, height: 1.3, color: InkColors.mutedForeground),
            ),
          ]),
        ),
        const SizedBox(width: 12),
        Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(
            isCredit ? '+' : '−',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          InkMoney(
            amount,
            style: TextStyle(fontSize: 13.5, height: 1.2, fontWeight: FontWeight.w700, color: color),
          ),
        ]),
      ]),
    );
  }
}
