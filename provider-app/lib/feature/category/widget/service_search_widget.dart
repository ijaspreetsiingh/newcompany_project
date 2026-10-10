import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class ServiceSearchWidget extends StatelessWidget {
  final String subcategoryId;
  const ServiceSearchWidget({super.key, required this.subcategoryId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceCategoryController>(
      builder: (serviceCategoryController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: InkColors.card,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: InkColors.border),
          ),
          child: Row(
            children: [
               Icon(
                Icons.search_rounded,
                size: 16,
                color: InkColors.mutedForeground,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: serviceCategoryController.searchController,
                  style:  TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color: InkColors.foreground,
                  ),
                  cursorColor: InkColors.foreground,
                  autofocus: false,
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.search,
                  onChanged: (text) =>
                      serviceCategoryController.showSuffixIcon(context, text),
                  onSubmitted: (text) {
                    if (text.isNotEmpty) {
                      serviceCategoryController
                          .getSearchedServiceListBasedOnSubcategory(
                            subCategoryId: subcategoryId,
                            queryText: text,
                          );
                    }
                    FocusScope.of(context).unfocus();
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'search_services'.tr,
                    hintStyle:  TextStyle(
                      fontSize: 13,
                      height: 1.3,
                      color: InkColors.mutedForeground,
                    ),
                    suffixIcon: serviceCategoryController.isActiveSuffixIcon
                        ? IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            onPressed: () {
                              if (serviceCategoryController
                                  .searchController.text
                                  .trim()
                                  .isNotEmpty) {
                                serviceCategoryController
                                    .clearSearchController();
                              }
                              FocusScope.of(context).unfocus();
                            },
                            icon:  Icon(
                              Icons.cancel_outlined,
                              size: 18,
                              color: InkColors.mutedForeground,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
