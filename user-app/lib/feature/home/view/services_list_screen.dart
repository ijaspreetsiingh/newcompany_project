import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({super.key});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'All';
  
  // TODO: Replace with API: GET /services?category={category}&search={query}
  final List<Map<String, dynamic>> _services = [
    {
      'id': 1,
      'name': 'Full home deep cleaning',
      'category': 'Cleaning',
      'price': 2499,
      'rating': '4.89',
      'reviews': '8.2k',
      'duration': '4â€“5 hrs',
    },
    {
      'id': 2,
      'name': 'AC service & repatr',
      'category': 'AC & Appliance',
      'price': 499,
      'rating': '4.85',
      'reviews': '12k',
      'duration': '60 mins',
    },
    {
      'id': 3,
      'name': 'Plumbing repatr',
      'category': 'Repatrs',
      'price': 299,
      'rating': '4.82',
      'reviews': '5.4k',
      'duration': '45 mins',
    },
    {
      'id': 4,
      'name': 'Glow facial at home',
      'category': 'Salon',
      'price': 899,
      'rating': '4.91',
      'reviews': '3.1k',
      'duration': '75 mins',
    },
  ];

  final List<String> _categories = ['All', 'Cleaning', 'AC & Appliance', 'Repatrs', 'Salon'];

  @override
  Widget build(BuildContext context) {
    final filtered = _services.where((s) {
      final matchesCategory = selectedCategory == 'All' || s['category'] == selectedCategory;
      final matchesSearch = _searchController.text.isEmpty ||
          s['name'].toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).textTheme.bodyLarge!.color),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'services'.tr,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: Theme.of(context).textTheme.bodyLarge!.color),
            onPressed: () {
              // TODO: Open filter sheet
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            Container(
              margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'what_service_do_you_need'.tr,
                  hintStyle: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Colors.grey[500],
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, color: Colors.grey[600]),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),

            // Category Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories
                      .map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                          child: FilterChip(
                            label: Text(cat),
                            selected: selectedCategory == cat,
                            onSelected: (selected) {
                              setState(() => selectedCategory = cat);
                            },
                            backgroundColor: Colors.transparent,
                            side: BorderSide(
                              color: selectedCategory == cat ? primaryAccent : Colors.grey[300]!,
                            ),
                            labelStyle: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: selectedCategory == cat ? primaryAccent : Colors.grey[600],
                            ),
                            selectedColor: primaryAccent.withOpacity(0.1),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Results count + Sort button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filtered.length} services_found'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Colors.grey[600],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Open sort & filter sheet
                    },
                    child: Row(
                      children: [
                        Text(
                          'sort_and_filter'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: primaryAccent,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.tune, size: 16, color: primaryAccent),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Services Grid
            if (filtered.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text(
                        'no_services_found'.tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Text(
                        'try_different_search_or_remove_filter'.tr,
                        textAlign: TextAlign.center,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Column(
                  children: List.generate(
                    filtered.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                      child: _buildServiceCard(context, filtered[index]),
                    ),
                  ),
                ),
              ),

            // Trust Banner
            Container(
              margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user, color: primaryAccent),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'nest_protection'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                        Text(
                          'every_booking_includes_warranty'.tr,
                          style: robotoSmall.copyWith(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to service detail
      },
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: primaryAccent.withOpacity(0.1),
              ),
              child: Icon(Icons.cleaning_services, color: primaryAccent, size: 40),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['category'],
                    style: robotoSmall.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        '${service['rating']} Â· ${service['reviews']}',
                        style: robotoSmall.copyWith(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'â‚¹${service['price']} onwards',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.bookmark_border,
                color: primaryAccent,
                size: 20,
              ),
              onPressed: () {
                // TODO: Add to favorites
              },
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}


