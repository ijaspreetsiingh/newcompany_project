import 'package:jassdbx_provider/feature/transaction/widget/withdraw_list_shimmer.dart';
import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

double _amountOf(String? value) => double.tryParse(value ?? "0") ?? 0;

String _rupeeGroup(num value) {
  final bool negative = value.isNegative;
  final double v = value.abs().toDouble();
  final bool isInt = v == v.roundToDouble();
  final String s = isInt ? v.round().toString() : v.toStringAsFixed(2);

  String whole;
  String? dec;
  if (!isInt) {
    final int idx = s.indexOf('.');
    whole = s.substring(0, idx);
    dec = s.substring(idx);
  } else {
    whole = s;
  }

  String result;
  if (whole.length <= 3) {
    result = whole;
  } else {
    final String last3 = whole.substring(whole.length - 3);
    String rest = whole.substring(0, whole.length - 3);
    final List<String> buf = <String>[];
    while (rest.length > 2) {
      buf.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) buf.insert(0, rest);
    result = '${buf.join(',')},$last3';
  }
  return '${negative ? '-' : ''}$result${dec ?? ''}';
}

class TransactionScreen extends StatefulWidget {
  final String? fromNotification;
  const TransactionScreen({super.key, this.fromNotification = ""});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {

  final TextEditingController _amountController = TextEditingController();
  String _selectedMethodId = "";
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    Get.find<TransactionController>().getWithdrawRequestList(1, false, shouldUpdate: widget.fromNotification == "from_notification" ? false : true);
    Get.find<UserProfileController>().getProviderInfo(reload: true);
    Get.find<TransactionController>().getWithdrawMethods(isReload: true);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _effectiveMethodId(List<WithdrawalMethod> methods) {
    if (_selectedMethodId.isNotEmpty && methods.any((m) => m.id == _selectedMethodId)) {
      return _selectedMethodId;
    }
    for (final WithdrawalMethod method in methods) {
      if (method.isDefault == 1) return method.id ?? "";
    }
    return methods.isNotEmpty ? (methods.first.id ?? "") : "";
  }

  void _openRequest(TransactionController transactionController, double available) {
    final List<WithdrawalMethod> methods = (transactionController.withdrawModel?.withdrawalMethods ?? [])
        .where((m) => m.isActive != 0)
        .toList();

    final String id = _effectiveMethodId(methods);
    String name = "";
    for (final WithdrawalMethod method in methods) {
      if (method.id == id) {
        name = method.methodName ?? "";
        break;
      }
    }

    Get.to(() => WithdrawRequestScreen(
      amount: available,
      initialAmount: _amountController.text,
      initialMethodId: id,
      initialMethodName: name,
    ));
  }

  Widget _methodPill(WithdrawalMethod method, String effectiveId) {
    final bool active = method.id == effectiveId;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethodId = method.id ?? ""),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? InkColors.foreground : InkColors.card,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: active ? Colors.transparent : InkColors.border),
        ),
        child: Text(
          method.methodName ?? "",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.5,
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: active ? InkColors.background : InkColors.foreground,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkColors.background,
      body: SafeArea(
        child: GetBuilder<UserProfileController>(builder: (userProfileController) {

          final account = userProfileController.providerModel?.content?.providerInfo?.owner?.account;
          final double receivable = _amountOf(account?.accountReceivable);
          final double payable = _amountOf(account?.accountPayable);
          final double available = userProfileController.getTransactionAmountAmount(payable, receivable);
          final double pending = _amountOf(account?.balancePending);

          return GetBuilder<TransactionController>(builder: (transactionController) {

            final List<TransactionData> all = transactionController.transactionsList ?? [];

            if (transactionController.isLoading && all.isEmpty) {
              return const WithdrawListShimmer();
            }

            final List<String> pillItems = ['all'.tr, 'paid'.tr, 'unpaid'.tr];
            final List<TransactionData> filtered = _filterIndex == 0
                ? all
                : all.where((t) => _filterIndex == 1 ? t.isPaid == 1 : t.isPaid != 1).toList();

            final List<WithdrawalMethod> methods = (transactionController.withdrawModel?.withdrawalMethods ?? [])
                .where((m) => m.isActive != 0)
                .toList();
            final String effectiveMethodId = _effectiveMethodId(methods);

            return RefreshIndicator(
              color: InkColors.foreground,
              backgroundColor: InkColors.card,
              onRefresh: () async {
                await transactionController.getWithdrawRequestList(1, false);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: transactionController.scrollController,
                padding: const EdgeInsets.only(bottom: 32),
                children: [

                  InkTopBar(
                    title: 'withdraw'.tr,
                    subtitle: "${'balance'.tr} ₹${_rupeeGroup(available)}",
                    onBack: () {
                      if (widget.fromNotification == "fromNotification") {
                        Get.offAllNamed(RouteHelper.getInitialRoute());
                      } else {
                        Get.back();
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(children: [
                      Expanded(child: InkStat(label: "Available", value: '₹${_rupeeGroup(available)}')),
                      const SizedBox(width: 12),
                      Expanded(child: InkStat(label: 'pending'.tr, value: '₹${_rupeeGroup(pending)}')),
                    ]),
                  ),

                  const SizedBox(height: 20),

                  InkSection(
                    title: 'new_request'.tr,
                    child: InkCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        InkEyebrow('amount'.tr),

                        const SizedBox(height: 6),

                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(20),
                          ],
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.only(top: 4, bottom: 8),
                            hintText: '0',
                            hintStyle: displayBold.copyWith(fontSize: 26, color: InkColors.mutedForeground),
                            enabledBorder:  UnderlineInputBorder(borderSide: BorderSide(color: InkColors.border)),
                            focusedBorder:  UnderlineInputBorder(borderSide: BorderSide(color: InkColors.foreground)),
                            border:  UnderlineInputBorder(borderSide: BorderSide(color: InkColors.border)),
                          ),
                          style: displayBold.copyWith(fontSize: 26, height: 1.2, color: InkColors.foreground),
                        ),

                        const SizedBox(height: 18),

                        const InkEyebrow('Method'),

                        const SizedBox(height: 10),

                        if (methods.isEmpty)
                          Text('no_data_found'.tr,
                            style:  TextStyle(fontSize: 12, height: 1.4, color: InkColors.mutedForeground),
                          )
                        else
                          for (int i = 0; i < methods.length; i += 2)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(children: [
                                Expanded(child: _methodPill(methods[i], effectiveMethodId)),
                                const SizedBox(width: 8),
                                if (i + 1 < methods.length)
                                  Expanded(child: _methodPill(methods[i + 1], effectiveMethodId))
                                else
                                  const Expanded(child: SizedBox()),
                              ]),
                            ),

                        const SizedBox(height: 10),

                        InkPrimaryButton(
                          label: "Request withdraw",
                          height: 46,
                          onTap: () => _openRequest(transactionController, available),
                        ),

                      ]),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkPills(
                      items: pillItems,
                      value: pillItems[_filterIndex],
                      onChanged: (value) => setState(() => _filterIndex = pillItems.indexOf(value)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  InkSection(
                    title: 'withdraw_list'.tr,
                    child: filtered.isEmpty
                        ? const NoDataScreen(text: "no_withdraw_history", type: NoDataType.transaction)
                        : InkCard(
                            padding: EdgeInsets.zero,
                            child: Column(children: [
                              for (int i = 0; i < filtered.length; i++) ...[
                                if (i > 0)  Divider(height: 1, thickness: 1, color: InkColors.border),
                                _WithdrawRow(data: filtered[i]),
                              ],
                            ]),
                          ),
                  ),

                  if (transactionController.paginationLoading == true)
                     Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: InkColors.foreground),
                        ),
                      ),
                    ),

                ],
              ),
            );
          });
        }),
      ),
    );
  }
}

class _WithdrawRow extends StatelessWidget {
  final TransactionData data;
  const _WithdrawRow({required this.data});

  @override
  Widget build(BuildContext context) {

    final bool paid = data.isPaid == 1;
    final String date = DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate(data.createdAt ?? ""));
    final String amount = '₹${_rupeeGroup(double.tryParse(data.amount ?? "0") ?? 0)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(amount,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:  TextStyle(fontSize: 13.5, height: 1.3, fontWeight: FontWeight.w600, color: InkColors.foreground),
            ),
            const SizedBox(height: 3),
            Text(date,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.ltr,
              style:  TextStyle(fontSize: 11, height: 1.3, color: InkColors.mutedForeground),
            ),
          ]),
        ),

        const SizedBox(width: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: paid ? InkColors.foreground : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: paid ? Colors.transparent : InkColors.border),
          ),
          child: Text(
            paid ? 'paid'.tr.toUpperCase() : 'pending'.tr.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              height: 1.2,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: paid ? InkColors.background : InkColors.mutedForeground,
            ),
          ),
        ),

      ]),
    );
  }
}
