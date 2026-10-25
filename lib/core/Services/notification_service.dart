import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    try {
      final String currentTimeZone = await DateTime.now().timeZoneName;
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

    // **طلب إذن الـ Exact Alarm لأجهزة أندرويد 12+ (Android 12+)**
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
      cleanBody,
      scheduledTZDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'notes_custom_sound_channel',
          'Notes Reminders Custom Sound',
          channelDescription: 'Channel for notes reminders with custom alert sound',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('custom_sound'),
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