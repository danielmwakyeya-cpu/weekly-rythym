import 'dart:async';
import 'package:flutter/services.dart';

class AlarmSoundService {
  static Timer? _alarmLoop;
  static bool _isPlaying = false;
  static bool get isPlaying => _isPlaying;

  static void startAlarm() {
    stopAlarm();
    _isPlaying = true;

    // Trigger initial alert
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();

    // Rhythmic looping alert every 1.2 seconds
    _alarmLoop = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_isPlaying) HapticFeedback.heavyImpact();
      });
    });
  }

  static void stopAlarm() {
    _isPlaying = false;
    _alarmLoop?.cancel();
    _alarmLoop = null;
  }
}
