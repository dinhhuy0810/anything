import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/gradient_fab.dart';
import '../../../core/widgets/pill_tab_bar.dart';
import '../../../core/widgets/section_title.dart';
import '../controllers/budget_controller.dart';
import 'widgets/add_category_sheet.dart';
import 'widgets/add_expense_sheet.dart';
import 'widgets/category_budget_tile.dart';
import 'widgets/category_detail_sheet.dart';
import 'widgets/edit_total_sheet.dart';
import 'widgets/history_tile.dart';
import 'widgets/total_budget_card.dart';

class BudgetView extends GetView<BudgetController> {
  const BudgetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Obx(
            () => AppHeader(
              title: 'Ngân sách',
              subtitle: 'Quản lý quỹ & chi tiêu của bạn',
              bottom: PillTabBar(
                tabs: const ['Hạng mục', 'Lịch sử'],
                selectedIndex: controller.tabIndex.value,
                onChanged: (i) => controller.tabIndex.value = i,
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => IndexedStack(
                index: controller.tabIndex.value,
                sizing: StackFit.expand,
                children: const [
                  _CategoriesTab(),
                  _HistoryTab(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: GradientFab(
        onPressed: () => AddExpenseSheet.show(),
        icon: Icons.add_rounded,
        label: 'Ghi chi tiêu',
      ),
    );
  }
}

class _CategoriesTab extends GetView<BudgetController> {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView(
        padding: const EdgeInsets.only(bottom: 110),
        children: [
          TotalBudgetCard(
            total: controller.totalAmount.value,
            allocated: controller.allocatedTotal,
            unallocated: controller.unallocated,
            spent: controller.totalSpent,
            onEditTotal: () => EditTotalSheet.show(addFunds: false),
            onAddFunds: () => EditTotalSheet.show(addFunds: true),
          ),
          SectionTitle(
            title: 'Hạng mục của bạn',
            trailing: TextButton.icon(
              onPressed: () => AddCategorySheet.show(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm mục'),
            ),
          ),
          if (controller.categories.isEmpty)
            const EmptyStateWidget(
              icon: Icons.pie_chart_outline_rounded,
              message: 'Chưa có hạng mục nào.\nBấm "Thêm mục" để tạo hạng mục đầu tiên.',
            )
          else
            ...controller.categories.map(
              (c) => CategoryBudgetTile(
                category: c,
                spent: controller.spentFor(c.id),
                onTap: () => CategoryDetailSheet.show(c),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryTab extends GetView<BudgetController> {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.history.isEmpty) {
        return const EmptyStateWidget(
          icon: Icons.receipt_long_rounded,
          message: 'Chưa có giao dịch nào.\nMọi khoản nạp quỹ, phân bổ và chi tiêu sẽ hiện ở đây.',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 110),
        itemCount: controller.history.length,
        itemBuilder: (context, index) {
          final entry = controller.history[index];
          return HistoryTile(entry: entry, onDelete: () => controller.deleteHistoryEntry(entry));
        },
      );
    });
  }
}
