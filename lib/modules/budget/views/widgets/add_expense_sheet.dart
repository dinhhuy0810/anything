import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/values/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../data/models/budget_category_model.dart';
import '../../controllers/budget_controller.dart';

class AddExpenseSheet extends StatefulWidget {
  final BudgetCategoryModel? initialCategory;
  const AddExpenseSheet({super.key, this.initialCategory});

  static Future<void> show({BudgetCategoryModel? category}) {
    return Get.bottomSheet(
      backgroundColor: AppColors.surface,
      AddExpenseSheet(initialCategory: category),
      isScrollControlled: true,
    );
  }

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  BudgetCategoryModel? _category;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<BudgetController>();
    _category = widget.initialCategory ??
        (controller.categories.isNotEmpty ? controller.categories.first : null);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BudgetController>();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Obx(() {
          final categories = controller.categories;
          if (categories.isEmpty) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(height: 8),
                Text('Bạn chưa có hạng mục nào.\nHãy thêm hạng mục trước khi ghi chi tiêu.',
                    textAlign: TextAlign.center),
                SizedBox(height: 16),
              ],
            );
          }
          _category ??= categories.first;
          final remaining = controller.remainingFor(_category!);
          final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
          final willExceed = amount > 0 && amount > remaining;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _handle(),
              const SizedBox(height: 12),
              const Text('Ghi khoản chi tiêu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              const Text('Hạng mục', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((c) {
                  final selected = c.id == _category!.id;
                  return ChoiceChip(
                    label: Text(c.name),
                    avatar: Icon(c.icon, size: 16, color: selected ? Colors.white : c.color),
                    selected: selected,
                    selectedColor: c.color,
                    labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary),
                    onSelected: (_) => setState(() => _category = c),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Tên khoản chi (vd: Ăn trưa)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Số tiền', suffixText: 'đ'),
              ),
              if (willExceed) ...[
                const SizedBox(height: 8),
                Text(
                  'Vượt số dư khả dụng của hạng mục (còn ${AppDateUtils.formatCurrency(remaining)}).',
                  style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600, fontSize: 12.5),
                ),
              ],
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ngày', style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                  child: Text(AppDateUtils.formatShort(_date)),
                ),
              ),
              TextField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: 'Ghi chú (không bắt buộc)'),
              ),
              const SizedBox(height: 18),
              GradientButton(
                label: 'Lưu khoản chi',
                onPressed: () async {
                  final amt = double.tryParse(_amountCtrl.text.trim());
                  if (_titleCtrl.text.trim().isEmpty || amt == null || amt <= 0) {
                    Get.snackbar('Thiếu thông tin', 'Vui lòng nhập tên và số tiền hợp lệ');
                    return;
                  }
                  await controller.addExpense(
                    category: _category!,
                    amount: amt,
                    title: _titleCtrl.text.trim(),
                    note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
                    date: _date,
                  );
                  if (context.mounted) Get.back();
                },
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}
