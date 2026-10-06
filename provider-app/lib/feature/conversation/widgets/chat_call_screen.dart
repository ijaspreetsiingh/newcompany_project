import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

/// Professional voice-call screen used from chat.
///
/// Shows caller/callee info + call progress while the system dialer
/// (tel:) is launched. Works fully offline of any third-party VoIP SDK.
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

class _ChatCallScreenState extends State<ChatCallScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _statusTimer;
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

    _statusTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _dialerOpened) return;
      setState(() => _status = 'calling'.tr);
    });
  }

  Future<void> _launchDialer() async {
    final String number = widget.phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (number.isEmpty) {
      if (mounted) setState(() => _status = 'no_phone_number'.tr);
      return;
    }
    final Uri uri = Uri(scheme: 'tel', path: number);
    try {
      _dialerOpened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      _dialerOpened = false;
    }
    if (mounted && _dialerOpened) {
      setState(() => _status = 'in_dialer'.tr);
    } else if (mounted) {
      setState(() => _status = 'dialer_failed'.tr);
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkColors.background,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: InkColors.gradient),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(children: [
            const SizedBox(height: 24),

            Text(
              widget.role,
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.54,
                height: 1.2,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.55),
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
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                ),
                alignment: Alignment.center,
                child: widget.image.isNotEmpty
                    ? ClipOval(
                        child: CustomImage(
                          image: widget.image,
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                    : InkAvatar(name: widget.name, size: 100),
              ),
            ),

            const SizedBox(height: 28),

            Text(
              widget.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 24,
                height: 1.2,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.phone.isEmpty ? _status : (widget.phone.startsWith('+') ? widget.phone : '+${widget.phone}'),
              style: TextStyle(
                fontSize: 14,
                height: 1.3,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              _status,
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),

            const Spacer(),

            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _CallAction(
                icon: Icons.mic_none_rounded,
                label: 'mute'.tr,
                onTap: () {},
              ),
              _CallAction(
                icon: Icons.volume_up_rounded,
                label: 'speaker'.tr,
                onTap: () {},
              ),
              _CallAction(
                icon: Icons.refresh_rounded,
                label: 'redial'.tr,
                onTap: _launchDialer,
              ),
            ]),

            const SizedBox(height: 32),

            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: InkColors.destructive,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 30),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'end_call'.tr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
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

  const _CallAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ]),
    );
  }
}
