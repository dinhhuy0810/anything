import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;
  final TransactionType type;

  const ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class ExpenseCategories {
  ExpenseCategories._();

  static const List<ExpenseCategory> expenseCategories = [
    ExpenseCategory(name: 'Ăn uống', icon: Icons.restaurant, color: Colors.orange, type: TransactionType.expense),
    ExpenseCategory(name: 'Di chuyển', icon: Icons.directions_bike, color: Colors.blue, type: TransactionType.expense),
    ExpenseCategory(name: 'Mua sắm', icon: Icons.shopping_bag, color: Colors.pink, type: TransactionType.expense),
    ExpenseCategory(name: 'Hóa đơn', icon: Icons.receipt_long, color: Colors.purple, type: TransactionType.expense),
    ExpenseCategory(name: 'Giải trí', icon: Icons.movie, color: Colors.teal, type: TransactionType.expense),
    ExpenseCategory(name: 'Sức khỏe', icon: Icons.local_hospital, color: Colors.red, type: TransactionType.expense),
    ExpenseCategory(name: 'Giáo dục', icon: Icons.school, color: Colors.indigo, type: TransactionType.expense),
    ExpenseCategory(name: 'Khác', icon: Icons.category, color: Colors.grey, type: TransactionType.expense),
  ];

  static const List<ExpenseCategory> incomeCategories = [
    ExpenseCategory(name: 'Lương', icon: Icons.attach_money, color: Colors.green, type: TransactionType.income),
    ExpenseCategory(name: 'Thưởng', icon: Icons.card_giftcard, color: Colors.amber, type: TransactionType.income),
    ExpenseCategory(name: 'Đầu tư', icon: Icons.trending_up, color: Colors.lightGreen, type: TransactionType.income),
    ExpenseCategory(name: 'Khác', icon: Icons.category, color: Colors.grey, type: TransactionType.income),
  ];

  static List<ExpenseCategory> byType(TransactionType type) =>
      type == TransactionType.income ? incomeCategories : expenseCategories;

  static ExpenseCategory findByName(String name, TransactionType type) {
    return byType(type).firstWhere(
      (c) => c.name == name,
      orElse: () => byType(type).last,
    );
  }
}
