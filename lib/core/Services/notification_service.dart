import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

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

    // طلب إذن الإشعارات لأجهزة أندرويد 13 فما فوق تلقائياً عند التهيئة
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // التأكد من أن وقت التنبيه ليس في الماضي
    if (scheduledDate.isBefore(DateTime.now())) return;

    // تحويل الوقت بشكل دقيق للتايم زون المحلي
    final tz.TZDateTime scheduledTZDate =
    tz.TZDateTime.from(scheduledDate, tz.local);

    // ضمان أن الـ ID دائماً رقم موجب حتى لا يفشل الإشعار
    final int safeId = id.abs();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      safeId,
      title,
      body,
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