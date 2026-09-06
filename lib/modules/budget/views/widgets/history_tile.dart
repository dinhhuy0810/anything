import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/values/app_colors.dart';
import '../../../../data/models/budget_history_model.dart';

class HistoryTile extends StatelessWidget {
  final BudgetHistoryEntry entry;
  final VoidCallback onDelete;

  const HistoryTile({super.key, required this.entry, required this.onDelete});

  IconData get _icon {
    switch (entry.type) {
      case BudgetHistoryType.topup:
        return entry.isIncrease ? Icons.savings_rounded : Icons.money_off_rounded;
      case BudgetHistoryType.allocate:
        return Icons.pie_chart_rounded;
      case BudgetHistoryType.expense:
        return Icons.shopping_cart_rounded;
    }
  }

  Color get _color {
    switch (entry.type) {
      case BudgetHistoryType.topup:
        return entry.isIncrease ? AppColors.success : AppColors.danger;
      case BudgetHistoryType.allocate:
        return AppColors.primary;
      case BudgetHistoryType.expense:
        return AppColors.danger;
    }
  }

  String get _amountText {
    final sign = entry.type == BudgetHistoryType.expense
        ? '-'
        : (entry.isIncrease ? '+' : '-');
    return '$sign${AppDateUtils.formatCurrency(entry.amount)}';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.danger),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Xóa mục này?'),
                content: Text('Bạn có chắc muốn xóa "${entry.title}" khỏi lịch sử?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Xóa', style: TextStyle(color: AppColors.danger)),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: _color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(_icon, color: _color, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  const SizedBox(height: 2),
                  Text(
                    '${AppDateUtils.formatShort(entry.date)} • ${AppDateUtils.formatTime(entry.date)}'
                    '${entry.note != null && entry.note!.isNotEmpty ? ' • ${entry.note}' : ''}',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              _amountText,
              style: TextStyle(fontWeight: FontWeight.w800, color: _color, fontSize: 13.5),
            ),
          ],
        ),
      ),
    );
  }
}
