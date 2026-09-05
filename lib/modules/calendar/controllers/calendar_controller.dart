import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/lunar_calendar.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/calendar_event_model.dart';
import '../../../data/repositories/event_repository.dart';

class CalendarController extends GetxController {
  final EventRepository _repository;
  CalendarController(this._repository);

  final focusedDay = DateTime.now().obs;
  final selectedDay = DateTime.now().obs;
  final events = <CalendarEventModel>[].obs;

  final _uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    events.assignAll(_repository.getAll());
  }

  List<CalendarEventModel> eventsForDay(DateTime day) {
    return events.where((e) => _isSameDay(e.date, day)).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<CalendarEventModel> get eventsForSelectedDay => eventsForDay(selectedDay.value);

  bool hasEvents(DateTime day) => events.any((e) => _isSameDay(e.date, day));

  LunarDate lunarOf(DateTime day) => LunarCalendar.solarToLunar(day.day, day.month, day.year);

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
  }

  Future<void> addOrUpdateEvent({
    String? id,
    required DateTime date,
    required String title,
    String? note,
    bool hasTime = false,
    TimeOfDay? time,
    required int colorValue,
    bool reminderEnabled = false,
    int reminderMinutesBefore = 30,
  }) async {
    final event = CalendarEventModel(
      id: id ?? _uuid.v4(),
      date: DateTime(date.year, date.month, date.day),
      title: title,
      note: note,
      hasTime: hasTime,
      time: time,
      colorValue: colorValue,
      reminderEnabled: reminderEnabled,
      reminderMinutesBefore: reminderMinutesBefore,
    );

    events.removeWhere((e) => e.id == event.id);
    events.add(event);
    await _repository.saveAll(events);

    await NotificationService.instance.cancel(event.notificationId);
    if (event.reminderEnabled) {
      await NotificationService.instance.scheduleEventNotification(
        id: event.notificationId,
        title: 'Sự kiện: ${event.title}',
        body: (event.note != null && event.note!.isNotEmpty)
            ? event.note!
            : 'Đến giờ cho sự kiện của bạn rồi!',
        dateTime: event.notifyAt,
      );
    }
  }

  Future<void> deleteEvent(CalendarEventModel event) async {
    events.removeWhere((e) => e.id == event.id);
    await _repository.saveAll(events);
    await NotificationService.instance.cancel(event.notificationId);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
