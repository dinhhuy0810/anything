import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/values/app_colors.dart';

class TotalBudgetCard extends StatelessWidget {
  final double total;
  final double allocated;
  final double unallocated;
  final double spent;
  final VoidCallback onEditTotal;
  final VoidCallback onAddFunds;

  const TotalBudgetCard({
    super.key,
    required this.total,
    required this.allocated,
    required this.unallocated,
    required this.spent,
    required this.onEditTotal,
    required this.onAddFunds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng quỹ của bạn',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: onEditTotal,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            AppDateUtils.formatCurrency(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _stat('Đã chia', allocated, Colors.white),
              ),
              Container(width: 1, height: 30, color: Colors.white24),
              Expanded(
                child: _stat('Chưa chia', unallocated, unallocated < 0 ? Colors.yellowAccent : Colors.white),
              ),
              Container(width: 1, height: 30, color: Colors.white24),
              Expanded(
                child: _stat('Đã chi', spent, Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAddFunds,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Nạp thêm quỹ', style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                minimumSize: const Size.fromHeight(44),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(
          AppDateUtils.formatCurrency(value),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ],
    );
  }
}
