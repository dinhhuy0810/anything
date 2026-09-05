import '../models/expense_model.dart';
import '../providers/storage_provider.dart';

class ExpenseRepository {
  static const _key = 'expenses';
  final StorageProvider _storage;

  ExpenseRepository(this._storage);

  List<ExpenseModel> getAll() {
    return _storage.readList(_key).map(ExpenseModel.fromJson).toList();
  }

  Future<void> saveAll(List<ExpenseModel> expenses) {
    return _storage.writeList(_key, expenses.map((e) => e.toJson()).toList());
  }
}
