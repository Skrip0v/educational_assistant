import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    var initializationSettingsAndroid = const AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _plugin.initialize(initializationSettings);
  }

  static Future showNotification(
    int id,
    String title,
    String body,
    DateTime? date,
  ) async {
    await requestNotificationPermission();
    var androidNotificationDetails = const AndroidNotificationDetails(
      'ToDark',
      'DARK NIGHT',
      priority: Priority.high,
      importance: Importance.max,
    );
    var notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    var scheduledTime = tz.TZDateTime.from(date!, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'notlification-payload',
    );
  }

  static Future<void> requestNotificationPermission() async {
    var platform = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (platform != null) {
      await platform.requestExactAlarmsPermission();
      await platform.requestNotificationsPermission();
    }
  }

  static Future cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}
