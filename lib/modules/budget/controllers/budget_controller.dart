import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/budget_category_model.dart';
import '../../../data/models/budget_history_model.dart';
import '../../../data/repositories/budget_repository.dart';

class BudgetController extends GetxController {
  final BudgetRepository _repository;
  BudgetController(this._repository);

  final _uuid = const Uuid();

  final totalAmount = 0.0.obs;
  final categories = <BudgetCategoryModel>[].obs;
  final history = <BudgetHistoryEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    totalAmount.value = _repository.getTotal();

    final savedCategories = _repository.getCategories();
    if (savedCategories.isEmpty) {
      categories.assignAll(_defaultCategories());
      _repository.saveCategories(categories);
    } else {
      categories.assignAll(savedCategories);
    }

    final savedHistory = _repository.getHistory();
    savedHistory.sort((a, b) => b.date.compareTo(a.date));
    history.assignAll(savedHistory);
  }

  List<BudgetCategoryModel> _defaultCategories() {
    final seed = <List<Object>>[
      ['Ăn uống', 'restaurant', 0xFFFF7675],
      ['Di chuyển', 'moto', 0xFF74B9FF],
      ['Mua sắm', 'shopping', 0xFFE84393],
      ['Hóa đơn', 'bill', 0xFF6C5CE7],
      ['Giải trí', 'movie', 0xFF00CEC9],
      ['Sức khỏe', 'health', 0xFFEF5777],
      ['Giáo dục', 'school', 0xFF0984E3],
      ['Khác', 'other', 0xFF636E72],
    ];
    return seed
        .map((e) => BudgetCategoryModel(
              id: _uuid.v4(),
              name: e[0] as String,
              iconKey: e[1] as String,
              colorValue: e[2] as int,
              allocated: 0,
            ))
        .toList();
  }

  // ---------- Số liệu tổng hợp ----------

  /// Tổng số tiền đã được chia (phân bổ) cho tất cả hạng mục.
  double get allocatedTotal => categories.fold(0.0, (sum, c) => sum + c.allocated);

  /// Số tiền trong quỹ tổng chưa được chia cho hạng mục nào.
  double get unallocated => totalAmount.value - allocatedTotal;

  /// Tổng số tiền đã chi tiêu thực tế (tất cả hạng mục).
  double get totalSpent => history
      .where((h) => h.type == BudgetHistoryType.expense)
      .fold(0.0, (sum, h) => sum + h.amount);

  double spentFor(String categoryId) => history
      .where((h) => h.type == BudgetHistoryType.expense && h.categoryId == categoryId)
      .fold(0.0, (sum, h) => sum + h.amount);

  double remainingFor(BudgetCategoryModel category) =>
      category.allocated - spentFor(category.id);

  List<BudgetHistoryEntry> historyFor(String categoryId) =>
      history.where((h) => h.categoryId == categoryId).toList();

  // ---------- Thao tác với quỹ tổng ----------

  /// Nạp thêm (hoặc rút bớt nếu [amount] âm) vào quỹ tổng.
  Future<void> addToTotal(double amount, {String? note}) async {
    if (amount == 0) return;
    totalAmount.value += amount;
    await _repository.saveTotal(totalAmount.value);
    _pushHistory(
      type: BudgetHistoryType.topup,
      amount: amount.abs(),
      isIncrease: amount >= 0,
      title: amount >= 0 ? 'Nạp thêm vào quỹ' : 'Rút bớt khỏi quỹ',
      note: note,
    );
  }

  /// Đặt lại tổng quỹ về đúng giá trị [newTotal] (chỉnh sửa trực tiếp).
  Future<void> setTotal(double newTotal, {String? note}) async {
    final delta = newTotal - totalAmount.value;
    if (delta == 0) return;
    await addToTotal(delta, note: note ?? 'Chỉnh sửa tổng quỹ');
  }

  // ---------- Thao tác với hạng mục ----------

  Future<void> addCategory({
    required String name,
    required String iconKey,
    required Color color,
  }) async {
    final category = BudgetCategoryModel(
      id: _uuid.v4(),
      name: name,
      iconKey: iconKey,
      colorValue: color.value,
      allocated: 0,
    );
    categories.add(category);
    await _repository.saveCategories(categories);
  }

  Future<void> updateCategory(
    BudgetCategoryModel category, {
    String? name,
    String? iconKey,
    Color? color,
  }) async {
    final idx = categories.indexWhere((c) => c.id == category.id);
    if (idx == -1) return;
    categories[idx] = category.copyWith(
      name: name,
      iconKey: iconKey,
      colorValue: color?.value,
    );
    await _repository.saveCategories(categories);
  }

  Future<void> deleteCategory(BudgetCategoryModel category) async {
    categories.removeWhere((c) => c.id == category.id);
    history.removeWhere((h) => h.categoryId == category.id);
    await _repository.saveCategories(categories);
    await _repository.saveHistory(history);
  }

  /// Chia lại số tiền phân bổ cho 1 hạng mục thành [newAllocated].
  /// Phần chênh lệch được lấy từ (hoặc trả về) quỹ chưa phân bổ.
  Future<void> allocate(BudgetCategoryModel category, double newAllocated) async {
    final idx = categories.indexWhere((c) => c.id == category.id);
    if (idx == -1) return;
    final delta = newAllocated - category.allocated;
    if (delta == 0) return;
    categories[idx] = category.copyWith(allocated: newAllocated);
    await _repository.saveCategories(categories);
    _pushHistory(
      type: BudgetHistoryType.allocate,
      amount: delta.abs(),
      isIncrease: delta >= 0,
      title: delta >= 0 ? 'Phân bổ vào ${category.name}' : 'Rút bớt khỏi ${category.name}',
      categoryId: category.id,
      categoryName: category.name,
    );
  }

  // ---------- Chi tiêu ----------

  Future<void> addExpense({
    required BudgetCategoryModel category,
    required double amount,
    required String title,
    String? note,
    DateTime? date,
  }) async {
    _pushHistory(
      type: BudgetHistoryType.expense,
      amount: amount,
      isIncrease: false,
      title: title,
      categoryId: category.id,
      categoryName: category.name,
      note: note,
      date: date,
    );
  }

  Future<void> deleteHistoryEntry(BudgetHistoryEntry entry) async {
    history.removeWhere((h) => h.id == entry.id);
    await _repository.saveHistory(history);
  }

  void _pushHistory({
    required BudgetHistoryType type,
    required double amount,
    required bool isIncrease,
    required String title,
    String? categoryId,
    String? categoryName,
    String? note,
    DateTime? date,
  }) {
    final entry = BudgetHistoryEntry(
      id: _uuid.v4(),
      type: type,
      amount: amount,
      isIncrease: isIncrease,
      title: title,
      categoryId: categoryId,
      categoryName: categoryName,
      note: note,
      date: date ?? DateTime.now(),
    );
    history.insert(0, entry);
    _repository.saveHistory(history);
  }
}
