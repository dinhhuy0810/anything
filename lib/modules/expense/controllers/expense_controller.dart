import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../core/values/expense_categories.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/repositories/expense_repository.dart';

class ExpenseController extends GetxController {
  final ExpenseRepository _repository;
  ExpenseController(this._repository);

  final expenses = <ExpenseModel>[].obs;
  final selectedMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;
  final _uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    expenses.assignAll(_repository.getAll());
  }

  List<ExpenseModel> get expensesInMonth {
    final list = expenses
        .where((e) =>
            e.date.year == selectedMonth.value.year && e.date.month == selectedMonth.value.month)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double get totalIncome => expensesInMonth
      .where((e) => e.type == TransactionType.income)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalExpense => expensesInMonth
      .where((e) => e.type == TransactionType.expense)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get balance => totalIncome - totalExpense;

  Map<String, double> get expenseByCategory {
    final map = <String, double>{};
    for (final e in expensesInMonth.where((e) => e.type == TransactionType.expense)) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  void changeMonth(int offset) {
    final current = selectedMonth.value;
    selectedMonth.value = DateTime(current.year, current.month + offset);
  }

  Future<void> addExpense({
    String? id,
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    final model = ExpenseModel(
      id: id ?? _uuid.v4(),
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: date,
      note: note,
    );
    expenses.removeWhere((e) => e.id == model.id);
    expenses.add(model);
    await _repository.saveAll(expenses);
  }

  Future<void> deleteExpense(ExpenseModel model) async {
    expenses.removeWhere((e) => e.id == model.id);
    await _repository.saveAll(expenses);
  }
}
