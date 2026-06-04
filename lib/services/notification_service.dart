import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings android =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings settings =
    InitializationSettings(
      android: android,
    );

    await _notificationsPlugin.initialize(settings);
  }

  static Future<void> showNotification(
      String title,
      String body,
      ) async {
    const AndroidNotificationDetails details =
    AndroidNotificationDetails(
      'attendance_channel',
      'Attendance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _notificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: details,
      ),
    );
  }
}