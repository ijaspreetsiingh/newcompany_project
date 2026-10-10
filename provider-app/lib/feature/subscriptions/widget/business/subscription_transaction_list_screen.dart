import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';


class SubscriptionTransactionListScreen extends StatefulWidget {
  const SubscriptionTransactionListScreen({super.key});

  @override
  State<SubscriptionTransactionListScreen> createState() => _SubscriptionTransactionListScreenState();
}


class _SubscriptionTransactionListScreenState extends State<SubscriptionTransactionListScreen> {

  @override
  void initState() {
    super.initState();
    Get.find<BusinessSubscriptionController>().getSubscriptionTransactionList(1);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessSubscriptionController>(builder: (businessSubscriptionController){

      if(businessSubscriptionController.transactionList == null){
        return const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()));
      }

      return InkSection(
        title: "subscription_history".tr,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          const BusinessTransactionSearchWidget(),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          businessSubscriptionController.searchedTransactionList == null && !businessSubscriptionController.isSearchComplete ?
          const SizedBox(height: 240, child: BookingRequestItemShimmer()) :
          SubscriptionTransactionListview(transactionList: businessSubscriptionController.isSearchComplete ?
          businessSubscriptionController.searchedTransactionList! : businessSubscriptionController.transactionList ?? []),

        ]),
      );
    });
  }
}
