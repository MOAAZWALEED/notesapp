import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    // ضبط التايم زون المحلي صراحة بدلاً من الاعتماد الافتراضي فقط
    try {
      final String currentTimeZone = await DateTime.now().timeZoneName;
      // أو استخدام التايم زون الافتراضي المتاح
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    } catch (_) {
      tz.setLocalLocation(tz.local);
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {},
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    // طلب إذن الـ Exact Alarm لأجهزة أندرويد 12+ (Android 12+)
    await androidPlugin?.requestExactAlarmsPermission();
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tz.TZDateTime scheduledTZDate =
    tz.TZDateTime.from(scheduledDate, tz.local);

    final int safeId = id.abs();

    final String cleanBody = body
        .replaceAll(RegExp(r'\[\s*\]|\[[xX]\]'), '')
        .trim();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      safeId,
      title,
      cleanBody, // استبدال الـ body بالنص المنظف
      scheduledTZDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'notes_reminder_channel_id',
          'Notes Reminders',
          channelDescription: 'Channel for notes reminders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id.abs());
  }
}