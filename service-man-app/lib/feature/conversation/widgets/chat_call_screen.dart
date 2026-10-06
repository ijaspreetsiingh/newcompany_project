import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

/// Professional voice-call screen used from chat.
///
/// Shows caller/callee info + call progress while the system dialer
/// (tel:) is launched. No third-party VoIP SDK required.
class ChatCallScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String image;
  final String role;

  const ChatCallScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.image,
    required this.role,
  });

  @override
  State<ChatCallScreen> createState() => _ChatCallScreenState();
}

class _ChatCallScreenState extends State<ChatCallScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  String _status = 'calling'.tr;
  bool _dialerOpened = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      lowerBound: 0.85,
      upperBound: 1.12,
    )..repeat(reverse: true);

    _launchDialer();
  }

  Future<void> _launchDialer() async {
    final String number = widget.phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (number.isEmpty) {
      if (mounted) setState(() => _status = 'no_phone_number'.tr);
      return;
    }
    final Uri uri = Uri(scheme: 'tel', path: number);
    bool opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (mounted) {
      setState(() {
        _dialerOpened = opened;
        _status = opened ? 'in_dialer'.tr : 'dialer_failed'.tr;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.kBackground,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [context.kPrimary, context.kPrimary.withValues(alpha: 0.82)],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(children: [
            const SizedBox(height: 24),

            Text(
              widget.role.toUpperCase(),
              style: robotoBold.copyWith(
                fontSize: 11,
                letterSpacing: 1.54,
                height: 1.2,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),

            const SizedBox(height: 40),

            ScaleTransition(
              scale: _pulseController,
              child: Container(
                height: 128,
                width: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                alignment: Alignment.center,
                child: ClipOval(
                  child: widget.image.isNotEmpty
                      ? CustomImage(
                          image: widget.image,
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 120,
                          width: 120,
                          color: Colors.white.withValues(alpha: 0.2),
                          alignment: Alignment.center,
                          child: Text(
                            widget.name.isNotEmpty
                                ? widget.name[0].toUpperCase()
                                : '?',
                            style: robotoBold.copyWith(
                              fontSize: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            Text(
              widget.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoBold.copyWith(fontSize: 24, height: 1.2, color: Colors.white),
            ),

            const SizedBox(height: 8),

            Text(
              widget.phone.isEmpty
                  ? ''
                  : (widget.phone.startsWith('+')
                        ? widget.phone
                        : '+${widget.phone}'),
              style: robotoRegular.copyWith(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              _status,
              style: robotoMedium.copyWith(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),

            const Spacer(),

            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _CallAction(icon: Icons.mic_none_rounded, label: 'mute'.tr, onTap: () {}),
              _CallAction(icon: Icons.volume_up_rounded, label: 'speaker'.tr, onTap: () {}),
              _CallAction(icon: Icons.refresh_rounded, label: 'redial'.tr, onTap: _launchDialer),
            ]),

            const SizedBox(height: 32),

            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: context.kDestructive,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 30),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'end_call'.tr,
              style: robotoMedium.copyWith(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),

            if (!_dialerOpened && _status == 'dialer_failed'.tr) ...[
              const SizedBox(height: 16),
              InkWell(
                onTap: _launchDialer,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'try_again'.tr,
                    style: robotoMedium.copyWith(fontSize: 13, color: Colors.white),
                  ),
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

class _CallAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CallAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: robotoRegular.copyWith(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ]),
    );
  }
}
