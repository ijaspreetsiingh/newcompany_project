import 'package:demandium_provider/util/core_export.dart';

/// Cover image with a safe placeholder — [CustomImage] crashes on null.
class ServiceCover extends StatelessWidget {
  final String? image;
  final double size;
  final double radius;

  const ServiceCover({
    super.key,
    required this.image,
    this.size = 58,
    this.radius = Dimensions.radiusSmall,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = image != null && image!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        height: size,
        width: size,
        color: InkColors.accent,
        alignment: Alignment.center,
        child: hasImage
            ? CustomImage(image: image, height: size, width: size)
            : Icon(
                Icons.design_services_outlined,
                size: size * 0.4,
                color: InkColors.mutedForeground,
              ),
      ),
    );
  }
}
