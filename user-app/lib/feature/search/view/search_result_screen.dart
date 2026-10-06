// ignore_for_file: deprecated_member_use
import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:jdds/common/widgets/nest_service_list_items.dart';
import 'package:jdds/feature/search/widget/already_filtered_widget.dart';
import 'package:jdds/feature/search/widget/search_filter_button_widget.dart';
import 'package:jdds/feature/search/widget/search_shimmer_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';

/// nest. style "See All" / All Services screen
/// (reference: design_refrence/home-harmony-hub services.index)
/// - Clean back arrow + bold "Services" title + rounded search field
/// - "N services available" count line
/// - Vertical bordered service rows (nest. ServiceRow style)
class SearchResultScreen extends StatefulWidget {
  final String? queryText;
  final String? fromPage;

  /// Tab mode : bottom nav ke andar inline - back button / pop-widget nahi
  final bool isTabView;

  const SearchResultScreen({super.key, required this.queryText, this.fromPage, this.isTabView = false}) ;

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    _loadDart();
    super.initState();
  }

  Future<void> _loadDart() async {

    Get.find<AllSearchController>().clearAllFilterValue(shouldUpdate: false);
    Get.find<AllSearchController>().updateSortByType(widget.fromPage, shouldUpdate: false);
    Get.find<AllSearchController>().searchData(query:widget.queryText!, offset: 1, shouldUpdate: false);
    await Get.find<CategoryController>().getCategoryList(false);
    Get.find<AllSearchController>().resetCategoryCheckedList(shouldUpdate: false);
    Get.find<AllSearchController>().populatedSearchController(widget.queryText ?? "", shouldUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = GetBuilder<AllSearchController>(builder: (searchController){
      return FooterBaseView(
        scrollController: scrollController,
        child: searchController.searchServiceList == null ? const SearchShimmerWidget() :
        SizedBox(
          width: Dimensions.webMaxWidth,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Count line - nest. : "N services available"
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall,
                ),
                child: Text(
                  '${searchController.serviceModel?.content?.servicesContent?.total ?? 0} ${'results_found'.tr}',
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),

              const SearchFilterButtonWidget(),

              searchController.sortedByList.isNotEmpty && !ResponsiveHelper.isDesktop(context) ? const AlreadyFilteredWidget() : const SizedBox(),

              PaginatedListView(
                scrollController: scrollController,
                totalSize: searchController.serviceModel?.content?.servicesContent?.total,
                offset: searchController.serviceModel?.content?.servicesContent?.currentPage,
                onPaginate: (int offset) async => await searchController.searchData(query: searchController.searchController.text, offset: offset, shouldUpdate: false , reload: false),
                itemView: NestServiceViewVertical(
                  service: searchController.searchServiceList!,
                  noDataText: 'no_service_found'.tr,
                  noDataType: NoDataType.search,
                  fromPage:"search_page",
                ),
              )

            ],
          ),
        ),
      );
      },
    );

    /// Tab mode : bottom nav ke andar - bina CustomPopWidget ke (back press app handle kare)
    if (widget.isTabView) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const SearchAppBar(backButton: false),
        body: body,
      );
    }

    return CustomPopWidget(
      onPopInvoked: (){
        Get.find<AllSearchController>().clearSearchController();

      },
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,

        endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer():null,
        appBar: const SearchAppBar(backButton: true),

        body: body,
      ),
    );
  }
}



