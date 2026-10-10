import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class CollectCashCard extends StatelessWidget {
  final JustTheController toolTipController;
  const CollectCashCard(this.toolTipController, {super.key});

  String _balanceLabel(TransactionType transactionType) {
    switch (transactionType) {
      case TransactionType.payable:
        return "payable_balance".tr;
      case TransactionType.withdrawAble:
        return "receivable_balance".tr;
      case TransactionType.adjustAndPayable:
        return "final_payable_balance".tr;
      case TransactionType.adjustWithdrawAble:
        return "final_receivable_balance".tr;
      case TransactionType.adjust:
        return "adjustable_balance".tr;
      default:
        return "empty_balance".tr;
    }
  }

  String _balanceInfoText(TransactionType transactionType) {
    switch (transactionType) {
      case TransactionType.payable:
        return "payable_balance_text".tr;
      case TransactionType.withdrawAble:
        return "receivable_balance_text".tr;
      case TransactionType.adjustAndPayable:
        return "final_payable_balance_text".tr;
      case TransactionType.adjustWithdrawAble:
        return "final_receivable_balance_text".tr;
      case TransactionType.adjust:
        return "adjustable_balance_text".tr;
      default:
        return "";
    }
  }

  String _buttonLabel(TransactionType transactionType) {
    switch (transactionType) {
      case TransactionType.payable:
        return "pay_now".tr;
      case TransactionType.withdrawAble:
        return "withdraw".tr;
      case TransactionType.adjustAndPayable:
        return "adjust_and_pay".tr;
      case TransactionType.adjustWithdrawAble:
        return "adjust_and_withdraw".tr;
      case TransactionType.adjust:
        return "adjust".tr;
      default:
        return "empty_balance".tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(builder: (userProfileController) {
      double receivableAmount = double.tryParse(
        userProfileController.providerModel?.content?.providerInfo?.owner?.account?.accountReceivable ?? "0",
      ) ?? 0;
      double payableAmount = double.tryParse(
        userProfileController.providerModel?.content?.providerInfo?.owner?.account?.accountPayable ?? "0",
      ) ?? 0;

      double transactionAmount = userProfileController.getTransactionAmountAmount(payableAmount, receivableAmount);
      final TransactionType transactionType = userProfileController.getTransactionType(payableAmount, receivableAmount);

      if (transactionType == TransactionType.adjust) {
        transactionAmount = payableAmount;
      }

      return InkCard(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(
                'cash_in_hand'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:  TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                  color: InkColors.foreground,
                ),
              ),
              const SizedBox(height: 6),
              InkMoney(
                transactionAmount,
                style:  TextStyle(fontSize: 24, height: 1.1, color: InkColors.foreground),
              ),
              const SizedBox(height: 5),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Flexible(
                  child: Text(
                    _balanceLabel(transactionType),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:  TextStyle(fontSize: 11.5, height: 1.3, color: InkColors.mutedForeground),
                  ),
                ),
                const SizedBox(width: 6),
                JustTheTooltip(
                  backgroundColor: Colors.black87,
                  controller: toolTipController,
                  preferredDirection: AxisDirection.down,
                  tailLength: 14,
                  tailBaseWidth: 20,
                  content: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Text(
                      _balanceInfoText(transactionType),
                      style: robotoRegular.copyWith(color: Colors.white),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => toolTipController.showTooltip(),
                    child:  Icon(Icons.info_outline_rounded, color: InkColors.mutedForeground, size: 18),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(width: 12),
          GetBuilder<TransactionController>(builder: (transactionController) {
            if (transactionController.isLoading) {
              return Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: InkColors.foreground,
                  borderRadius: BorderRadius.circular(50),
                ),
                child:  SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: InkColors.background),
                ),
              );
            }

            return InkPrimaryButton(
              label: _buttonLabel(transactionType),
              height: 40,
              expanded: false,
              onTap: transactionType == TransactionType.none
                  ? null
                  : () {
                      final config = Get.find<SplashController>().configModel.content;

                      if (transactionType == TransactionType.payable || transactionType == TransactionType.adjustAndPayable) {
                        if (config?.digitalPayment == 0) {
                          showCustomSnackBar("no_payment_option_available".tr);
                        } else if ((config?.minimumPayableAmount ?? 0) <= transactionAmount) {
                          Get.find<DashboardController>().updateIndex(-1, isUpdate: false);
                          showModalBottomSheet(
                            context: context,
                            useRootNavigator: true,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => PaymentMethodDialog(amount: transactionAmount),
                          );
                        } else {
                          showCustomSnackBar(
                            "${'minimum_payable_amount'.tr} ${PriceConverter.convertPrice(config?.minimumPayableAmount ?? 0)}",
                          );
                        }
                      } else if (transactionType == TransactionType.withdrawAble ||
                          transactionType == TransactionType.adjustWithdrawAble) {
                        Get.to(() => WithdrawRequestScreen(amount: transactionAmount));
                      } else if (transactionType == TransactionType.adjust) {
                        transactionController.adjustTransaction();
                      }
                    },
            );
          }),
        ]),
      );
    });
  }
}
