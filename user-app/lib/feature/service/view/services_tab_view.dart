import 'package:get/get.dart';
import 'package:jdds/common/widgets/nest_service_list_items.dart';
import 'package:jdds/feature/search/widget/already_filtered_widget.dart';
import 'package:jdds/feature/search/widget/search_filter_button_widget.dart';
import 'package:jdds/feature/search/widget/search_shimmer_widget.dart';
import 'package:jdds/util/core_export.dart';
import 'package:google_fonts/google_fonts.dart';

/// nest. style Services tab (inline bottom-nav view) - updated design
/// - "All" chip  â†’ ServiceController.getAllServiceList (home wali RELIABLE API,
///                 isliye SAARI services aati hain, kuch miss nahi hota)
/// - Category chip â†’ controller ke existing category-filter se filtered services
/// - Home pe category tap â†’ yahan aata hai + wahi chip active hoti hai
class ServicesTabView extends StatefulWidget {
  const ServicesTabView({super.key});

  @override
  State<ServicesTabView> createState() => _ServicesTabViewState();
}

class _ServicesTabViewState extends State<ServicesTabView> {
  final ScrollController scrollController = ScrollController();

  /// Currently selected category chip (null = All)
  int? selectedChipIndex;
  int _lastHandledCategoryRequestVersion = 0;

  @override
  void initState() {
    super.initState();

    /// Home se category tap ke saath aaye? (uske baad pending clear)
    final BottomNavController navController = Get.find<BottomNavController>();
    _lastHandledCategoryRequestVersion =
        navController.servicesCategoryRequestVersion;
    final String? pendingSlug = navController.pendingServicesCategorySlug;
    final String? pendingId = navController.pendingServicesCategoryId;
    navController.pendingServicesCategorySlug = null;
    navController.pendingServicesCategoryId = null;

    _loadData(initialCategorySlug: pendingSlug, initialCategoryId: pendingId);
  }

  /// Categories load + All services (reliable home API)
  Future<void> _loadData({
    String? initialCategorySlug,
    String? initialCategoryId,
  }) async {
    final CategoryController categoryController =
        Get.find<CategoryController>();
    await categoryController.getCategoryList(false);

    if (!mounted) return;

    if ((initialCategorySlug != null || initialCategoryId != null) &&
        categoryController.categoryList != null) {
      final categoryIndex = categoryController.categoryList!.indexWhere(
        (cat) =>
            (initialCategorySlug != null && cat.slug == initialCategorySlug) ||
            (initialCategoryId != null && cat.id == initialCategoryId),
      );

      if (categoryIndex >= 0) {
        selectedChipIndex = categoryIndex;
        Get.find<AllSearchController>().selectSingleCategory(
          categoryIndex,
          shouldUpdate: false,
        );
      }
    }

    /// All services reload (inttial pe bhi, taaki fresh list aaye)
    Get.find<AllSearchController>().searchData(
      query: Get.find<AllSearchController>().searchController.text.trim(),
      offset: 1,
      shouldUpdate: false,
      reload: true,
    );
  }

  void _listenForHomeCategoryRequest(BottomNavController navController) {
    final int requestVersion = navController.servicesCategoryRequestVersion;
    if (requestVersion == _lastHandledCategoryRequestVersion) return;

    _lastHandledCategoryRequestVersion = requestVersion;
    final String? categorySlug = navController.pendingServicesCategorySlug;
    final String? categoryId = navController.pendingServicesCategoryId;
    navController.pendingServicesCategorySlug = null;
    navController.pendingServicesCategoryId = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _applyHomeCategoryRequest(categorySlug, categoryId);
      }
    });
  }

  Future<void> _applyHomeCategoryRequest(
    String? categorySlug,
    String? categoryId,
  ) async {
    final CategoryController categoryController =
        Get.find<CategoryController>();
    if (categoryController.categoryList == null) {
      await categoryController.getCategoryList(false);
    }
    if (!mounted) return;

    final categories = categoryController.categoryList ?? <CategoryModel>[];
    final int? categoryIndex = categorySlug == null && categoryId == null
        ? null
        : categories.indexWhere(
            (category) =>
                (categorySlug != null && category.slug == categorySlug) ||
                (categoryId != null && category.id == categoryId),
          );
    final int? selectedIndex = categoryIndex != null && categoryIndex >= 0
        ? categoryIndex
        : null;

    final AllSearchController searchController =
        Get.find<AllSearchController>();
    searchController.selectSingleCategory(selectedIndex, shouldUpdate: false);
    setState(() => selectedChipIndex = selectedIndex);
    searchController.searchData(
      query: searchController.searchController.text.trim(),
      offset: 1,
      shouldUpdate: false,
      reload: true,
    );
  }

  /// Category chip tap - controller ke existing category-filter logic se
  void _onChipTap(int? chipIndex) {
    final AllSearchController searchController =
        Get.find<AllSearchController>();

    /// "All" chip (null) ya same chip dobara tap = deselect
    final int? nextSelection =
        chipIndex == null || selectedChipIndex == chipIndex ? null : chipIndex;
    searchController.selectSingleCategory(nextSelection, shouldUpdate: false);
    setState(() => selectedChipIndex = nextSelection);

    /// Filter ke saath dobara search (See All screen jaisa hi API flow)
    searchController.searchData(
      query: searchController.searchController.text.trim(),
      offset: 1,
      shouldUpdate: false,
      reload: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BottomNavController>(
      builder: (navController) {
        _listenForHomeCategoryRequest(navController);
        return _buildServicesTab(context);
      },
    );
  }

  Widget _buildServicesTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? const Color(0xFFF1F1F1)
        : const Color(0xFF141414);
    final mutedColor = isDark
        ? const Color(0xFFB3B3B3)
        : const Color(0xFF7D7D7D);
    final bgColor = isDark ? const Color(0xFF0D0D0D) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF333333)
        : const Color(0xFFE5E5E5);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      /// Search bar with a back action to return from Services to Home.
      appBar: SearchAppBar(
        backButton: true,
        onBackPressed: () =>
            Get.find<BottomNavController>().changePage(BnbItem.homePage),
      ),

      body: GetBuilder<AllSearchController>(
        builder: (searchController) {
          return FooterBaseView(
            scrollController: scrollController,
            child: searchController.searchServiceList == null
                ? const SearchShimmerWidget()
                : SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// â”€â”€ Category chips : All + categories (nest. pills) â”€â”€
                        GetBuilder<CategoryController>(
                          builder: (categoryController) {
                            final List<CategoryModel>? categories =
                                categoryController.categoryList;

                            if (categories == null || categories.isEmpty) {
                              return const SizedBox();
                            }

                            return SizedBox(
                              height: 56,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                physics: const ClampingScrollPhysics(),
                                itemCount: categories.length + 1,
                                itemBuilder: (context, index) {
                                  final bool isAll = index == 0;
                                  final bool isSelected = isAll
                                      ? selectedChipIndex == null
                                      : selectedChipIndex == index - 1;
                                  final CategoryModel category = isAll
                                      ? CategoryModel(name: 'all'.tr)
                                      : categories[index - 1];

                                  return Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      end: 10,
                                    ),
                                    child: InkWell(
                                      onTap: () =>
                                          _onChipTap(isAll ? null : index - 1),
                                      hoverColor: Colors.transparent,
                                      borderRadius: BorderRadius.circular(999),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 12,
                                        ),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          /// nest. chip : selected = black fill, unselected = hatrline border
                                          color: isSelected
                                              ? primaryColor
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? primaryColor
                                                : borderColor,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            /// Chip icon (All = apps icon, category = image)
                                            isAll
                                                ? Icon(
                                                    Icons.apps_rounded,
                                                    size: 18,
                                                    color: isSelected
                                                        ? bgColor
                                                        : mutedColor,
                                                  )
                                                : CustomImage(
                                                    image:
                                                        category
                                                            .imageFullPath ??
                                                        '',
                                                    height: 18,
                                                    width: 18,
                                                    fit: BoxFit.contain,
                                                  ),
                                            const SizedBox(width: 10),

                                            Text(
                                              category.name ?? '',
                                              style: GoogleFonts.dmSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: isSelected
                                                    ? bgColor
                                                    : mutedColor,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                        /// Count line - "N results found" (See All jaisa hi)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Text(
                            '${searchController.serviceModel?.content?.servicesContent?.total ?? 0} ${'results_found'.tr}',
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: mutedColor,
                            ),
                          ),
                        ),

                        /// Sort + Filter buttons (PEHLE JAISA HI - delete nahi kiya)
                        const SearchFilterButtonWidget(),

                        /// Applied filters chips (PEHLE JAISA HI)
                        searchController.sortedByList.isNotEmpty &&
                                !ResponsiveHelper.isDesktop(context)
                            ? const AlreadyFilteredWidget()
                            : const SizedBox(),

                        /// Services list - paginated (See All screen jaisa hi flow)
                        PaginatedListView(
                          scrollController: scrollController,
                          totalSize: searchController
                              .serviceModel
                              ?.content
                              ?.servicesContent
                              ?.total,
                          offset: searchController
                              .serviceModel
                              ?.content
                              ?.servicesContent
                              ?.currentPage,
                          onPaginate: (int offset) async =>
                              await searchController.searchData(
                                query: searchController.searchController.text,
                                offset: offset,
                                shouldUpdate: false,
                                reload: false,
                              ),
                          itemView: NestServiceViewVertical(
                            service: searchController.searchServiceList!,
                            noDataText: 'no_service_found'.tr,
                            noDataType: NoDataType.search,
                            fromPage: "search_page",
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
