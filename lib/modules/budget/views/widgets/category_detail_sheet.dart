import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/values/app_colors.dart';
import '../../../../data/models/budget_category_model.dart';
import '../../controllers/budget_controller.dart';
import 'add_category_sheet.dart';
import 'add_expense_sheet.dart';
import 'history_tile.dart';

class CategoryDetailSheet extends StatefulWidget {
  final BudgetCategoryModel category;
  const CategoryDetailSheet({super.key, required this.category});

  static Future<void> show(BudgetCategoryModel category) {
    return Get.bottomSheet(
      CategoryDetailSheet(category: category),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  @override
  State<CategoryDetailSheet> createState() => _CategoryDetailSheetState();
}

class _CategoryDetailSheetState extends State<CategoryDetailSheet> {
  late final TextEditingController _allocateCtrl;

  @override
  void initState() {
    super.initState();
    _allocateCtrl = TextEditingController(text: widget.category.allocated.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _allocateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BudgetController>();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Obx(() {
          BudgetCategoryModel? category;
          for (final c in controller.categories) {
            if (c.id == widget.category.id) {
              category = c;
              break;
            }
          }
          if (category == null) return const SizedBox.shrink();
          // Gán sang biến `final` để Dart giữ được kiểu non-null bên trong
          // các closure (onPressed: () => ...) bên dưới — biến `var` bị mất
          // suy luận non-null khi bị closure "chụp" lại.
          final cat = category;
          final spent = controller.spentFor(cat.id);
          final remaining = cat.allocated - spent;
          final entries = controller.historyFor(cat.id);
          final availableToAllocate = controller.unallocated + cat.allocated;

          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(color: cat.color.withOpacity(0.14), borderRadius: BorderRadius.circular(16)),
                    child: Icon(cat.icon, color: cat.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                        Text(
                          remaining < 0
                              ? 'Vượt ${AppDateUtils.formatCurrency(remaining.abs())}'
                              : 'Còn lại ${AppDateUtils.formatCurrency(remaining)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: remaining < 0 ? AppColors.danger : AppColors.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => AddCategorySheet.show(editing: cat),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(context, controller, cat),
                    icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _statBox('Đã chia', cat.allocated)),
                  const SizedBox(width: 10),
                  Expanded(child: _statBox('Đã chi', spent)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Phân bổ lại từ quỹ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                'Quỹ khả dụng để chia cho mục này: ${AppDateUtils.formatCurrency(availableToAllocate)}',
                style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _allocateCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Số tiền phân bổ', suffixText: 'đ'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final value = double.tryParse(_allocateCtrl.text.trim());
                      if (value == null || value < 0) {
                        Get.snackbar('Không hợp lệ', 'Vui lòng nhập số tiền hợp lệ');
                        return;
                      }
                      if (value > availableToAllocate) {
                        Get.snackbar('Vượt quỹ', 'Quỹ chưa phân bổ không đủ');
                        return;
                      }
                      await controller.allocate(cat, value);
                    },
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
                    child: const Text('Cập nhật'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => AddExpenseSheet.show(category: cat),
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: const Text('Thêm khoản chi cho mục này'),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Lịch sử của mục này', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(height: 8),
              if (entries.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Chưa có giao dịch nào.', style: TextStyle(color: AppColors.textSecondary)),
                )
              else
                ...entries.map((e) => HistoryTile(entry: e, onDelete: () => controller.deleteHistoryEntry(e))),
            ],
          );
        });
      },
    );
  }

  Widget _statBox(String label, double value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 2),
          Text(AppDateUtils.formatCurrency(value), style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, BudgetController controller, BudgetCategoryModel category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa hạng mục?'),
        content: Text('Xóa "${category.name}" sẽ xóa luôn lịch sử chi tiêu của mục này. Bạn có chắc chắn?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.deleteCategory(category);
              if (context.mounted) Get.back();
            },
            child: const Text('Xóa', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
