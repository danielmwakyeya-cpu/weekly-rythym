import 'package:flutter/services.dart';

/// Centralized haptic feedback service for premium feel.
class HapticService {
  /// Ultra-light selection click — tab switches, day selector
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Light tap — checkbox toggle, swipe threshold
  static void lightTap() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact — button press, task completion
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact — timer alarm, celebration, delete
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Vibrate pattern — alarm ringing
  static void vibrate() {
    HapticFeedback.vibrate();
  }
}
