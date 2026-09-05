import 'package:flutter/material.dart';

/// Một sự kiện / ngày được đánh dấu trong lịch.
/// Nếu chỉ muốn "đánh dấu" một ngày, có thể tạo event với hasTime = false
/// và không bật nhắc nhở - ngày đó vẫn hiện chấm màu trên lịch.
class CalendarEventModel {
  final String id;
  final DateTime date;
  final String title;
  final String? note;
  final bool hasTime;
  final TimeOfDay? time;
  final int colorValue;
  final bool reminderEnabled;
  final int reminderMinutesBefore;

  CalendarEventModel({
    required this.id,
    required this.date,
    required this.title,
    this.note,
    this.hasTime = false,
    this.time,
    this.colorValue = 0xFF2196F3,
    this.reminderEnabled = false,
    this.reminderMinutesBefore = 30,
  });

  Color get color => Color(colorValue);

  /// Thời điểm diễn ra sự kiện (mặc định 8:00 sáng nếu không đặt giờ).
  DateTime get dateTime {
    if (hasTime && time != null) {
      return DateTime(date.year, date.month, date.day, time!.hour, time!.minute);
    }
    return DateTime(date.year, date.month, date.day, 8, 0);
  }

  DateTime get notifyAt => dateTime.subtract(Duration(minutes: reminderMinutesBefore));

  /// id thông báo suy ra từ id sự kiện để có thể cancel đúng thông báo.
  int get notificationId => id.hashCode & 0x7FFFFFFF;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'title': title,
        'note': note,
        'hasTime': hasTime,
        'timeHour': time?.hour,
        'timeMinute': time?.minute,
        'colorValue': colorValue,
        'reminderEnabled': reminderEnabled,
        'reminderMinutesBefore': reminderMinutesBefore,
      };

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      note: json['note'] as String?,
      hasTime: json['hasTime'] as bool? ?? false,
      time: json['timeHour'] != null
          ? TimeOfDay(hour: json['timeHour'] as int, minute: json['timeMinute'] as int)
          : null,
      colorValue: json['colorValue'] as int? ?? 0xFF2196F3,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderMinutesBefore: json['reminderMinutesBefore'] as int? ?? 30,
    );
  }
}
