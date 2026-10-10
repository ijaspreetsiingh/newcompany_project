import 'package:jassdbx_serviceman/utils/core_export.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: context.kPrimary,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _block(context, 36, 36),
                          const Spacer(),
                          _block(context, 36, 36),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: _block(context, 96, 96, radius: 100),
                      ),
                      const SizedBox(height: 12),
                      Center(child: _block(context, 160, 22)),
                      const SizedBox(height: 6),
                      Center(child: _block(context, 110, 14)),
                      const SizedBox(height: 8),
                      Center(child: _block(context, 140, 20, radius: 4)),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: _block(context, 0, 40)),
                          const SizedBox(width: 16),
                          Expanded(child: _block(context, 0, 40)),
                          const SizedBox(width: 16),
                          Expanded(child: _block(context, 0, 40)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
              child: Column(
                children: [
                  _block(context, 0, 76),
                  const SizedBox(height: 20),
                  _block(context, 0, 224),
                  const SizedBox(height: 20),
                  _block(context, 0, 168),
                  const SizedBox(height: 20),
                  _block(context, 0, 48),
                ],
              ),
            ),
          ],
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
