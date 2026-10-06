import 'package:demandium_serviceman/utils/core_export.dart';

class ProfileInfoShimmer extends StatelessWidget {
  const ProfileInfoShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 3),
      interval: const Duration(seconds: 5),
      color: Colors.white,
      colorOpacity: 0,
      enabled: true,
      direction: const ShimmerDirection.fromLTRB(),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _block(context, 96, 96, radius: 100)),
              const SizedBox(height: 20),
              _block(context, 90, 14),
              const SizedBox(height: 8),
              _block(context, 0, 48),
              const SizedBox(height: 20),
              _block(context, 60, 14),
              const SizedBox(height: 8),
              _block(context, 0, 48),
              const SizedBox(height: 20),
              _block(context, 100, 14),
              const SizedBox(height: 8),
              _block(context, 0, 48),
              const SizedBox(height: 20),
              _block(context, 90, 14),
              const SizedBox(height: 8),
              _block(context, 0, 48),
              const SizedBox(height: 20),
              _block(context, 0, 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _block(
    BuildContext context,
    double width,
    double height, {
    double radius = kRadiusMd,
  }) {
    return Container(
      width: width == 0 ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        color: context.kMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
