import 'package:jassdbx_provider/util/core_export.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceAssignmentCountdownDialog extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  final int countdownSeconds;

  const ServiceAssignmentCountdownDialog({
    Key? key,
    required this.bookingData,
    this.countdownSeconds = 60,
  }) : super(key: key);

  @override
  State<ServiceAssignmentCountdownDialog> createState() =>
      _ServiceAssignmentCountdownDialogState();
}

class _ServiceAssignmentCountdownDialogState
    extends State<ServiceAssignmentCountdownDialog> {
  late int _timeLeft;
  late Future<void> _timerFuture;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.countdownSeconds;
    _timerFuture = _startCountdown();
  }

  Future<void> _startCountdown() async {
    for (int i = widget.countdownSeconds; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _timeLeft = i - 1);
      }
      if (_timeLeft <= 0) break;
    }
    if (mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    // Extract data from notification
    String title = widget.bookingData['title'] ?? 'New Assignment';
    String body = widget.bookingData['body'] ?? 'You have been assigned a new service';
    String bookingId = widget.bookingData['booking_id'] ?? '';

    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Body Text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        body,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (bookingId.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'ID: $bookingId',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // COUNTDOWN TIMER (BIG & BOLD)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _timeLeft > 15
                            ? Colors.green
                            : _timeLeft > 5
                                ? Colors.orange
                                : Colors.red,
                        _timeLeft > 15
                            ? Colors.green.withValues(alpha: 0.6)
                            : _timeLeft > 5
                                ? Colors.orange.withValues(alpha: 0.6)
                                : Colors.red.withValues(alpha: 0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _timeLeft > 15
                            ? Colors.green.withValues(alpha: 0.5)
                            : _timeLeft > 5
                                ? Colors.orange.withValues(alpha: 0.5)
                                : Colors.red.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Accept in',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_timeLeft',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'seconds',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.8),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                          // Decline logic here
                        },
                        child: const Text(
                          'Decline',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                          // Accept logic here
                        },
                        child: const Text(
                          'Accept',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
