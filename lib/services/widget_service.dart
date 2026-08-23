import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../models/schedule_model.dart';

class WidgetService {
  static const String appGroupId = 'group.com.keke.weeklyrhythm';
  static const String androidWidgetName = 'TodayWidgetProvider';
  static const String iOSWidgetName = 'TodayWidget';

  static Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);
    } catch (e) {
      debugPrint('HomeWidget init error: $e');
    }
  }

  /// Update widget data with today's schedule summary
  static Future<void> updateTodayWidget({
    required String appTitle,
    required String todayName,
    required int doneCount,
    required int totalCount,
    required List<SlotModel> slots,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('widget_title', appTitle);
      await HomeWidget.saveWidgetData<String>('widget_day', todayName);
      await HomeWidget.saveWidgetData<String>('widget_progress', '$doneCount / $totalCount done');

      // Top 3 upcoming / pending slots
      final pendingSlots = slots.where((s) => !s.done).take(3).map((s) => '${s.time} ${s.label}').toList();
      await HomeWidget.saveWidgetData<String>(
        'widget_tasks',
        pendingSlots.isEmpty ? 'All tasks complete! 🎉' : pendingSlots.join('\n'),
      );

      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: iOSWidgetName,
      );
    } catch (e) {
      debugPrint('Failed to update home widget: $e');
    }
  }
}
