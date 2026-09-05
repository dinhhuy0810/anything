import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../controllers/calendar_controller.dart';
import 'widgets/add_event_sheet.dart';
import 'widgets/event_tile.dart';

class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch'),
      ),
      body: Obx(
        () => Column(
          children: [
            Card(
              margin: const EdgeInsets.all(8),
              child: TableCalendar<void>(
                locale: 'vi_VN',
                firstDay: DateTime(2000, 1, 1),
                lastDay: DateTime(2100, 12, 31),
                focusedDay: controller.focusedDay.value,
                selectedDayPredicate: (day) =>
                    AppDateUtils.isSameDay(day, controller.selectedDay.value),
                onDaySelected: controller.onDaySelected,
                onPageChanged: (day) => controller.focusedDay.value = day,
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {CalendarFormat.month: 'Tháng'},
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekendStyle: TextStyle(color: Colors.red.shade300),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) => _dayCell(day),
                  outsideBuilder: (context, day, focusedDay) =>
                      _dayCell(day, isOutside: true),
                  todayBuilder: (context, day, focusedDay) =>
                      _dayCell(day, isToday: true),
                  selectedBuilder: (context, day, focusedDay) =>
                      _dayCell(day, isSelected: true),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppDateUtils.formatFull(controller.selectedDay.value),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    'ÂL: ${controller.lunarOf(controller.selectedDay.value)}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: controller.eventsForSelectedDay.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.event_note,
                      message:
                          'Chưa có sự kiện nào trong ngày này.\nBấm nút + để thêm mới.',
                    )
                  : ListView(
                      children: controller.eventsForSelectedDay
                          .map(
                            (e) => EventTile(
                              event: e,
                              onTap: () => AddEventSheet.show(
                                  controller.selectedDay.value,
                                  existing: e),
                              onDelete: () => controller.deleteEvent(e),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddEventSheet.show(controller.selectedDay.value),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _dayCell(DateTime day,
      {bool isToday = false, bool isSelected = false, bool isOutside = false}) {
    final controller = Get.find<CalendarController>();
    final lunar = controller.lunarOf(day);
    final hasEvent = controller.hasEvents(day);
    final isSunday = day.weekday == DateTime.sunday;

    final textColor = isSelected
        ? Colors.white
        : isOutside
            ? Colors.grey.shade400
            : (isSunday ? Colors.red.shade400 : Colors.black87);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.blue
            : (isToday ? Colors.blue.withOpacity(0.15) : null),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              color: textColor,
              fontWeight:
                  isToday || isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            lunar.day == 1 ? '${lunar.day}/${lunar.month}' : '${lunar.day}',
            style: TextStyle(
              fontSize: 9,
              color: isSelected ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          if (hasEvent && !isSelected)
            Container(
              margin: const EdgeInsets.only(top: 1),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                  color: Colors.redAccent, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
