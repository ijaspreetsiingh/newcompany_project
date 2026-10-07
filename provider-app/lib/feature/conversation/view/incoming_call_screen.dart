import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/call_controller.dart';
import '../model/call_model.dart';
import 'voice_call_screen.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callId;
  final String callType;
  final String userName;
  final String userImage;
  final String? bookingId;
  final bool verify;

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.callType,
    required this.userName,
    required this.userImage,
    this.bookingId,
    this.verify = false,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  final AudioPlayer _ringPlayer = AudioPlayer();
  Timer? _timeoutTimer;
  bool _accepting = false;
  bool _verified = false;
  String _statusText = '';

  @override
  void initState() {
    super.initState();
    if (widget.verify) {
      _verifyThenRing();
    } else {
      _startRinging();
    }
    _timeoutTimer = Timer(const Duration(seconds: 45), () {
      if (!mounted || _accepting) return;
      _stopRing();
      Get.back();
    });
  }

  Future<void> _verifyThenRing() async {
    final data = await Get.find<CallController>().getStatus(widget.callId);
    if (!mounted) return;
    if (data != null && data.status == 'ringing') {
      _startRinging();
    } else {
      setState(() => _statusText = Get.find<CallController>().callStatusText(data?.status));
      _timeoutTimer?.cancel();
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) Get.back();
    }
  }

  void _startRinging() {
    _verified = true;
    try {
      _ringPlayer.setReleaseMode(ReleaseMode.loop);
      _ringPlayer.play(AssetSource('sounds/incoming_ring.wav'));
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<void> _stopRing() async {
    try {
      await _ringPlayer.stop();
    } catch (_) {}
  }

  Future<void> _accept() async {
    if (_accepting) return;
    setState(() => _accepting = true);
    await _stopRing();

    final CallStatusData? data = await Get.find<CallController>().acceptCall(widget.callId);
    if (data == null) {
      if (mounted) Get.back();
      return;
    }

    if (!mounted) return;
    Get.off(() => VoiceCallScreen(
          callId: widget.callId,
          callType: widget.callType,
          isOutgoing: false,
          userName: widget.userName,
          userImage: widget.userImage,
          userPhone: '',
          initialData: data,
        ));
  }

  Future<void> _reject() async {
    await _stopRing();
    await Get.find<CallController>().rejectCall(widget.callId);
    if (mounted) Get.back();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _ringPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1116),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: CircleAvatar(
                radius: 56,
                backgroundColor: Colors.white12,
                backgroundImage: widget.userImage.isNotEmpty ? NetworkImage(widget.userImage) : null,
                child: widget.userImage.isEmpty
                    ? const Icon(Icons.person, size: 60, color: Colors.white70)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.userName.isNotEmpty ? widget.userName : 'call'.tr,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _statusText.isNotEmpty
                  ? _statusText
                  : _accepting
                      ? 'connecting'.tr
                      : widget.callType == 'video'
                          ? 'incoming_video_call'.tr
                          : 'incoming_call'.tr,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16),
            ),
            const Spacer(),
            if (_accepting)
              const Padding(
                padding: EdgeInsets.only(bottom: 48),
                child: CircularProgressIndicator(color: Colors.white),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleButton(
                      icon: Icons.call_end_rounded,
                      color: Colors.redAccent,
                      onTap: _reject,
                    ),
                    _circleButton(
                      icon: Icons.call_rounded,
                      color: Colors.green,
                      onTap: _verified ? _accept : null,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 56),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({required IconData icon, required Color color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: Icon(icon, color: Colors.white, size: 34),
      ),
    );
  }
}
