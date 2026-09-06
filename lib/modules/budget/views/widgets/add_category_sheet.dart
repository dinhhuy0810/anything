import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/app_colors.dart';
import '../../../../core/values/budget_icons.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../data/models/budget_category_model.dart';
import '../../controllers/budget_controller.dart';

class AddCategorySheet extends StatefulWidget {
  final BudgetCategoryModel? editing;
  const AddCategorySheet({super.key, this.editing});

  static Future<void> show({BudgetCategoryModel? editing}) {
    return Get.bottomSheet(
      backgroundColor: AppColors.surface,
      AddCategorySheet(editing: editing),
      isScrollControlled: true,
    );
  }

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  late final _nameCtrl = TextEditingController(text: widget.editing?.name ?? '');
  late String _iconKey = widget.editing?.iconKey ?? BudgetIcons.keys.first;
  late Color _color = widget.editing?.color ?? AppColors.categoryPalette.first;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BudgetController>();
    final isEditing = widget.editing != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 12),
            Text(isEditing ? 'Sửa hạng mục' : 'Thêm hạng mục mới',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: _color.withOpacity(0.16), shape: BoxShape.circle),
                  child: Icon(BudgetIcons.get(_iconKey), color: _color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Tên hạng mục'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Chọn biểu tượng', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BudgetIcons.keys.map((key) {
                final selected = key == _iconKey;
                return GestureDetector(
                  onTap: () => setState(() => _iconKey = key),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: selected ? _color : AppColors.surfaceMuted,
                      shape: BoxShape.circle,
                      border: selected ? Border.all(color: _color, width: 2) : null,
                    ),
                    child: Icon(BudgetIcons.get(key), size: 19, color: selected ? Colors.white : AppColors.textSecondary),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Chọn màu', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppColors.categoryPalette.map((c) {
                final selected = c.value == _color.value;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selected ? Border.all(color: AppColors.textPrimary, width: 2) : null,
                    ),
                    child: selected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: isEditing ? 'Lưu thay đổi' : 'Thêm hạng mục',
              onPressed: () async {
                final name = _nameCtrl.text.trim();
                if (name.isEmpty) {
                  Get.snackbar('Thiếu thông tin', 'Vui lòng nhập tên hạng mục');
                  return;
                }
                if (isEditing) {
                  await controller.updateCategory(widget.editing!, name: name, iconKey: _iconKey, color: _color);
                } else {
                  await controller.addCategory(name: name, iconKey: _iconKey, color: _color);
                }
                if (context.mounted) Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
