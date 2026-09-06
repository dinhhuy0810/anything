import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/values/app_colors.dart';
import '../../../../data/models/calendar_event_model.dart';

class EventTile extends StatelessWidget {
  final CalendarEventModel event;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const EventTile({
    super.key,
    required this.event,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      if (event.hasTime) AppDateUtils.formatTime(event.dateTime),
      if (event.note != null && event.note!.isNotEmpty) event.note!,
    ];

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(color: event.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  if (subtitleParts.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitleParts.join(' • '),
                      style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 11.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (event.reminderEnabled)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.notifications_active_rounded, size: 18, color: AppColors.warning),
              ),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onDelete,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
