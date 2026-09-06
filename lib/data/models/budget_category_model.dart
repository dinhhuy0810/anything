import 'package:flutter/material.dart';

import '../../core/values/budget_icons.dart';

/// Một "hạng mục" trong tổng ngân sách, ví dụ: Ăn uống, Di chuyển...
/// [allocated] là số tiền đã được chia (phân bổ) từ tổng quỹ cho hạng mục này.
class BudgetCategoryModel {
  final String id;
  final String name;
  final String iconKey;
  final int colorValue;
  final double allocated;

  const BudgetCategoryModel({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorValue,
    required this.allocated,
  });

  IconData get icon => BudgetIcons.get(iconKey);
  Color get color => Color(colorValue);

  BudgetCategoryModel copyWith({
    String? name,
    String? iconKey,
    int? colorValue,
    double? allocated,
  }) {
    return BudgetCategoryModel(
      id: id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      allocated: allocated ?? this.allocated,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconKey': iconKey,
        'colorValue': colorValue,
        'allocated': allocated,
      };

  factory BudgetCategoryModel.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconKey: json['iconKey'] as String? ?? 'other',
      colorValue: json['colorValue'] as int? ?? 0xFF6C5CE7,
      allocated: (json['allocated'] as num?)?.toDouble() ?? 0,
    );
  }
}
