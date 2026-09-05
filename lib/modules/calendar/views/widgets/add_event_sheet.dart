import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/calendar_event_model.dart';
import '../../controllers/calendar_controller.dart';

/// Bottom sheet dùng để thêm mới hoặc chỉnh sửa 1 sự kiện / đánh dấu ngày.
class AddEventSheet extends StatefulWidget {
  final DateTime date;
  final CalendarEventModel? existing;

  const AddEventSheet({super.key, required this.date, this.existing});

  static Future<void> show(DateTime date, {CalendarEventModel? existing}) {
    return Get.bottomSheet(
      AddEventSheet(date: date, existing: existing),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  @override
  State<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<AddEventSheet> {
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _hasTime = false;
  TimeOfDay _time = TimeOfDay.now();
  Color _color = Colors.blue;
  bool _reminderEnabled = false;
  int _reminderMinutes = 30;

  final _colors = const [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleCtrl.text = e.title;
      _noteCtrl.text = e.note ?? '';
      _hasTime = e.hasTime;
      _time = e.time ?? TimeOfDay.now();
      _color = e.color;
      _reminderEnabled = e.reminderEnabled;
      _reminderMinutes = e.reminderMinutesBefore;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CalendarController>();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.existing == null ? 'Thêm sự kiện / đánh dấu ngày' : 'Sửa sự kiện',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Tiêu đề', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (không bắt buộc)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Đặt giờ cụ thể'),
              value: _hasTime,
              onChanged: (v) => setState(() => _hasTime = v),
            ),
            if (_hasTime)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Giờ diễn ra'),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(context: context, initialTime: _time);
                    if (picked != null) setState(() => _time = picked);
                  },
                  child: Text(_time.format(context)),
                ),
              ),
            const SizedBox(height: 8),
            const Text('Màu đánh dấu', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: _colors.map((c) {
                final selected = c.value == _color.value;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selected ? Border.all(width: 3, color: Colors.black26) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Nhắc nhở'),
              subtitle: const Text('Gửi thông báo trước khi sự kiện diễn ra'),
              value: _reminderEnabled,
              onChanged: (v) => setState(() => _reminderEnabled = v),
            ),
            if (_reminderEnabled)
              DropdownButtonFormField<int>(
                value: _reminderMinutes,
                decoration: const InputDecoration(labelText: 'Nhắc trước', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Đúng giờ')),
                  DropdownMenuItem(value: 15, child: Text('15 phút trước')),
                  DropdownMenuItem(value: 30, child: Text('30 phút trước')),
                  DropdownMenuItem(value: 60, child: Text('1 giờ trước')),
                  DropdownMenuItem(value: 1440, child: Text('1 ngày trước')),
                ],
                onChanged: (v) => setState(() => _reminderMinutes = v ?? 30),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_titleCtrl.text.trim().isEmpty) {
                    Get.snackbar('Thiếu tiêu đề', 'Vui lòng nhập tiêu đề sự kiện');
                    return;
                  }
                  await controller.addOrUpdateEvent(
                    id: widget.existing?.id,
                    date: widget.date,
                    title: _titleCtrl.text.trim(),
                    note: _noteCtrl.text.trim(),
                    hasTime: _hasTime,
                    time: _hasTime ? _time : null,
                    colorValue: _color.value,
                    reminderEnabled: _reminderEnabled,
                    reminderMinutesBefore: _reminderMinutes,
                  );
                  if (context.mounted) Get.back();
                },
                child: const Text('Lưu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
