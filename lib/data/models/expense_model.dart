import '../../core/values/expense_categories.dart';

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? note;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type.name,
        'category': category,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }
}
