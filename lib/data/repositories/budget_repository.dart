import '../models/budget_category_model.dart';
import '../models/budget_history_model.dart';
import '../providers/storage_provider.dart';

class BudgetRepository {
  static const _kTotal = 'budget_total_amount';
  static const _kCategories = 'budget_categories';
  static const _kHistory = 'budget_history';

  final StorageProvider _storage;
  BudgetRepository(this._storage);

  double getTotal() => _storage.readDouble(_kTotal, fallback: 0);

  Future<void> saveTotal(double value) => _storage.writeDouble(_kTotal, value);

  List<BudgetCategoryModel> getCategories() {
    return _storage.readList(_kCategories).map(BudgetCategoryModel.fromJson).toList();
  }

  Future<void> saveCategories(List<BudgetCategoryModel> categories) {
    return _storage.writeList(_kCategories, categories.map((e) => e.toJson()).toList());
  }

  List<BudgetHistoryEntry> getHistory() {
    return _storage.readList(_kHistory).map(BudgetHistoryEntry.fromJson).toList();
  }

  Future<void> saveHistory(List<BudgetHistoryEntry> history) {
    return _storage.writeList(_kHistory, history.map((e) => e.toJson()).toList());
  }
}
