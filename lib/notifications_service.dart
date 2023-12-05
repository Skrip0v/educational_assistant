// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

//Это класс, который отвечает за уведомления.
class NotificationsService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  //Инициализация плагина для уведомлений, он вызывает в main()
  static Future<void> init() async {
    var initializationSettingsAndroid = const AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _plugin.initialize(initializationSettings);
  }

  //Это функция отвечает за заплонирования уведомления. Сюда передается информация о задаче,
  //а также дата, когда нужно показать это уведомление
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

  //Эта функция запрашивает разрешения по показ уведомлений. Вызывается в main()
  //Она показывает окно настроек, в котором пользователь должен подтвердить разренешие
  static Future<void> requestNotificationPermission() async {
    var platform = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (platform != null) {
      await platform.requestExactAlarmsPermission();
      await platform.requestNotificationsPermission();
    }
  }

  //Эта функция отвечает за отмену запланированного уведомления (например когда задачу удалили, 
  //то уведомление показывать уже не нужно)
  static Future cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}
