import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../controller/call_controller.dart';
import '../model/call_model.dart';

class VoiceCallScreen extends StatefulWidget {
  final String callId;
  final String callType;
  final bool isOutgoing;
  final String userName;
  final String userImage;
  final String userPhone;
  final CallStatusData? initialData;

  const VoiceCallScreen({
    super.key,
    required this.callId,
    required this.callType,
    required this.isOutgoing,
    required this.userName,
    required this.userImage,
    required this.userPhone,
    this.initialData,
  });

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  RtcEngine? _engine;
  Timer? _statusPollTimer;
  Timer? _durationTimer;
  final AudioPlayer _tonePlayer = AudioPlayer();

  bool _joined = false;
  bool _muted = false;
  bool _speakerOn = true;
  bool _cameraFront = true;
  bool _ending = false;
  int _seconds = 0;
  int _remoteUid = 0;
  String _stateText = '';

  bool get _isVideo => widget.callType == 'video';

  @override
  void initState() {
    super.initState();
    _stateText = widget.isOutgoing ? 'ringing'.tr : 'connecting'.tr;
    if (widget.initialData != null && (widget.initialData?.rtcToken ?? '').isNotEmpty) {
      _joinCall(widget.initialData!);
    } else {
      _playRingback();
      _startStatusPolling();
    }
  }

  Future<void> _playRingback() async {
    try {
      await _tonePlayer.setReleaseMode(ReleaseMode.loop);
      await _tonePlayer.play(AssetSource('sounds/incoming_ring.wav'), volume: 0.35);
    } catch (_) {}
  }

  Future<void> _stopTone() async {
    try {
      await _tonePlayer.stop();
    } catch (_) {}
  }

  void _startStatusPolling() {
    _statusPollTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) async {
      final data = await Get.find<CallController>().getStatus(widget.callId);
      if (data == null || !mounted) return;

      if (data.status == 'answered' && (data.rtcToken ?? '').isNotEmpty) {
        timer.cancel();
        _statusPollTimer = null;
        await _stopTone();
        _joinCall(data);
      } else if (['missed', 'rejected', 'cancelled', 'ended'].contains(data.status)) {
        timer.cancel();
        _statusPollTimer = null;
        await _stopTone();
        setState(() => _stateText = Get.find<CallController>().callStatusText(data.status));
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) Get.back();
      }
    });
  }

  Future<void> _joinCall(CallStatusData data) async {
    setState(() => _stateText = 'connecting'.tr);

    if (await Permission.microphone.request().isGranted == false) {
      _failBack('permission_denied'.tr);
      return;
    }
    if (_isVideo && await Permission.camera.request().isGranted == false) {
      _failBack('permission_denied'.tr);
      return;
    }

    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(appId: data.agoraAppId ?? ''));
      await _engine!.enableAudio();
      if (_isVideo) await _engine!.enableVideo();
      await _engine!.setDefaultAudioRouteToSpeakerphone(true);

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, uid) {
            if (!mounted) return;
            setState(() {
              _joined = true;
              _stateText = '';
            });
            _startDurationTimer();
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            if (!mounted) return;
            setState(() => _remoteUid = remoteUid);
          },
          onUserOffline: (connection, remoteUid, reason) {
            _finishCall();
          },
        ),
      );

      if (_isVideo) {
        try {
          await _engine!.startPreview();
        } catch (_) {}
      }

      await _engine!.joinChannel(
        token: data.rtcToken ?? '',
        channelId: data.channelName ?? widget.callId,
        uid: data.rtcUid ?? 0,
        options: ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          autoSubscribeAudio: true,
          autoSubscribeVideo: _isVideo,
        ),
      );
    } catch (_) {
      _failBack('failed'.tr);
    }
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _seconds++);
    });
  }

  void _failBack(String message) {
    _stopTone();
    Get.find<CallController>().endCall(widget.callId);
    if (mounted) {
      Get.back();
      // ignore: use_build_context_synchronously
      Get.rawSnackbar(message: message, duration: const Duration(seconds: 3));
    }
  }

  Future<void> _finishCall() async {
    if (_ending) return;
    _ending = true;
    _statusPollTimer?.cancel();
    _durationTimer?.cancel();
    await _stopTone();
    await Get.find<CallController>().endCall(widget.callId);
    await _disposeEngine();
    if (mounted) Get.back();
  }

  Future<void> _disposeEngine() async {
    try {
      if (_engine != null) {
        await _engine!.leaveChannel();
        await _engine!.release();
        _engine = null;
      }
    } catch (_) {}
  }

  Future<void> _toggleMute() async {
    _muted = !_muted;
    setState(() {});
    try {
      await _engine?.muteLocalAudioStream(_muted);
    } catch (_) {}
  }

  Future<void> _toggleSpeaker() async {
    _speakerOn = !_speakerOn;
    setState(() {});
    try {
      await _engine?.setEnableSpeakerphone(_speakerOn);
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    _cameraFront = !_cameraFront;
    setState(() {});
    try {
      await _engine?.switchCamera();
    } catch (_) {}
  }

  String _durationText() {
    final m = _seconds ~/ 60;
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '${m.toString().padLeft(2, '0')}:$s';
  }

  @override
  void dispose() {
    _statusPollTimer?.cancel();
    _durationTimer?.cancel();
    _tonePlayer.dispose();
    _disposeEngine();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1116),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            _avatar(),
            const SizedBox(height: 16),
            Text(
              widget.userName.isNotEmpty ? widget.userName : 'call'.tr,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _joined ? _durationText() : _stateText,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 15),
            ),
            const SizedBox(height: 24),
            if (_isVideo && _joined) Expanded(child: _videoViews()) else const Spacer(),
            if (!_isVideo || !_joined) ...[
              if (_isVideo)
                Expanded(
                  child: Center(
                    child: Text(_stateText, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16)),
                  ),
                )
              else
                const Spacer(),
            ],
            _actions(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _avatar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
      ),
      child: CircleAvatar(
        radius: 48,
        backgroundColor: Colors.white12,
        backgroundImage: widget.userImage.isNotEmpty ? NetworkImage(widget.userImage) : null,
        child: widget.userImage.isEmpty
            ? const Icon(Icons.person, size: 52, color: Colors.white70)
            : null,
      ),
    );
  }

  Widget _videoViews() {
    return Stack(
      children: [
        if (_remoteUid != 0)
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine!,
                    canvas: VideoCanvas(uid: _remoteUid),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          right: 16,
          top: 16,
          child: Container(
            width: 110,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine!,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _actions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _roundAction(
            icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
            active: !_muted,
            onTap: _toggleMute,
          ),
          _roundAction(
            icon: _speakerOn ? Icons.volume_up_rounded : Icons.volume_down_rounded,
            active: _speakerOn,
            onTap: _toggleSpeaker,
          ),
          if (_isVideo)
            _roundAction(
              icon: Icons.cameraswitch_rounded,
              active: true,
              onTap: _switchCamera,
            ),
          _roundAction(
            icon: Icons.call_end_rounded,
            active: false,
            color: Colors.redAccent,
            onTap: _finishCall,
          ),
        ],
      ),
    );
  }

  Widget _roundAction({required IconData icon, required bool active, required VoidCallback onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color ?? (active ? Colors.white : Colors.white24),
        ),
        child: Icon(icon, color: color != null ? Colors.white : (active ? Colors.black87 : Colors.white), size: 28),
      ),
    );
  }
}
