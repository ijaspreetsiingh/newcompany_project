import 'dart:ui';

import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class MyServicesScreen extends StatefulWidget {
  final int initialCategoryIndex;
  final bool autoLoad;

  const MyServicesScreen({
    super.key,
    this.initialCategoryIndex = 0,
    this.autoLoad = true,
  });

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _searchFocused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final MyServicesController controller = Get.find<MyServicesController>();
      if (widget.initialCategoryIndex > 0) {
        controller.selectCategory(widget.initialCategoryIndex);
      }
      if (widget.autoLoad || !controller.hasFetchedOnce) {
        controller.getMyServices();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _stickyHeader(MyServicesController controller) {
    final double topInset = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: InkColors.background.withValues(alpha: 0.90),
        border: Border(bottom: BorderSide(color: InkColors.border)),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, topInset + 16, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'my_services'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: displayBold.copyWith(
                          fontSize: 22,
                          height: 1.15,
                          color: InkColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.totalServices} ${'services'.tr.toLowerCase()}  •  ${controller.totalSubCategories} ${'sub_category'.tr.toLowerCase()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(
                          fontSize: 12,
                          height: 1.3,
                          color: InkColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkIconButton(
                  icon: Icons.refresh_rounded,
                  onTap: () => controller.getMyServices(),
                ),
                if (controller.canAddService) ...[
                  const SizedBox(width: 8),
                  InkIconButton(
                    icon: Icons.add_rounded,
                    filled: true,
                    onTap: () => Get.to(() => const CreateServiceScreen()),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _permissionBanner(MyServicesController controller) {
    if (!controller.isReadOnly && controller.canEdit) {
      return const SizedBox.shrink();
    }

    final String message = controller.isReadOnly
        ? 'read_only_services_message'.tr
        : 'add_only_services_message'.tr;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: InkColors.card,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(color: InkColors.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility_outlined,
            size: 16,
            color: InkColors.mutedForeground,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                height: 1.4,
                color: InkColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField(MyServicesController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Focus(
        onFocusChange: (focused) {
          if (_searchFocused != focused) {
            setState(() => _searchFocused = focused);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: InkColors.paper,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _searchFocused ? InkColors.foreground : InkColors.border,
            ),
            boxShadow: _searchFocused
                ? [
                    BoxShadow(
                      color: InkColors.foreground.withValues(alpha: 0.07),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                height: 32,
                width: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: InkColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: InkColors.border),
                ),
                child: Icon(
                  Icons.search_rounded,
                  size: 17,
                  color: _searchFocused
                      ? InkColors.foreground
                      : InkColors.mutedForeground,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: InkColors.foreground,
                  ),
                  cursorColor: InkColors.foreground,
                  textInputAction: TextInputAction.search,
                  onChanged: controller.setSearchQuery,
                  decoration: InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintText: 'search_service_hint'.tr,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      fontWeight: FontWeight.w400,
                      color: InkColors.mutedForeground,
                    ),
                  ),
                ),
              ),
              if (controller.searchQuery.isNotEmpty)
                InkWell(
                  onTap: () {
                    _searchController.clear();
                    controller.clearSearch();
                    FocusScope.of(context).unfocus();
                    setState(() => _searchFocused = false);
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    height: 28,
                    width: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: InkColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 15,
                      color: InkColors.foreground,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int? count,
    IconData? icon,
    double radius = 50,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? InkColors.foreground : InkColors.card,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: isSelected ? InkColors.foreground : InkColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? InkColors.background
                    : InkColors.mutedForeground,
              ),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: isSelected
                  ? robotoSemiBold.copyWith(
                      fontSize: 13.5,
                      height: 1.2,
                      color: InkColors.background)
                  : robotoMedium.copyWith(
                      fontSize: 13.5,
                      height: 1.2,
                      color: InkColors.foreground),
            ),
            if (count != null) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? InkColors.background.withValues(alpha: 0.20)
                      : InkColors.accent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '$count',
                  style: robotoBold.copyWith(
                    fontSize: 11,
                    height: 1.2,
                    color: isSelected
                        ? InkColors.background
                        : InkColors.foreground,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusFilters(MyServicesController controller) {
    final List<Map<String, dynamic>> filters = [
      {'key': 'all', 'label': 'filter_all'.tr, 'count': controller.totalServices},
      {
        'key': 'mine',
        'label': 'filter_mine'.tr,
        'count': controller.categories.fold(
            0,
            (sum, c) =>
                sum +
                c.subCategories.fold(
                    0,
                    (s, sc) =>
                        s +
                        sc.services
                            .where((e) => e.isOwned && !e.isPending)
                            .length)),
      },
      {
        'key': 'admin',
        'label': 'filter_admin'.tr,
        'count': controller.categories.fold(
            0,
            (sum, c) =>
                sum +
                c.subCategories.fold(
                    0, (s, sc) => s + sc.services.where((e) => !e.isOwned).length)),
      },
      {
        'key': 'pending',
        'label': 'filter_pending'.tr,
        'count': controller.categories.fold(
            0,
            (sum, c) =>
                sum +
                c.subCategories.fold(
                    0, (s, sc) => s + sc.services.where((e) => e.isPending).length)),
      },
      {
        'key': 'edited',
        'label': 'filter_edited'.tr,
        'count': controller.categories.fold(
            0,
            (sum, c) =>
                sum +
                c.subCategories.fold(
                    0, (s, sc) => s + sc.services.where((e) => e.isEdited).length)),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: InkEyebrow('filter'.tr),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 0),
            itemCount: filters.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final Map<String, dynamic> filter = filters[index];
              return _chip(
                label: filter['label'] as String,
                count: filter['count'] as int,
                isSelected: controller.statusFilter == filter['key'],
                onTap: () => controller.setStatusFilter(filter['key'] as String),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _categoryChips(MyServicesController controller) {
    if (controller.isFiltering || controller.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: InkEyebrow('categories'.tr),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 0),
            itemCount: controller.categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final MyServiceCategory category = controller.categories[index];
              return _chip(
                label: category.name ?? '',
                icon: Icons.folder_open_rounded,
                radius: 12,
                count: category.subCategories.fold<int>(
                    0, (sum, sc) => sum + sc.services.length),
                isSelected: index == controller.selectedCategoryIndex &&
                    !controller.isFiltering,
                onTap: () => controller.selectCategory(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _serviceCard(MyServiceItem service) {
    final MyServicesController controller = Get.find<MyServicesController>();
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: MyServiceTile(
        service: service,
        canManage: controller.canEditService(service),
        onEdit: () => showCustomBottomSheet(
          child: EditServiceSheet(service: service),
        ),
        onDelete: () => _confirmDelete(service),
      ),
    );
  }

  Widget _subCategorySection(MyServiceSubCategory subCategory) {
    if (subCategory.services.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  (subCategory.name ?? '').toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: robotoSemiBold.copyWith(
                    fontSize: 12.5,
                    height: 1.2,
                    letterSpacing: 0.9,
                    color: InkColors.foreground,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: InkColors.accent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '${subCategory.services.length}',
                  style: robotoBold.copyWith(
                    fontSize: 11.5,
                    height: 1.2,
                    color: InkColors.foreground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ...subCategory.services.map(_serviceCard),
        ],
      ),
    );
  }

  void _confirmDelete(MyServiceItem service) {
    showCustomDialog(
      child: ConfirmationDialog(
        title: 'delete_service'.tr,
        description: service.parentServiceId == null
            ? 'delete_own_service_message'.tr
            : 'delete_clone_message'.tr,
        yesButtonText: 'yes'.tr,
        noButtonText: 'no'.tr,
        onYesPressed: () async {
          Get.back();
          await Get.find<MyServicesController>().deleteService(service.id);
        },
      ),
    );
  }

  Widget _emptyState(String message) {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: NoDataScreen(
            text: message,
            type: NoDataType.service,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkColors.background,
      body: GetBuilder<MyServicesController>(
        builder: (controller) {
          final bool showSkeleton =
              controller.isLoading && !controller.hasFetchedOnce;

          final Widget content;
          if (showSkeleton) {
            content = const CategorySubcategoryShimmer();
          } else if (controller.categories.isEmpty) {
            content = _emptyState('no_service_added_yet'.tr);
          } else if (controller.isFiltering) {
            final List<MyServiceItem> results = controller.filteredServices;
            content = results.isEmpty
                ? _emptyState('no_matching_service'.tr)
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkEyebrow(
                              '${results.length} ${'results'.tr.toLowerCase()}'),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          ...results.map(_serviceCard),
                        ],
                      ),
                    ),
                  );
          } else {
            final List<MyServiceSubCategory> subCategories =
                controller.visibleSubCategories;
            final bool hasAnyService =
                subCategories.any((e) => e.services.isNotEmpty);
            content = hasAnyService
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...subCategories.map(_subCategorySection),
                      ],
                    ),
                  )
                : _emptyState('no_service_in_this_sub_category'.tr);
          }

          return Column(
            children: [
              _stickyHeader(controller),
              _permissionBanner(controller),
              _searchField(controller),
              _statusFilters(controller),
              _categoryChips(controller),
              Expanded(
                child: showSkeleton
                    ? const CategorySubcategoryShimmer()
                    : RefreshIndicator(
                        color: InkColors.foreground,
                        backgroundColor: InkColors.card,
                        onRefresh: () => controller.getMyServices(),
                        child: content,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
