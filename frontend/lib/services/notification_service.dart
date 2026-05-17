import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final _storage = <String, String>{};
  static const _hourKey = 'reminder_hour';
  static const _minuteKey = 'reminder_minute';

  Future<void> init() async {
    // Notifications are not supported on web; skip silently.
    if (kIsWeb) return;

    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      await _plugin.initialize(
        const InitializationSettings(android: androidSettings, iOS: iosSettings),
      );

      final hour = _storage[_hourKey];
      final minute = _storage[_minuteKey];
      if (hour != null && minute != null) {
        await _schedule(int.parse(hour), int.parse(minute));
      }
    } catch (_) {}
  }

  Future<void> scheduleDailyReminder(int hour, int minute) async {
    _storage[_hourKey] = hour.toString();
    _storage[_minuteKey] = minute.toString();
    await _schedule(hour, minute);
  }

  Future<void> _schedule(int hour, int minute) async {
    await _plugin.cancelAll();

    await _plugin.zonedSchedule(
      0,
      '学习提醒',
      '该复习今天的学习内容啦！打开 MindFlow 开始复习吧。',
      _nextInstanceOf(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'review_reminder',
          '每日复习提醒',
          channelDescription: '每天定时提醒复习',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    _storage.remove(_hourKey);
    _storage.remove(_minuteKey);
  }

  Future<int?> getReminderHour() async {
    final v = _storage[_hourKey];
    return v != null ? int.tryParse(v) : null;
  }

  Future<int?> getReminderMinute() async {
    final v = _storage[_minuteKey];
    return v != null ? int.tryParse(v) : null;
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
