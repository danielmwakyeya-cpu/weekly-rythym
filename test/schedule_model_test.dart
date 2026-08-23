import 'package:flutter_test/flutter_test.dart';
import 'package:keke_days_app/models/schedule_model.dart';
import 'package:keke_days_app/services/default_schedule.dart';
import 'package:keke_days_app/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  group('Schedule & Time Model Tests', () {
    test('Default schedule contains 7 days and all expected tasks', () {
      final defaults = DefaultSchedule.getDefaults();
      expect(defaults.length, 7);
      expect(defaults.containsKey('Monday'), isTrue);
      expect(defaults.containsKey('Wednesday'), isTrue);
      expect(defaults['Wednesday']!.slots.any((s) => s.kind == SlotKind.night), isTrue);
    });

    test('ParsedTime correctly parses time ranges and meridiem borrowing', () {
      final t1 = ParsedTime.parse('8:15 - 8:45 AM');
      expect(t1, isNotNull);
      expect(t1!.startMin, 8 * 60 + 15);
      expect(t1.endMin, 8 * 60 + 45);
      expect(t1.crossesMidnight, isFalse);

      final t2 = ParsedTime.parse('9:00 PM - 5:00 AM');
      expect(t2, isNotNull);
      expect(t2!.startMin, 21 * 60);
      expect(t2.endMin, 5 * 60);
      expect(t2.crossesMidnight, isTrue);
    });

    test('Theme generation works across presets and custom HSL accent colors', () {
      final blush = AppThemes.getTheme('blush');
      expect(blush.name, 'Blush');
      expect(blush.colors.ink, const Color(0xFF2B1620));

      final custom = AppThemes.getTheme('custom', customAccent: const Color(0xFF8FBE6E));
      expect(custom.name, 'Custom');
      expect(custom.colors.gold, const Color(0xFF8FBE6E));
    });
  });
}
