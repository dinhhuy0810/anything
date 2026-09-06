import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/utils/date_utils.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/gradient_fab.dart';
import '../controllers/calendar_controller.dart';
import 'widgets/add_event_sheet.dart';
import 'widgets/event_tile.dart';

class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Obx(
            () => AppHeader(
              title: 'Lịch',
              subtitle: 'Sự kiện & lịch âm của bạn',
              trailing: controller.isViewingCurrentMonth
                  ? null
                  : _TodayButton(onTap: controller.goToToday),
            ),
          ),
          Expanded(
            child: Obx(
              () => Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border),
                    ),
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
                        titleTextStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                        leftChevronIcon: Icon(Icons.chevron_left_rounded, color: AppColors.primary),
                        rightChevronIcon: Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekendStyle: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700),
                        weekdayStyle: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) => _dayCell(day),
                        outsideBuilder: (context, day, focusedDay) => _dayCell(day, isOutside: true),
                        todayBuilder: (context, day, focusedDay) => _dayCell(day, isToday: true),
                        selectedBuilder: (context, day, focusedDay) => _dayCell(day, isSelected: true),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            AppDateUtils.formatFull(controller.selectedDay.value),
                            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'ÂL: ${controller.lunarOf(controller.selectedDay.value)}',
                            style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: controller.eventsForSelectedDay.isEmpty
                        ? const EmptyStateWidget(
                            icon: Icons.event_note_rounded,
                            message: 'Chưa có sự kiện nào trong ngày này.\nBấm nút + để thêm mới.',
                          )
                        : ListView(
                            padding: const EdgeInsets.only(bottom: 100),
                            children: controller.eventsForSelectedDay
                                .map(
                                  (e) => EventTile(
                                    event: e,
                                    onTap: () => AddEventSheet.show(controller.selectedDay.value, existing: e),
                                    onDelete: () => controller.deleteEvent(e),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: GradientFab(
        onPressed: () => AddEventSheet.show(controller.selectedDay.value),
        icon: Icons.add_rounded,
      ),
    );
  }

  Widget _dayCell(DateTime day, {bool isToday = false, bool isSelected = false, bool isOutside = false}) {
    final controller = Get.find<CalendarController>();
    final lunar = controller.lunarOf(day);
    final hasEvent = controller.hasEvents(day);
    final isSunday = day.weekday == DateTime.sunday;

    final numberColor = isSelected
        ? Colors.white
        : isOutside
            ? AppColors.textSecondary.withOpacity(0.5)
            : (isSunday ? AppColors.danger : AppColors.textPrimary);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isToday ? AppColors.primary.withOpacity(0.14) : null),
            shape: BoxShape.circle,
          ),
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: numberColor,
              fontWeight: isToday || isSelected ? FontWeight.w800 : FontWeight.w500,
              fontSize: 13.5,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          lunar.day == 1 ? '${lunar.day}/${lunar.month}' : '${lunar.day}',
          style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
        if (hasEvent)
          Container(
            margin: const EdgeInsets.only(top: 1),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(color: AppColors.accentPink, shape: BoxShape.circle),
          )
        else
          const SizedBox(height: 5),
      ],
    );
  }
}

/// Nút "về hôm nay" — chỉ hiện khi đang xem 1 tháng khác tháng hiện tại.
class _TodayButton extends StatelessWidget {
  final VoidCallback onTap;
  const _TodayButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.today_rounded, size: 16, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'Hôm nay',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
