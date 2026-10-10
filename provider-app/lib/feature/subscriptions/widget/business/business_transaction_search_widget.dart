import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class BusinessTransactionSearchWidget extends StatelessWidget {
  const BusinessTransactionSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessSubscriptionController>(
      builder: (businessSubscriptionController){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 3),
                    decoration: BoxDecoration(
                      color: InkColors.card,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: InkColors.border),
                    ),
                    child: Row(
                      children: [
                         Icon(Icons.search_rounded, size: 16, color: InkColors.mutedForeground),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Expanded(
                          child: TextField(
                            controller: businessSubscriptionController.searchController,
                            style:  TextStyle(fontSize: 13, color: InkColors.foreground),
                            cursorColor: InkColors.foreground,
                            autofocus: false,
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.search,
                            onChanged: (text) => businessSubscriptionController.showSuffixIcon(context,text),
                            onSubmitted: (text){
                              if(text.isNotEmpty) {
                                businessSubscriptionController.clearSearchController(clearTextController: false);
                                businessSubscriptionController.getSearchedSubscriptionTransactionList(queryText: text, startDate: "", endDate: "");
                              }
                              FocusScope.of(context).unfocus();
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'search'.tr,
                              hintStyle:  TextStyle(fontSize: 13, color: InkColors.mutedForeground),
                              suffixIcon: businessSubscriptionController.isActiveSuffixIcon ? IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(width: 24, height: 24),
                                onPressed: () {
                                  if(businessSubscriptionController.searchController.text.trim().isNotEmpty) {
                                    businessSubscriptionController.clearSearchController();
                                  }
                                  FocusScope.of(context).unfocus();
                                },
                                icon:  Icon(Icons.cancel_outlined, size: 18, color: InkColors.mutedForeground),
                              ) : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: Dimensions.paddingSizeDefault),

                InkIconButton(
                  icon: Icons.calendar_today_outlined,
                  onTap: () async  {
                    DateTimeRange? dateTimeRange = await showDateRangePicker(
                      initialEntryMode: DatePickerEntryMode.calendar,
                      context: context,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(3000),
                      currentDate: DateTime.now(),
                    );
                    if (dateTimeRange !=null) {
                      businessSubscriptionController.dateTimeRange = dateTimeRange;
                      businessSubscriptionController.clearSearchController(shouldUpdate: false, clearDate: false);
                      businessSubscriptionController.getSearchedSubscriptionTransactionList(
                        queryText: "",
                        startDate: DateConverter.dateTimeStringToDate(dateTimeRange.start.toString()),
                        endDate: DateConverter.dateTimeStringToDate(dateTimeRange.end.toString()),
                      );
                    }
                  },
                ),
              ],
            ),

            businessSubscriptionController.dateTimeRange !=null ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: InkColors.card,
                border: Border.all(color: InkColors.border),
              ),
              margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),

              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall ),

              child: Row(mainAxisSize: MainAxisSize.min,children: [
                Text("${ DateConverter.dateStringMonthYear(businessSubscriptionController.dateTimeRange!.start)} - ${ DateConverter.dateStringMonthYear(businessSubscriptionController.dateTimeRange!.end)}",
                  style:  TextStyle(fontSize: 12, color: InkColors.mutedForeground),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                InkWell(
                  onTap: () => businessSubscriptionController.clearSearchController(),
                  child:  Icon(Icons.close, color: InkColors.mutedForeground, size: 16,),
                ),
              ],
              ),
            ) : const SizedBox(),
          ],
        );
      },
    );
  }
}
