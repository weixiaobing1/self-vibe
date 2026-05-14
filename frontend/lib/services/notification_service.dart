import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _hourKey = 'reminder_hour';
  static const _minuteKey = 'reminder_minute';

  Future<void> init() async {
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

    // Reschedule if previously configured
    final hour = await _storage.read(key: _hourKey);
    final minute = await _storage.read(key: _minuteKey);
    if (hour != null && minute != null) {
      await _schedule(int.parse(hour), int.parse(minute));
    }
  }

  Future<void> scheduleDailyReminder(int hour, int minute) async {
    await _storage.write(key: _hourKey, value: hour.toString());
    await _storage.write(key: _minuteKey, value: minute.toString());
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
    await _storage.delete(key: _hourKey);
    await _storage.delete(key: _minuteKey);
  }

  Future<int?> getReminderHour() async {
    final v = await _storage.read(key: _hourKey);
    return v != null ? int.tryParse(v) : null;
  }

  Future<int?> getReminderMinute() async {
    final v = await _storage.read(key: _minuteKey);
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
