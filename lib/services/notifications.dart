import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  NotificationsService._();
  static final instance = NotificationsService._();
  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await plugin.initialize(const InitializationSettings(android: android, iOS: ios));
    await plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    await plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleReminder({required String eventId, required String title, required DateTime reminderAt}) async {
    if (!reminderAt.isAfter(DateTime.now())) return;
    final details = NotificationDetails(
      android: AndroidNotificationDetails('event_reminders', 'Event reminders', channelDescription: 'Ceylona event reminders', importance: Importance.high, priority: Priority.high),
      iOS: const DarwinNotificationDetails(),
    );
    await plugin.zonedSchedule(
      _notificationId(eventId),
      'Event reminder',
      title,
      tz.TZDateTime.from(reminderAt, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(String eventId) =>
      plugin.cancel(_notificationId(eventId));

  int _notificationId(String eventId) => eventId.codeUnits.fold(0, (value, code) => (value * 31 + code) & 0x7fffffff);
}