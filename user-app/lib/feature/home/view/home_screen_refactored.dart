import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class HomeScreenRefactored extends StatelessWidget {
  const HomeScreenRefactored({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),
            // Location Pill
            _buildLocationPill(context),
            // Greeting
            _buildGreeting(context),
            // Search
            _buildSearchBox(context),
            // Categories
            _buildCategories(context),
            // Featured Service
            _buildFeaturedService(context),
            // Popular Services
            _buildPopularServices(context),
            // Campaign
            _buildCampaign(context),
            // Trust
            _buildTrustSection(context),
            // All Services
            _buildAllServices(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(shape: BoxShape.circle, color: primaryAccent),
                child: const Center(child: Text('n.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
              ),
              const SizedBox(width: 8),
              Text('nest.', style: robotoBold.copyWith(fontSize: 18)),
            ],
          ),
          Row(
            children: [
              IconButton(icon: Icon(Icons.notifications_none, color: Theme.of(context).textTheme.bodyLarge!.color), onPressed: () {}),
              IconButton(icon: Icon(Icons.favorite_border, color: Theme.of(context).textTheme.bodyLarge!.color), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPill(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(color: Theme.of(context).primaryColorLight, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('home'.tr, style: robotoSmall.copyWith(fontSize: 10, color: Colors.grey[600])),
                Text('Your Location', style: robotoMedium.copyWith(fontSize: 12)),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Icons.expand_more, size: 18, color: Theme.of(context).textTheme.bodyLarge!.color),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Good afternoon', style: robotoRegular.copyWith(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('What can we help\nwith today?', style: robotoBold.copyWith(fontSize: 24, color: Theme.of(context).textTheme.bodyLarge!.color, height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(RouteHelper.allServiceScreenRoute('home')),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[600]),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(child: Text('Search cleaning, AC, plumber...', style: robotoRegular.copyWith(fontSize: 14, color: Colors.grey[500]))),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      {'name': 'Cleaning', 'icon': Icons.cleaning_services},
      {'name': 'AC', 'icon': Icons.ac_unit},
      {'name': 'Plumber', 'icon': Icons.plumbing},
      {'name': 'Salon', 'icon': Icons.person},
      {'name': 'Electric', 'icon': Icons.electrical_services},
      {'name': 'Paint', 'icon': Icons.format_paint},
      {'name': 'Appliances', 'icon': Icons.kitchen},
      {'name': 'More', 'icon': Icons.more_horiz},
    ];

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: Dimensions.paddingSizeSmall,
          mainAxisSpacing: Dimensions.paddingSizeSmall,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: primaryAccent.withOpacity(0.1), shape: BoxShape.circle),
                child: Center(child: Icon(categories[index]['icon'] as IconData, color: primaryAccent, size: 24)),
              ),
              const SizedBox(height: 8),
              Text(categories[index]['name'] as String, textAlign: TextAlign.center, style: robotoSmall.copyWith(fontSize: 11, color: Theme.of(context).textTheme.bodyLarge!.color)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeaturedService(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        height: 200,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), color: primaryAccent.withOpacity(0.1)),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.6), Colors.transparent]),
                ),
              ),
            ),
            Positioned(
              bottom: Dimensions.paddingSizeDefault,
              left: Dimensions.paddingSizeDefault,
              right: Dimensions.paddingSizeDefault,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MOST BOOKED', style: robotoSmall.copyWith(fontSize: 10, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Deep clean.\nFresh start.', style: robotoBold.copyWith(fontSize: 20, color: Colors.white, height: 1.2)),
                  const SizedBox(height: 8),
                  Row(children: [Text('Book now', style: robotoMedium.copyWith(fontSize: 12, color: Colors.white)), const SizedBox(width: 4), Text('Â· â‚¹2,499', style: robotoMedium.copyWith(fontSize: 12, color: Colors.white))]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularServices(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Popular near you', style: robotoBold.copyWith(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge!.color)),
              GestureDetector(
                onTap: () => Get.toNamed(RouteHelper.allServiceScreenRoute('home')),
                child: Row(children: [Text('See all', style: robotoMedium.copyWith(fontSize: 12, color: primaryAccent)), const SizedBox(width: 4), Icon(Icons.arrow_forward, size: 14, color: primaryAccent)]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildServiceCard(context, 'Full home deep cleaning', 'â‚¹2,499', '4.89', '8.2k'),
          const SizedBox(height: 8),
          _buildServiceCard(context, 'AC service & repatr', 'â‚¹499', '4.85', '12k'),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String name, String price, String rating, String reviews) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault), border: Border.all(color: Colors.grey[300]!)),
      child: Row(
        children: [
          Container(width: 60, height: 60, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: primaryAccent.withOpacity(0.1)), child: Icon(Icons.cleaning_services, color: primaryAccent)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold.copyWith(fontSize: 13, color: Theme.of(context).textTheme.bodyLarge!.color)),
                const SizedBox(height: 4),
                Row(children: [const Icon(Icons.star, size: 10, color: Colors.orange), const SizedBox(width: 4), Text('$rating Â· $reviews', style: robotoSmall.copyWith(fontSize: 10, color: Colors.grey[600]))]),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [Text(price, style: robotoBold.copyWith(fontSize: 13, color: Theme.of(context).textTheme.bodyLarge!.color)), Text('onwards', style: robotoSmall.copyWith(fontSize: 9, color: Colors.grey[600]))],
          ),
          const SizedBox(width: 8),
          IconButton(icon: Icon(Icons.bookmark_border, color: primaryAccent, size: 20), onPressed: () {}, constraints: const BoxConstraints(), padding: EdgeInsets.zero),
        ],
      ),
    );
  }

  Widget _buildCampaign(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(color: primaryAccent, borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
        child: Row(
          children: [
            const Icon(Icons.local_offer, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NEW CUSTOMER', style: robotoSmall.copyWith(fontSize: 10, color: Colors.white)),
                  Text('â‚¹200 off your first booking', style: robotoBold.copyWith(fontSize: 14, color: Colors.white)),
                  Text('Use code NEST200', style: robotoSmall.copyWith(fontSize: 10, color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustSection(BuildContext context) {
    final items = [
      {'icon': Icons.verified_user, 'title': 'Verified pros', 'subtitle': 'Background checked'},
      {'icon': Icons.local_offer, 'title': 'Upfront pricing', 'subtitle': 'No hidden charges'},
      {'icon': Icons.shield, 'title': '7-day warranty', 'subtitle': "We've got you"},
      {'icon': Icons.support_agent, 'title': 'Real support', 'subtitle': 'Help when needed'},
    ];

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Why choose nest.', style: robotoBold.copyWith(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge!.color)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.2),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault), border: Border.all(color: Colors.grey[300]!)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(items[index]['icon'] as IconData, color: primaryAccent, size: 24),
                    const SizedBox(height: 8),
                    Text(items[index]['title'] as String, textAlign: TextAlign.center, style: robotoBold.copyWith(fontSize: 12, color: Theme.of(context).textTheme.bodyLarge!.color)),
                    const SizedBox(height: 4),
                    Text(items[index]['subtitle'] as String, textAlign: TextAlign.center, style: robotoSmall.copyWith(fontSize: 9, color: Colors.grey[600])),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAllServices(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('All services', style: robotoBold.copyWith(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge!.color)),
              GestureDetector(
                onTap: () => Get.toNamed(RouteHelper.allServiceScreenRoute('home')),
                child: Row(children: [Text('See all', style: robotoMedium.copyWith(fontSize: 12, color: primaryAccent)), const SizedBox(width: 4), Icon(Icons.arrow_forward, size: 14, color: primaryAccent)]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildServiceCard(context, 'Glow facial at home', 'â‚¹899', '4.91', '3.1k'),
          const SizedBox(height: 8),
          _buildServiceCard(context, 'Sofa & carpet cleaning', 'â‚¹1,299', '4.88', '4.5k'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

