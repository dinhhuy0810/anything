import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final DateTime month;
  final double income;
  final double expense;
  final double balance;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const ExpenseSummaryCard({
    super.key,
    required this.month,
    required this.income,
    required this.expense,
    required this.balance,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: onPrev,
                ),
                Text(
                  'Tháng ${AppDateUtils.formatMonthYear(month)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: onNext,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppDateUtils.formatCurrency(balance),
              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const Text('Số dư', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _amountColumn('Thu nhập', income, Icons.arrow_upward, Colors.greenAccent),
                _amountColumn('Chi tiêu', expense, Icons.arrow_downward, Colors.redAccent.shade100),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _amountColumn(String label, double value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        Text(
          AppDateUtils.formatCurrency(value),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
