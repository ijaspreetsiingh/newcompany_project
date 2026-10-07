import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

/// Help & support (customer app ke SupportScreen jaisa hi design)
/// support-intro · 3 × support-card · Popular topics menu-card
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static String get _phone =>
      Get.find<SplashController>().configModel?.content?.businessPhone?.toString() ?? '';
  static String get _email =>
      Get.find<SplashController>().configModel?.content?.businessEmail ?? '';

  Future<void> _launch(Uri uri, {bool external = false}) async {
    try {
      await launchUrl(uri, mode: external ? LaunchMode.externalApplication : LaunchMode.platformDefault);
    } catch (_) {
      showCustomSnackBar('something_went_wrong'.tr);
    }
  }

  /// Help & Support → admin (technical support) se in-app chat.
  /// Serviceman config me admin_details nahi aata, isliye thread-index ka
  /// auto-created `adminChannel` (reference_type = support) use hota hai.
  Future<void> _openSupportChat() async {
    final ConversationController conversation = Get.find<ConversationController>();
    if (conversation.adminConversationModel?.id == null) {
      await conversation.getChannelList(1, type: 'customer');
    }
    final ChannelData? adminChannel = conversation.adminConversationModel;
    if (adminChannel?.id == null) {
      showCustomSnackBar('something_went_wrong'.tr);
      return;
    }
    final content = Get.find<SplashController>().configModel?.content;
    Get.toNamed(RouteHelper.getChatScreenRoute(
      adminChannel!.id!,
      'Technical support',
      content?.faviconFullPath ?? '',
      _phone,
      'super-admin',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        backgroundColor: context.kBackground,
        body: SafeArea(
          bottom: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            PageHeader(
              title: 'help_&_support'.tr,
              onBack: () => Get.back(),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 28),

                  Center(
                    child: Column(children: [
                      Container(
                        height: 52,
                        width: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.kPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.support_agent_rounded,
                          size: 24,
                          color: context.kPrimaryForeground,
                        ),
                      ),
                      const SizedBox(height: 13),
                      Text(
                        'How can we help?',
                        style: robotoBold.copyWith(
                          fontSize: 22,
                          height: 1.2,
                          color: context.kForeground,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Our care team usually replies within 5 minutes.',
                        textAlign: TextAlign.center,
                        style: robotoRegular.copyWith(
                          fontSize: 12,
                          color: context.kMutedForeground,
                        ),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 26),

                  _SupportCard(
                    highlight: true,
                    icon: Icons.messenger_outline_rounded,
                    title: 'Chat with support',
                    subtitle: 'Replies within minutes',
                    onTap: _openSupportChat,
                  ),
                  _SupportCard(
                    icon: Icons.phone_outlined,
                    title: 'Call support',
                    subtitle: 'Available 8 AM – 10 PM',
                    onTap: () => _launch(Uri(scheme: 'tel', path: _phone)),
                  ),
                  _SupportCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'WhatsApp us',
                    subtitle: 'Fastest response',
                    onTap: () => _launch(
                      Uri.parse('https://wa.me/${_phone.replaceAll(RegExp(r'[^0-9]'), '')}'),
                      external: true,
                    ),
                  ),
                  _SupportCard(
                    icon: Icons.mail_outline_rounded,
                    title: 'Email support',
                    subtitle: 'Replies within 24 hours',
                    onTap: () => _launch(Uri(scheme: 'mailto', path: _email)),
                  ),

                  const SizedBox(height: 26),

                  Text(
                    'POPULAR TOPICS',
                    style: robotoMedium.copyWith(
                      fontSize: 11,
                      letterSpacing: 0.8,
                      color: context.kMutedForeground,
                    ),
                  ),
                  const SizedBox(height: 10),

                  KCard(
                    padding: EdgeInsets.zero,
                    child: Column(children: [
                      _topicRow(
                        context,
                        title: 'terms'.tr,
                        onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('terms-and-conditions')),
                      ),
                      Divider(height: 1, thickness: 1, color: context.kBorder),
                      _topicRow(
                        context,
                        title: 'privacy_policy_title'.tr,
                        onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('privacy-policy')),
                      ),
                      Divider(height: 1, thickness: 1, color: context.kBorder),
                      _topicRow(
                        context,
                        title: 'refund_policy'.tr,
                        onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('refund-policy')),
                      ),
                      Divider(height: 1, thickness: 1, color: context.kBorder),
                      _topicRow(
                        context,
                        title: 'cancellation_policy'.tr,
                        onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('cancellation-policy')),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 28),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _topicRow(BuildContext context, {required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 53),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Row(children: [
          Expanded(
            child: Text(
              title,
              style: robotoMedium.copyWith(
                fontSize: 13.5,
                color: context.kForeground,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_rounded, size: 17, color: context.kMutedForeground),
        ]),
      ),
    );
  }
}

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
              color: highlight ? context.kPrimary.withValues(alpha: 0.5) : context.kBorder,
            ),
          ),
          child: Row(children: [
            Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: highlight ? context.kPrimary : context.kCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 18,
                color: highlight ? context.kPrimaryForeground : context.kForeground,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  title,
                  style: robotoMedium.copyWith(
                    fontSize: 14,
                    height: 1.3,
                    color: context.kForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: robotoRegular.copyWith(
                    fontSize: 12,
                    height: 1.4,
                    color: context.kMutedForeground,
                  ),
                ),
              ]),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 17, color: context.kMutedForeground),
          ]),
        ),
      ),
    );
  }
}
