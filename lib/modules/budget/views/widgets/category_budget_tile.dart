import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/values/app_colors.dart';
import '../../../../data/models/budget_category_model.dart';

class CategoryBudgetTile extends StatelessWidget {
  final BudgetCategoryModel category;
  final double spent;
  final VoidCallback onTap;

  const CategoryBudgetTile({
    super.key,
    required this.category,
    required this.spent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = category.allocated - spent;
    final percent = category.allocated <= 0 ? 0.0 : (spent / category.allocated).clamp(0.0, 1.0);
    final overspent = remaining < 0;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(category.icon, color: category.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        overspent
                            ? '-${AppDateUtils.formatCurrency(remaining.abs())}'
                            : AppDateUtils.formatCurrency(remaining),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: overspent ? AppColors.danger : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 7,
                      backgroundColor: AppColors.surfaceMuted,
                      color: overspent ? AppColors.danger : category.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${AppDateUtils.formatCurrency(spent)} / ${AppDateUtils.formatCurrency(category.allocated)}',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
