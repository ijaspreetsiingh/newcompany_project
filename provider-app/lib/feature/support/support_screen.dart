import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static String get _phone =>
      Get.find<SplashController>().configModel.content?.businessPhone?.toString() ?? '';
  static String get _email =>
      Get.find<SplashController>().configModel.content?.businessEmail ?? '';

  Future<void> _launch(Uri uri, {bool external = false}) async {
    try {
      await launchUrl(uri, mode: external ? LaunchMode.externalApplication : LaunchMode.platformDefault);
    } catch (_) {
      showCustomSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
    }
  }

  /// Help & Support → admin (technical support) se in-app chat
  Future<void> _openSupportChat() async {
    final content = Get.find<SplashController>().configModel.content;
    final String adminId = content?.adminDetails?.id ?? '';
    if (adminId.isEmpty) {
      showCustomSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
      return;
    }
    await Get.find<ConversationController>().createChannel(
      userID: adminId,
      referenceID: '',
      name: 'Technical support',
      image: content?.faviconFullPath ?? '',
      phone: _phone,
      userType: 'super-admin',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          InkTopBar(
            title: 'help_&_support'.tr,
            onBack: () => Get.back(),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 28),

                Center(
                  child: Column(children: [
                    Container(
                      height: 52,
                      width: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: InkColors.foreground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.support_agent_rounded, size: 24, color: InkColors.background),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      'How can we help?',
                      style: robotoBold.copyWith(
                        fontSize: 22,
                        height: 1.2,
                        color: InkColors.foreground,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Our care team usually replies within 5 minutes.',
                      textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(
                        fontSize: 12,
                        color: InkColors.mutedForeground,
                        decoration: TextDecoration.none,
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
                    color: InkColors.mutedForeground,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 10),

                InkCard(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Column(children: [
                      _topicRow(
                        title: 'Terms & conditions',
                        onTap: () => Get.toNamed(RouteHelper.getHtmlRoute(HtmlType.termsAndCondition.value)),
                      ),
                      _divider(),
                      _topicRow(
                        title: 'Privacy policy',
                        onTap: () => Get.toNamed(RouteHelper.getHtmlRoute(HtmlType.privacyPolicy.value)),
                      ),
                      _divider(),
                      _topicRow(
                        title: 'Refund policy',
                        onTap: () => Get.toNamed(RouteHelper.getHtmlRoute(HtmlType.refundPolicy.value)),
                      ),
                      _divider(),
                      _topicRow(
                        title: 'Cancellation policy',
                        onTap: () => Get.toNamed(RouteHelper.getHtmlRoute(HtmlType.cancellationPolicy.value)),
                      ),
                    ]),
                  ),
                ),

                const SizedBox(height: 28),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _divider() => Divider(height: 1, thickness: 1, color: InkColors.border);

  Widget _topicRow({required String title, required VoidCallback onTap}) {
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
                color: InkColors.foreground,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_rounded, size: 17, color: InkColors.mutedForeground),
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
              color: highlight ? InkColors.foreground.withValues(alpha: 0.45) : InkColors.border,
            ),
          ),
          child: Row(children: [
            Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: highlight ? InkColors.foreground : InkColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 18,
                color: highlight ? InkColors.background : InkColors.foreground,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  title,
                  style: robotoSemiBold.copyWith(
                    fontSize: 14,
                    height: 1.3,
                    color: InkColors.foreground,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: robotoRegular.copyWith(
                    fontSize: 12,
                    height: 1.4,
                    color: InkColors.mutedForeground,
                    decoration: TextDecoration.none,
                  ),
                ),
              ]),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 17, color: InkColors.mutedForeground),
          ]),
        ),
      ),
    );
  }
}
