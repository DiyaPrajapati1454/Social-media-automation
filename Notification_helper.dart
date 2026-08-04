import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize Notifications
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings =
    InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print(" Notification Clicked: ${response.payload}");
      },
    );

    // Request permission for Android 13+
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    print(" Notifications Initialized Successfully");
  }

  // Schedule a Notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      print(" Scheduling Notification: $title at $scheduledTime");

      // Ensure scheduled time is in the future
      if (scheduledTime.isBefore(DateTime.now())) {
        print("Error: Scheduled time is in the past!");
        return;
      }
      if(Platform.isAndroid ){
        final granted=await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.canScheduleExactNotifications();
        if(granted==false){
          print("Required exact alarm permission");
          AndroidFlutterLocalNotificationsPlugin().requestExactAlarmsPermission();
          return;
        }
      }
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        // tz.TZDateTime.now(tz.local).add(const Duration(seconds:10)),
        tz.TZDateTime.from(scheduledTime, tz.local), //  Convert to timezone
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'post_channel_id',
            'Post Notifications',
            channelDescription: 'Scheduled post notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
      );
      // await _notificationsPlugin.show(id, title, body,NotificationDetails);

      print(" Notification Scheduled Successfully! date and time is ${scheduledTime}");
    } catch (e, stack) {
      print("Error Scheduling Notification: $e");
      print(stack);
    }
  }
}