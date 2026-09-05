import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/values/expense_categories.dart';

class CategoryBreakdown extends StatelessWidget {
  final Map<String, double> data;
  final double total;

  const CategoryBreakdown({super.key, required this.data, required this.total});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries.map((entry) {
          final category = ExpenseCategories.findByName(entry.key, TransactionType.expense);
          final percent = total == 0 ? 0.0 : entry.value / total;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(category.icon, size: 16, color: category.color),
                    const SizedBox(width: 6),
                    Expanded(child: Text(entry.key)),
                    Text(AppDateUtils.formatCurrency(entry.value)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    color: category.color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
