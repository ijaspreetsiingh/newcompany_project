import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';

/// nest. Help & support (reference: designnew SupportScreen)
/// support-intro · 3 × support-card · Popular topics menu-card
class SupportScreen extends StatelessWidget {
  SupportScreen({super.key});

  final Uri _callUri = Uri(
    scheme: 'tel',
    path: Get.find<SplashController>().configModel.content!.businessPhone.toString(),
  );

  final Uri _mailUri = Uri(
    scheme: 'mailto',
    path: Get.find<SplashController>().configModel.content!.businessEmail,
  );

  String get _phone =>
      Get.find<SplashController>().configModel.content!.businessPhone.toString();

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,
        endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
        backgroundColor: NestInk.background,
        appBar: CustomAppBar(
          title: 'help_&_support'.tr,
          bgColor: NestInk.background,
        ),
        body: Center(
          child: FooterBaseView(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: NestScreenBody(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// reference `.support-intro`
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 28),
                      child: Column(
                        children: [
                          Container(
                            height: 46,
                            width: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: NestInk.primary,
                            ),
                            child: Icon(
                              Icons.support_agent_rounded,
                              size: 22,
                              color: NestInk.background,
                            ),
                          ),
                          const SizedBox(height: 13),
                          Text(
                            'How can we help?',
                            style: NestInk.display(size: 24, weight: FontWeight.w800),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Our care team usually replies within 5 minutes.',
                            textAlign: TextAlign.center,
                            style: NestInk.body(size: 10, color: NestInk.mutedText),
                          ),
                        ],
                      ),
                    ),

                    /// in-app chat with admin (Help & Support se technical support)
                    _SupportCard(
                      highlight: true,
                      icon: Icons.messenger_outline_rounded,
                      title: 'Chat with support',
                      subtitle: 'Replies within minutes',
                      onTap: _openSupportChat,
                    ),

                    /// 3 × reference `.support-card`
                    _SupportCard(
                      icon: Icons.phone_outlined,
                      title: 'Call support',
                      subtitle: 'Available 8 AM – 10 PM',
                      onTap: () => _launch(_callUri),
                    ),
                    _SupportCard(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'WhatsApp us',
                      subtitle: 'Fastest response',
                      onTap: () => _launch(
                        Uri.parse(
                          'https://wa.me/${_phone.replaceAll(RegExp(r'[^0-9]'), '')}',
                        ),
                        external: true,
                      ),
                    ),
                    _SupportCard(
                      icon: Icons.mail_outline_rounded,
                      title: 'Email support',
                      subtitle: 'Replies within 24 hours',
                      onTap: () => _launch(_mailUri),
                    ),

                    /// reference `<SectionTitle title="Popular topics"/>`
                    NestSectionRow(
                      title: 'Popular topics',
                      margin: const EdgeInsets.only(top: 30, bottom: 14),
                    ),

                    NestMenuCard(
                      margin: EdgeInsets.zero,
                      children: [
                        NestMenuRow(
                          title: 'Reschedule a booking',
                          minHeight: 53,
                          onTap: () => Get.toNamed(RouteHelper.getBookingScreenRoute(true)),
                        ),
                        NestMenuRow(
                          title: 'Refunds & cancellations',
                          minHeight: 53,
                          onTap: () => Get.toNamed(RouteHelper.getRefundPolicyRoute()),
                        ),
                        NestMenuRow(
                          title: 'Payments & invoices',
                          minHeight: 53,
                          onTap: () => Get.toNamed(
                            Get.find<SplashController>().configModel.content?.walletStatus != 0
                                ? RouteHelper.getMyWalletScreen()
                                : RouteHelper.getBookingScreenRoute(true),
                          ),
                        ),
                        NestMenuRow(
                          title: 'Service warranty',
                          minHeight: 53,
                          onTap: () => _launch(
                            Uri(
                              scheme: 'mailto',
                              path: Get.find<SplashController>()
                                  .configModel
                                  .content!
                                  .businessEmail,
                              queryParameters: {'subject': 'Service warranty'},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launch(Uri uri, {bool external = false}) async {
    try {
      await launchUrl(
        uri,
        mode: external ? LaunchMode.externalApplication : LaunchMode.platformDefault,
      );
    } catch (_) {
      customSnackBar('Could not open the app');
    }
  }

  /// Help & Support → admin (technical support) se in-app chat
  Future<void> _openSupportChat() async {
    if (!Get.find<AuthController>().isLoggedIn()) {
      Get.toNamed(RouteHelper.getSignInRoute());
      return;
    }
    final content = Get.find<SplashController>().configModel.content;
    final String adminId = content?.adminDetails?.id ?? '';
    if (adminId.isEmpty) {
      customSnackBar('Could not start the chat');
      return;
    }
    await Get.find<ConversationController>().createChannel(
      adminId,
      '',
      name: 'Technical support',
      image: content?.faviconFullPath ?? '',
      phone: _phone,
      userType: 'super-admin',
    );
  }
}

/// reference `.support-card`
class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlight;

  const _SupportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          constraints: const BoxConstraints(minHeight: 67),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: highlight ? NestInk.primary.withValues(alpha: 0.5) : NestInk.border,
            ),
          ),
          child: Row(
            children: [
              highlight
                  ? NestIconWell(
                      icon: icon,
                      background: NestInk.primary,
                      foreground: NestInk.background,
                    )
                  : NestIconWell(icon: icon),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: NestInk.display(size: 12, weight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: NestInk.body(size: 9, color: NestInk.mutedText),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, size: 17, color: NestInk.mutedText),
            ],
          ),
        ),
      ),
    );
  }
}
