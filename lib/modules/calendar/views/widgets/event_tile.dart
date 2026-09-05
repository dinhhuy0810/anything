import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundColor: event.color, radius: 8),
        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitleParts.isEmpty ? null : Text(subtitleParts.join(' • ')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (event.reminderEnabled)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.notifications_active, size: 18, color: Colors.orange),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
