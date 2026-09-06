import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Bọc flutter_local_notifications để lên lịch nhắc nhở cho sự kiện.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    } catch (_) {
      // Nếu không tìm thấy timezone, dùng mặc định của thiết bị.
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(settings: initSettings);

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();

    _initialized = true;
  }

  Future<void> scheduleEventNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    if (dateTime.isBefore(DateTime.now())) {
      debugPrint('⚠️ Bỏ qua lên lịch vì thời gian đã ở quá khứ: $dateTime');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'event_channel',
      'Nhắc lịch sự kiện',
      channelDescription: 'Thông báo nhắc nhở sự kiện trong lịch',
      importance: Importance.max,
      // priority: Priority.max,
      // playSound: true,
      // sound: RawResourceAndroidNotificationSound('noti'),
    );
    const details = NotificationDetails(
        android: androidDetails, iOS: DarwinNotificationDetails());

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(dateTime, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint(
          '✅ Đã lên lịch thông báo id=$id lúc: ${tz.TZDateTime.from(dateTime, tz.local)}');
    } catch (e, st) {
      debugPrint('❌ Lỗi khi lên lịch thông báo: $e');
      debugPrint('$st');
    }
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);
}
