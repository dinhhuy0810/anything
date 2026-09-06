import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/values/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/pill_tab_bar.dart';
import '../../controllers/budget_controller.dart';

enum _Mode { addFunds, setExact }

class EditTotalSheet extends StatefulWidget {
  final bool startWithAddFunds;
  const EditTotalSheet({super.key, this.startWithAddFunds = true});

  static Future<void> show({bool addFunds = true}) {
    return Get.bottomSheet(
      backgroundColor: AppColors.surface,
      EditTotalSheet(startWithAddFunds: addFunds),
      isScrollControlled: true,
    );
  }

  @override
  State<EditTotalSheet> createState() => _EditTotalSheetState();
}

class _EditTotalSheetState extends State<EditTotalSheet> {
  late _Mode _mode = widget.startWithAddFunds ? _Mode.addFunds : _Mode.setExact;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
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
      child: Obx(
        () => Column(
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
            const Text('Quản lý tổng quỹ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              'Hiện tại: ${AppDateUtils.formatCurrency(controller.totalAmount.value)}',
              style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            PillTabBar(
              tabs: const ['Nạp thêm', 'Đặt lại số'],
              selectedIndex: _mode == _Mode.addFunds ? 0 : 1,
              onChanged: (i) => setState(() => _mode = i == 0 ? _Mode.addFunds : _Mode.setExact),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              decoration: InputDecoration(
                labelText: _mode == _Mode.addFunds ? 'Số tiền muốn nạp thêm' : 'Tổng quỹ mới',
                suffixText: 'đ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: 'Ghi chú (không bắt buộc)'),
            ),
            const SizedBox(height: 18),
            GradientButton(
              label: 'Xác nhận',
              onPressed: () async {
                final value = double.tryParse(_amountCtrl.text.trim());
                if (value == null) {
                  Get.snackbar('Thiếu thông tin', 'Vui lòng nhập một số hợp lệ');
                  return;
                }
                final note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();
                if (_mode == _Mode.addFunds) {
                  await controller.addToTotal(value, note: note);
                } else {
                  if (value < 0) {
                    Get.snackbar('Không hợp lệ', 'Tổng quỹ không thể âm');
                    return;
                  }
                  await controller.setTotal(value, note: note);
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
