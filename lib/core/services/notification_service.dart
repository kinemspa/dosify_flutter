import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../data/models/medication_schedule.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Handle notification tap by navigating to the relevant medication/dose screen
  }

  Future<void> scheduleReminders(MedicationSchedule schedule) async {
    if (!schedule.reminderEnabled || !schedule.isActive) return;

    final nextDoses = schedule.getNextScheduledDoses(
      DateTime.now(),
      10, // Schedule next 10 doses
    );

    for (final doseTime in nextDoses) {
      final notificationTime = doseTime.subtract(
        Duration(minutes: schedule.reminderMinutesBefore),
      );

      if (notificationTime.isBefore(DateTime.now())) continue;

      await _notifications.zonedSchedule(
        _generateNotificationId(schedule.id, doseTime),
        'Time for ${schedule.medicationName}',
        'Take ${schedule.dosageAmount} ${schedule.dosageUnit}',
        tz.TZDateTime.from(notificationTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminders',
            'Medication Reminders',
            channelDescription: 'Notifications for medication reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: _generateNotificationPayload(schedule, doseTime),
      );
    }
  }

  Future<void> cancelScheduleReminders(String scheduleId) async {
    final now = DateTime.now();
    // Cancel notifications for the next 365 days (conservative approach)
    for (var i = 0; i < 365; i++) {
      final date = now.add(Duration(days: i));
      for (var hour = 0; hour < 24; hour++) {
        final time = DateTime(date.year, date.month, date.day, hour);
        final id = _generateNotificationId(scheduleId, time);
        await _notifications.cancel(id);
      }
    }
  }

  int _generateNotificationId(String scheduleId, DateTime dateTime) {
    // Create a unique ID based on schedule ID and datetime
    // Format: YYYYMMDDHH (year, month, day, hour)
    final timeComponent = int.parse(
      '${dateTime.year}${dateTime.month.toString().padLeft(2, '0')}'
      '${dateTime.day.toString().padLeft(2, '0')}'
      '${dateTime.hour.toString().padLeft(2, '0')}',
    );
    
    // Use the last 5 digits of the schedule ID's hashcode
    final scheduleComponent = scheduleId.hashCode.abs() % 100000;
    
    // Combine them ensuring no overflow
    return (timeComponent + scheduleComponent) % 2147483647;
  }

  String _generateNotificationPayload(
    MedicationSchedule schedule,
    DateTime doseTime,
  ) {
    return {
      'scheduleId': schedule.id,
      'medicationId': schedule.medicationId,
      'doseTime': doseTime.toIso8601String(),
    }.toString();
  }

  Future<bool> requestPermissions() async {
    if (await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission() ??
        false) {
      return true;
    }

    if (await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false) {
      return true;
    }

    return false;
  }
}
