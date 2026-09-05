import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/expense_categories.dart';
import '../../controllers/expense_controller.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  static Future<void> show() {
    return Get.bottomSheet(
      const AddExpenseSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  TransactionType _type = TransactionType.expense;
  late String _category = ExpenseCategories.byType(_type).first.name;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpenseController>();
    final categories = ExpenseCategories.byType(_type);

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
            const Text('Thêm giao dịch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Chi tiêu'),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Thu nhập'),
                  icon: Icon(Icons.arrow_upward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() {
                _type = s.first;
                _category = ExpenseCategories.byType(_type).first.name;
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Tên giao dịch', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số tiền',
                border: OutlineInputBorder(),
                suffixText: 'đ',
              ),
            ),
            const SizedBox(height: 12),
            const Text('Danh mục', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((c) {
                final selected = c.name == _category;
                return ChoiceChip(
                  label: Text(c.name),
                  avatar: Icon(c.icon, size: 16, color: selected ? Colors.white : c.color),
                  selected: selected,
                  selectedColor: c.color,
                  labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
                  onSelected: (_) => setState(() => _category = c.name),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ngày'),
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
                child: Text('${_date.day}/${_date.month}/${_date.year}'),
              ),
            ),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (không bắt buộc)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(_amountCtrl.text.trim());
                  if (_titleCtrl.text.trim().isEmpty || amount == null || amount <= 0) {
                    Get.snackbar('Thiếu thông tin', 'Vui lòng nhập tên và số tiền hợp lệ');
                    return;
                  }
                  await controller.addExpense(
                    title: _titleCtrl.text.trim(),
                    amount: amount,
                    type: _type,
                    category: _category,
                    date: _date,
                    note: _noteCtrl.text.trim(),
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
