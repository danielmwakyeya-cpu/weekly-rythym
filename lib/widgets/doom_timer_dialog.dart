import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../services/alarm_sound_service.dart';
import '../theme/app_theme.dart';

class DoomTimerDialog extends StatefulWidget {
  const DoomTimerDialog({super.key});

  @override
  State<DoomTimerDialog> createState() => _DoomTimerDialogState();
}

class _DoomTimerDialogState extends State<DoomTimerDialog> {
  int _totalSeconds = 30 * 60;
  int _secondsLeft = 30 * 60;
  bool _isRunning = false;
  bool _isRinging = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    _totalSeconds = provider.customTimerDurationSeconds;
    _secondsLeft = _totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    AlarmSoundService.stopAlarm();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isRinging = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _onTimerFinish();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    AlarmSoundService.stopAlarm();
    setState(() {
      _secondsLeft = _totalSeconds;
      _isRunning = false;
      _isRinging = false;
    });
  }

  void _setPreset(int minutes) {
    _timer?.cancel();
    AlarmSoundService.stopAlarm();
    setState(() {
      _totalSeconds = minutes * 60;
      _secondsLeft = _totalSeconds;
      _isRunning = false;
      _isRinging = false;
    });
    Provider.of<ScheduleProvider>(context, listen: false).setCustomTimerDuration(_totalSeconds);
  }

  void _onTimerFinish() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isRinging = true;
    });
    AlarmSoundService.startAlarm();
  }

  void _stopAlarm() {
    AlarmSoundService.stopAlarm();
    setState(() => _isRinging = false);
    _resetTimer();
  }

  void _snoozeAlarm(int minutes) {
    AlarmSoundService.stopAlarm();
    setState(() {
      _totalSeconds = minutes * 60;
      _secondsLeft = _totalSeconds;
      _isRinging = false;
    });
    _startTimer();
  }

  void _showCustomDurationDialog(BuildContext context, AppColors colors) {
    final ctrl = TextEditingController(text: '${_totalSeconds ~/ 60}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.plum,
        title: Text('Custom Duration (Minutes)', style: GoogleFonts.fraunces(color: colors.cream)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: GoogleFonts.workSans(color: colors.cream, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Enter minutes (e.g. 5, 25, 90)',
            hintStyle: GoogleFonts.workSans(color: colors.muted),
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: colors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colors.terracotta),
            onPressed: () {
              final val = int.tryParse(ctrl.text.trim());
              if (val != null && val > 0 && val <= 720) {
                _setPreset(val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Set Timer'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSecs) {
    final m = totalSecs ~/ 60;
    final s = totalSecs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final colors = provider.colors;
    final progress = _totalSeconds == 0 ? 0.0 : (_secondsLeft / _totalSeconds);

    return Dialog(
      backgroundColor: colors.plum,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.gold.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isRinging ? '\u23F0 Alarm Ringing!' : 'Focus & Decompression',
                  style: GoogleFonts.fraunces(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _isRinging ? colors.terracotta : colors.cream,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colors.muted, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _isRinging
                  ? 'Time is up! Step away and take a deep breath.'
                  : 'Guilt-free decompression timer. When it rings, hands up!',
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(fontSize: 12, color: colors.muted),
            ),
            const SizedBox(height: 20),

            // Circular Countdown / Alarm Dial
            SizedBox(
              width: 170,
              height: 170,
              child: CustomPaint(
                painter: _TimerRingPainter(
                  progress: progress,
                  trackColor: colors.plumLight,
                  color: _isRinging ? colors.terracotta : colors.gold,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(_secondsLeft),
                        style: GoogleFonts.fraunces(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: _isRinging ? colors.terracotta : colors.cream,
                        ),
                      ),
                      Text(
                        _isRinging ? 'ALARM RINGING' : (_isRunning ? 'running' : 'paused'),
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _isRinging ? colors.terracotta : colors.muted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Presets + Custom Button
            if (!_isRinging) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  ...[15, 30, 45, 60].map((m) {
                    final selected = _totalSeconds == m * 60;
                    return GestureDetector(
                      onTap: () => _setPreset(m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? colors.terracotta : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: selected ? colors.terracotta : Colors.white.withOpacity(0.12)),
                        ),
                        child: Text(
                          '${m}m',
                          style: GoogleFonts.workSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : colors.goldSoft,
                          ),
                        ),
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: () => _showCustomDurationDialog(context, colors),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.gold.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tune, size: 12, color: colors.goldSoft),
                          const SizedBox(width: 4),
                          Text(
                            'Custom',
                            style: GoogleFonts.workSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: colors.goldSoft),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Controls: Start/Pause & Reset
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _resetTimer,
                      icon: Icon(Icons.refresh, size: 16, color: colors.muted),
                      label: Text('Reset', style: GoogleFonts.workSans(color: colors.muted, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow, size: 16, color: Colors.white),
                      label: Text(_isRunning ? 'Pause' : 'Start', style: GoogleFonts.workSans(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.terracotta,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Alarm Ringing Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _snoozeAlarm(5),
                      icon: Icon(Icons.snooze, size: 16, color: colors.goldSoft),
                      label: Text('Snooze (+5m)', style: GoogleFonts.workSans(color: colors.goldSoft, fontSize: 12.5)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.gold.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _stopAlarm,
                      icon: const Icon(Icons.alarm_off, size: 16, color: Colors.white),
                      label: Text('Stop Alarm', style: GoogleFonts.workSans(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.terracotta,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color color;

  _TimerRingPainter({
    required this.progress,
    required this.trackColor,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 8.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Progress Arc
    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, -pi / 2, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
