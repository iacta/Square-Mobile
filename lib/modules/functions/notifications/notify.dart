import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:square/modules/views/routes/main_page/home.dart';
import 'package:square/modules/views/routes/routes.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
     tz.initializeTimeZones();
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('icon');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {
      final context = Routes.navigatorKey?.currentContext;
      if (context != null) {
        indiceAtual = 2;
        Navigator.of(context).pushNamed('/home');
      }
    });
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.max,
            priority: Priority.high,
            colorized: true,
            color: Color.fromARGB(255, 0, 38, 255)),
        iOS: DarwinNotificationDetails());
  }

  Future showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    return notificationsPlugin.show(
        id, title, body, await notificationDetails());
  }

  Future<void> scheduleDailyNotification() async {
    const dailyNotificationId = 0;
    const dailyNotificationTitle = 'Subtrair um dia do plano';
    const dailyNotificationBody = 'Clique para subtrair um dia do plano.';

    // Configuração da notificação diária
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'daily_notification_channel_id',
      'Daily Notification Channel',
      importance: Importance.max,
      priority: Priority.high,
      colorized: true,
      color: Color.fromARGB(255, 0, 38, 255),
    );
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    // Agenda a notificação diariamente às 00:00
    await notificationsPlugin.zonedSchedule(
      dailyNotificationId,
      dailyNotificationTitle,
      dailyNotificationBody,
      _nextInstanceOfMidnight(),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfMidnight() {
    final now = tz.TZDateTime.now(tz.local);
    final tomorrow = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + 1,
      0,
      0,
    );
    return tomorrow;
  }
}
