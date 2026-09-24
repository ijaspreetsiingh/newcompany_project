import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning'.tr;
    if (hour < 17) return 'good_afternoon'.tr;
    return 'good_evening'.tr;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
      builder: (userController) {
        final userName = userController.userInfo.firstName ?? '';

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Ios27Tokens.radiusMd),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall,
                          ),
                          Text(
                            userName.isNotEmpty
                                ? '$userName 👋'
                                : '${'welcome_back'.tr} 👋',
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeOverLarge + 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall,
                          ),
                          Text(
                            '${'here_is_your_booking_overview_for_this_week'.tr}.',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          Ios27Tokens.radiusSm,
                        ),
                      ),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          Ios27Tokens.radiusSm,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
