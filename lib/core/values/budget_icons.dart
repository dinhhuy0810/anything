import 'package:flutter/material.dart';

/// Danh sách icon cố định (const) cho hạng mục ngân sách.
/// Dùng key dạng String để lưu trữ thay vì IconData.codePoint động,
/// tránh lỗi icon bị tree-shake mất khi build release.
class BudgetIcons {
  BudgetIcons._();

  static const Map<String, IconData> icons = {
    'restaurant': Icons.restaurant_rounded,
    'moto': Icons.two_wheeler_rounded,
    'car': Icons.directions_car_filled_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'bill': Icons.receipt_long_rounded,
    'movie': Icons.movie_rounded,
    'health': Icons.local_hospital_rounded,
    'school': Icons.school_rounded,
    'home': Icons.home_rounded,
    'gift': Icons.card_giftcard_rounded,
    'travel': Icons.flight_takeoff_rounded,
    'pet': Icons.pets_rounded,
    'coffee': Icons.local_cafe_rounded,
    'phone': Icons.phone_android_rounded,
    'sport': Icons.sports_soccer_rounded,
    'saving': Icons.savings_rounded,
    'baby': Icons.child_care_rounded,
    'beauty': Icons.face_retouching_natural_rounded,
    'gaming': Icons.sports_esports_rounded,
    'other': Icons.category_rounded,
  };

  static IconData get(String key) => icons[key] ?? Icons.category_rounded;

  static List<String> get keys => icons.keys.toList();
}
