import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Notification IDs
  static const int idMainReminder = 0;
  static const int idEarlyReminder = 1;
  static const int idLateReminder = 2;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
    debugPrint('[NotificationService] Initialized');
  }

  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('[NotificationService] Tapped: ${response.payload}');
  }

  static Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      await ios.requestPermissions(alert: true, badge: true, sound: true);
    }
    return true;
  }

  /// Schedule all reminders for medication:
  ///   [idEarlyReminder] — 15 minutes before
  ///   [idMainReminder]  — at the scheduled time
  ///   [idLateReminder]  — 2 hours after
  static Future<void> scheduleAllReminders({
    required int hour,
    required int minute,
  }) async {
    await requestPermissions();
    final location = tz.local;
    final now = DateTime.now();

    // ── 1. Main reminder (at scheduled time) ──
    await _scheduleDaily(
      id: idMainReminder,
      hour: hour,
      minute: minute,
      title: 'TBC Tracker',
      body: 'Waktunya minum obat! Jangan lupa ya.',
      location: location,
      now: now,
    );

    // ── 2. Early reminder (15 minutes before) ──
    final earlyDt = _addMinutes(hour, minute, -15);
    await _scheduleDaily(
      id: idEarlyReminder,
      hour: earlyDt.hour,
      minute: earlyDt.minute,
      title: 'TBC Tracker',
      body: '15 menit lagi waktunya minum obat. Siapkan obatmu!',
      location: location,
      now: now,
    );

    // ── 3. Late follow-up (2 hours after) ──
    final lateDt = _addMinutes(hour, minute, 120);
    await _scheduleDaily(
      id: idLateReminder,
      hour: lateDt.hour,
      minute: lateDt.minute,
      title: 'TBC Tracker',
      body: 'Sudah minum obat hari ini? Jangan sampai terlewat!',
      location: location,
      now: now,
    );

    debugPrint(
      '[NotificationService] Scheduled 3 reminders at $hour:$minute',
    );
  }

  /// Cancel all medication reminders.
  static Future<void> cancelAllReminders() async {
    await Future.wait([
      _plugin.cancel(idMainReminder),
      _plugin.cancel(idEarlyReminder),
      _plugin.cancel(idLateReminder),
    ]);
    debugPrint('[NotificationService] All reminders cancelled');
  }

  /// Schedule a single daily repeating notification.
  static Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required tz.Location location,
    required DateTime now,
  }) async {
    var scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'medication_reminder',
      'Pengingat Obat',
      channelDescription: 'Pengingat untuk minum obat TBC',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      fullScreenIntent: true,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'medication_reminder',
    );
  }

  /// Add minutes to (hour, minute), wrapping around 24h.
  static ({int hour, int minute}) _addMinutes(
      int hour, int minute, int offsetMinutes) {
    final totalMinutes = (hour * 60 + minute + offsetMinutes) % (24 * 60);
    if (totalMinutes < 0) {
      return (hour: 0, minute: 0);
    }
    return (hour: totalMinutes ~/ 60, minute: totalMinutes % 60);
  }

  /// Show an immediate test notification.
  static Future<void> showNow({
    String title = 'TBC Tracker',
    String body = 'Waktunya minum obat!',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'medication_reminder',
      'Pengingat Obat',
      channelDescription: 'Pengingat untuk minum obat TBC',
      importance: Importance.high,
      priority: Priority.high,
      fullScreenIntent: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(0, title, body, details);
  }

  /// Convert "HH:MM AM/PM" string to (hour, minute) in 24-hour format.
  static ({int hour, int minute}) parseReminderTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return (hour: 8, minute: 0);

    try {
      final parts = timeStr.split(' ');
      if (parts.length != 2) return (hour: 8, minute: 0);

      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return (hour: 8, minute: 0);

      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      final period = parts[1].toUpperCase();

      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      return (hour: hour, minute: minute);
    } catch (e) {
      return (hour: 8, minute: 0);
    }
  }
}
