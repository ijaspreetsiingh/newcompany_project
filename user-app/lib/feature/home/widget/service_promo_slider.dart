import 'package:jdds/util/core_export.dart';

/// Auto-sliding promo slider - Services section ke niche
/// Images URL se load hoti hain
class ServicePromoSlider extends StatefulWidget {
  const ServicePromoSlider({super.key});

  @override
  State<ServicePromoSlider> createState() => _ServicePromoSliderState();
}

class _ServicePromoSliderState extends State<ServicePromoSlider> {
  int _currentIndex = 0;

  /// Promo images - URL se
  static const List<String> _promoImages = [
    'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=900&q=70',
    'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=900&q=70',
    'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=900&q=70',
    'https://images.unsplash.com/photo-1504148455328-c376907d081c?auto=format&fit=crop&w=900&q=70',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Column(children: [

        Stack(children: [

          /// Auto sliding images - URL se
          CarouselSlider.builder(
            options: CarouselOptions(
              height: MediaQuery.of(context).size.width > 450 ? 200 : (MediaQuery.of(context).size.width * 0.35),
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: false,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) {
                setState(() => _currentIndex = index);
              },
            ),
            itemCount: _promoImages.length,
            itemBuilder: (context, index, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                child: CustomImage(
                  image: _promoImages[index],
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: Images.placeholder,
                ),
              );
            },
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        /// Dots indicator - SS layout
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_promoImages.length, (index) {
          bool isActive = index == _currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 7,
            width: isActive ? 18 : 7,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).hintColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
          );
        })),
      ]),
    );
  }
}
