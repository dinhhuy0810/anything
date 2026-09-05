import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/values/expense_categories.dart';
import '../../../../data/models/expense_model.dart';

class ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onDelete;

  const ExpenseTile({super.key, required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final category = ExpenseCategories.findByName(expense.category, expense.type);
    final isIncome = expense.type == TransactionType.income;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.color.withOpacity(0.15),
          child: Icon(category.icon, color: category.color),
        ),
        title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${expense.category} • ${AppDateUtils.formatShort(expense.date)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${AppDateUtils.formatCurrency(expense.amount)}',
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
