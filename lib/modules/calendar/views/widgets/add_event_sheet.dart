import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../data/models/calendar_event_model.dart';
import '../../controllers/calendar_controller.dart';

/// Bottom sheet dùng để thêm mới hoặc chỉnh sửa 1 sự kiện / đánh dấu ngày.
class AddEventSheet extends StatefulWidget {
  final DateTime date;
  final CalendarEventModel? existing;

  const AddEventSheet({super.key, required this.date, this.existing});

  static Future<void> show(DateTime date, {CalendarEventModel? existing}) {
    return Get.bottomSheet(
      backgroundColor: AppColors.surface,
      AddEventSheet(date: date, existing: existing),
      isScrollControlled: true,
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
  Color _color = AppColors.categoryPalette.first;
  bool _reminderEnabled = false;
  int _reminderMinutes = 30;

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
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.existing == null
                  ? 'Thêm sự kiện / đánh dấu ngày'
                  : 'Sửa sự kiện',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration:
                  const InputDecoration(labelText: 'Ghi chú (không bắt buộc)'),
            ),
            const SizedBox(height: 6),
            _softSwitchTile(
              title: 'Đặt giờ cụ thể',
              value: _hasTime,
              onChanged: (v) => setState(() => _hasTime = v),
            ),
            if (_hasTime) ...[
              const SizedBox(height: 6),
              _rowTile(
                title: 'Giờ diễn ra',
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                        context: context, initialTime: _time);
                    if (picked != null) setState(() => _time = picked);
                  },
                  child: Text(_time.format(context)),
                ),
              ),
            ],
            const SizedBox(height: 14),
            const Text('Màu đánh dấu',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppColors.categoryPalette.map((c) {
                final selected = c.value == _color.value;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: AppColors.textPrimary, width: 2)
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
            _softSwitchTile(
              title: 'Nhắc nhở',
              subtitle: 'Gửi thông báo trước khi sự kiện diễn ra',
              value: _reminderEnabled,
              onChanged: (v) => setState(() => _reminderEnabled = v),
            ),
            if (_reminderEnabled) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _reminderMinutes,
                decoration: const InputDecoration(labelText: 'Nhắc trước'),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Đúng giờ')),
                  DropdownMenuItem(value: 15, child: Text('15 phút trước')),
                  DropdownMenuItem(value: 30, child: Text('30 phút trước')),
                  DropdownMenuItem(value: 60, child: Text('1 giờ trước')),
                  DropdownMenuItem(value: 1440, child: Text('1 ngày trước')),
                ],
                onChanged: (v) => setState(() => _reminderMinutes = v ?? 30),
              ),
            ],
            const SizedBox(height: 20),
            GradientButton(
              label: 'Lưu',
              onPressed: () async {
                if (_titleCtrl.text.trim().isEmpty) {
                  Get.snackbar(
                      'Thiếu tiêu đề', 'Vui lòng nhập tiêu đề sự kiện');
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _softSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primary,
          title: Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
          subtitle: subtitle == null
              ? null
              : Text(subtitle, style: const TextStyle(fontSize: 11.5)),
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _rowTile({required String title, required Widget trailing}) {
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
          trailing: trailing,
        ),
      ),
    );
  }
}
