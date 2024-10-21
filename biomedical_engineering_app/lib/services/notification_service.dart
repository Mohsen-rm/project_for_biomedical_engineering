// // lib/services/notification_service.dart
//
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/material.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:flutter_native_timezone/flutter_native_timezone.dart';
//
// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//
//   factory NotificationService() => _instance;
//
//   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//
//   NotificationService._internal() {
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   }
//
//   Future<void> init() async {
//     // إعدادات Android
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     // إعدادات iOS
//
//     // إعدادات التهيئة الكاملة
//     const InitializationSettings initializationSettings =
//     InitializationSettings(
//       android: initializationSettingsAndroid,
//     );
//
//     // تهيئة الإضافات
//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       // onSelectNotification: (String? payload) async {
//       //   // يمكنك إضافة وظائف إضافية عند الضغط على الإشعار
//       // },
//     );
//
//     // إعداد المنطقة الزمنية
//     await _configureLocalTimeZone();
//   }
//
//   Future<void> _configureLocalTimeZone() async {
//     tz.initializeTimeZones();
//     String timeZoneName = 'UTC';
//     try {
//       timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
//     } catch (e) {
//       print('خطأ في الحصول على المنطقة الزمنية: $e');
//     }
//     tz.setLocalLocation(tz.getLocation(timeZoneName));
//   }
//
//   Future<void> scheduleAlarm({
//     required int id,
//     required String title,
//     required String body,
//     required TimeOfDay time,
//     required bool isDaily,
//   }) async {
//     final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
//     tz.TZDateTime scheduledDate = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       time.hour,
//       time.minute,
//     );
//
//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(Duration(days: 1));
//     }
//
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       isDaily
//           ? _nextInstanceOfTime(time)
//           : scheduledDate,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'alarm_channel_id',
//           'Alarm Notifications',
//           channelDescription: 'Channel for alarm notifications',
//           importance: Importance.max,
//           priority: Priority.high,
//           sound: RawResourceAndroidNotificationSound('alarm_sound'),
//           playSound: true,
//         ),
//       ),
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//       UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents:
//       isDaily ? DateTimeComponents.time : null,
//     );
//   }
//
//   tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
//     final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
//     tz.TZDateTime scheduledDate = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       time.hour,
//       time.minute,
//     );
//
//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(Duration(days: 1));
//     }
//
//     return scheduledDate;
//   }
//
//   Future<void> cancelAlarm(int id) async {
//     await flutterLocalNotificationsPlugin.cancel(id);
//   }
//
//   Future<void> cancelAllAlarms() async {
//     await flutterLocalNotificationsPlugin.cancelAll();
//   }
// }
