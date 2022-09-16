import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:productivity_monster/UI/task_app_scrap/notified_page.dart';
import 'package:productivity_monster/models/task.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotifyHelper {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  initializeNotification() async {
    _configureLocalTimezone();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("app_icon_");

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }


  Future selectNotification(String? payload) async {
    if (payload != null) {
      print('notification payload: $payload');
    } else {
      print("Notification Done");
    }
    Get.to(()=> NotifiedPage(label: payload!));
  }

  displayNotification({required String title, required String body}) async {
    print("doing test");
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'your channel id', 'your channel name',
        importance: Importance.max, priority: Priority.high, icon: 'appicon');
    var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'It could be anything you pass',
    );
  }

  scheduledNotification(int hour, int minute, Task task) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        task.id!.toInt(),
        task.title,
        task.note,
        _convertTime(hour, minute),
        //tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails('your channel id',
                'your channel name',
                importance: Importance.max, priority: Priority.high, icon: 'appicon')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
    payload: "${task.title}|${task.note}|");
  }

  tz.TZDateTime _convertTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    // if(scheduleDate.isBefore(now)){
    //   scheduleDate = scheduleDate.add(const Duration(days:1));
    // }
    return scheduleDate;
  }

  Future<void> _configureLocalTimezone() async{
    tz.initializeTimeZones();
    final String timeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone));
  }

  Future<void> cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
