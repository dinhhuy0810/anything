import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/section_title.dart';
import '../controllers/expense_controller.dart';
import 'widgets/add_expense_sheet.dart';
import 'widgets/category_breakdown.dart';
import 'widgets/expense_summary_card.dart';
import 'widgets/expense_tile.dart';

class ExpenseView extends GetView<ExpenseController> {
  const ExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý chi tiêu')),
      body: Obx(
        () => ListView(
          children: [
            ExpenseSummaryCard(
              month: controller.selectedMonth.value,
              income: controller.totalIncome,
              expense: controller.totalExpense,
              balance: controller.balance,
              onPrev: () => controller.changeMonth(-1),
              onNext: () => controller.changeMonth(1),
            ),
            if (controller.expenseByCategory.isNotEmpty) ...[
              const SectionTitle(title: 'Phân bổ chi tiêu'),
              CategoryBreakdown(
                data: controller.expenseByCategory,
                total: controller.totalExpense,
              ),
              const SizedBox(height: 8),
            ],
            const SectionTitle(title: 'Giao dịch trong tháng'),
            if (controller.expensesInMonth.isEmpty)
              const EmptyStateWidget(
                icon: Icons.receipt_long,
                message: 'Chưa có giao dịch nào trong tháng này.\nBấm nút + để thêm mới.',
              )
            else
              ...controller.expensesInMonth.map(
                (e) => ExpenseTile(expense: e, onDelete: () => controller.deleteExpense(e)),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddExpenseSheet.show(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
