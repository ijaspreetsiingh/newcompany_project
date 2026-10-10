import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class SubscriptionTransactionListview extends StatelessWidget {
  final List<SubscriptionTransactionModel> transactionList;
  const SubscriptionTransactionListview({super.key, required this.transactionList});

  @override
  Widget build(BuildContext context) {

    List<PopupMenuModel> menuList = [
      PopupMenuModel(title: "download_invoice", icon: Icons.download)
    ];

    return GetBuilder<BusinessSubscriptionController>(builder: (businessSubscriptionController){

      if(transactionList.isEmpty){
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: NoDataScreen(
            text:
            businessSubscriptionController.isActiveSuffixIcon && businessSubscriptionController.isSearchComplete && businessSubscriptionController.dateTimeRange == null ?
            "no_transaction_history_found_to_your_related_search" : businessSubscriptionController.dateTimeRange != null  ?
            "${"no_transaction_history_fount_between".tr.capitalizeFirst} : ${ DateConverter.dateStringMonthYear(businessSubscriptionController.dateTimeRange!.start)} - ${ DateConverter.dateStringMonthYear(businessSubscriptionController.dateTimeRange!.end)}" :
            "no_transaction_history", type: NoDataType.transaction,
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: InkCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            for (int index = 0; index < transactionList.length; index++) ...[
              if(index > 0)  Divider(height: 1, color: InkColors.border),
              TransactionHistoryRow(transaction: transactionList[index], menuList: menuList),
            ],
          ]),
        ),
      );
    });
  }
}


class TransactionHistoryRow extends StatelessWidget {
  final SubscriptionTransactionModel transaction;
  final List<PopupMenuModel> menuList;
  const TransactionHistoryRow({super.key, required this.transaction, required this.menuList});

  @override
  Widget build(BuildContext context) {

    bool isRefund = (transaction.trxType ?? "").contains("refund");

    String packageName = transaction.packageLog?.packageName ?? "";
    String title = packageName.isNotEmpty ?
    "${'subscription'.tr.trim().capitalizeFirst ?? 'Subscription'} — $packageName" :
    transaction.trxType?.tr ?? "";

    String date = transaction.createdAt != null ?
    DateConverter.dateStringMonthYear(DateConverter.isoUtcStringToLocalDate(transaction.createdAt ?? "")) : "";

    String meta = "${transaction.id ?? ""} · $date";

    double amount = (transaction.credit ?? 0) > 0 ? transaction.credit ?? 0 : transaction.debit ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(children: [

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(
                child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style:  TextStyle(fontSize: 13, height: 1.3, fontWeight: FontWeight.w600, color: InkColors.foreground),
                ),
              ),
              const SizedBox(width: 6),
              InkStatusChip(status: isRefund ? "refund" : "paid"),
            ]),
            const SizedBox(height: 4),
            Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis,
              style:  TextStyle(fontSize: 10.5, height: 1.3, color: InkColors.mutedForeground),
            ),
          ]),
        ),

        const SizedBox(width: 8),

        Row(mainAxisSize: MainAxisSize.min, children: [
          InkMoney(amount, style:  TextStyle(fontSize: 13, color: InkColors.foreground)),

          PopupMenuButton<PopupMenuModel>(
            shape:  RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault,)),
                side: BorderSide(color: InkColors.border)
            ),
            surfaceTintColor: InkColors.card,
            position: PopupMenuPosition.under, elevation: 8,
            shadowColor: Colors.black.withValues(alpha:0.15),
            itemBuilder: (BuildContext context) {
              return menuList.map((PopupMenuModel option) {
                return PopupMenuItem<PopupMenuModel>(
                  onTap: () async {
                    showCustomDialog(child: const CustomLoader());
                    String languageCode = Get.find<LocalizationController>().locale.languageCode;
                    String uri = "${AppConstants.baseUrl}${AppConstants.subscriptionTransactionInvoice}${transaction.id}/$languageCode";
                    if (kDebugMode) {
                      print("Uri : $uri");
                    }
                    await _launchUrl(Uri.parse(uri));
                    Get.back();
                  },
                  value: option,
                  height: 40,
                  child: Row(
                    children: [
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                      Icon(option.icon, size: Dimensions.fontSizeLarge,color: InkColors.inkSoft,),
                      const SizedBox(width: Dimensions.paddingSizeSmall,),
                      Text(option.title.tr, style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall
                      ),),
                    ],
                  ),
                );
              }).toList();
            },
            child:  Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.more_vert, size: 18, color: InkColors.mutedForeground),
            ),
          ),
        ]),

      ]),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}
