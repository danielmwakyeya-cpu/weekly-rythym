import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/smart_reminder_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    _initialized = true;
  }

  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  /// Schedule notifications for a SmartReminderModel at all active lead times.
  static Future<void> scheduleReminderNotifications(SmartReminderModel reminder) async {
    await cancelReminderNotifications(reminder.id);

    final now = DateTime.now();
    int notifId = reminder.id.hashCode.abs();

    final leadTimes = <String, Duration>{};
    if (reminder.isMonthActive) leadTimes['1 month'] = const Duration(days: 30);
    if (reminder.isFortnightActive) leadTimes['2 weeks'] = const Duration(days: 14);
    if (reminder.isWeekActive) leadTimes['1 week'] = const Duration(days: 7);
    if (reminder.isDayActive) leadTimes['1 day'] = const Duration(days: 1);

    for (final entry in leadTimes.entries) {
      final triggerDate = reminder.eventDate.subtract(entry.value);
      if (triggerDate.isAfter(now)) {
        try {
          final tzDate = tz.TZDateTime.from(triggerDate, tz.local);
          await _plugin.zonedSchedule(
            notifId,
            '📅 ${reminder.title}',
            '${entry.key} until ${reminder.title}!',
            tzDate,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'smart_reminders',
                'Smart Advance Reminders',
                channelDescription: 'Multi-tier advance warnings for events',
                importance: Importance.high,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: null,
            payload: reminder.id,
          );
        } catch (e) {
          debugPrint('Failed to schedule notification: $e');
        }
      }
      notifId++;
    }
  }

  static Future<void> cancelReminderNotifications(String reminderId) async {
    final baseId = reminderId.hashCode.abs();
    for (int i = 0; i < 4; i++) {
      await _plugin.cancel(baseId + i);
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Show an immediate local notification
  static Future<void> showInstant({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant',
          'Instant Notifications',
          channelDescription: 'Immediate alerts',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }
}
