import 'package:flutter/material.dart';

/// Bảng màu chủ đạo của app — phong cách "soft modern" (nền sáng, thẻ bo tròn,
/// gradient tím-ngọc nhẹ nhàng, chữ đậm rõ ràng).
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF4B3FCF);
  static const Color secondary = Color(0xFF00CEC9);
  static const Color accentPink = Color(0xFFFF6B9A);

  // Nền / bề mặt
  static const Color background = Color(0xFFF6F5FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF0EEFB);
  static const Color border = Color(0xFFE7E4F5);

  // Chữ
  static const Color textPrimary = Color(0xFF201C3A);
  static const Color textSecondary = Color(0xFF827E9C);

  // Ngữ nghĩa
  static const Color success = Color(0xFF2ECC71);
  static const Color danger = Color(0xFFEF5777);
  static const Color warning = Color(0xFFFFA726);

  // Giữ tên cũ để tương thích ngược nếu còn nơi nào tham chiếu
  static const Color income = success;
  static const Color expense = danger;

  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientWarm = LinearGradient(
    colors: [Color(0xFFFF6B9A), Color(0xFFFFA726)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Bảng màu để người dùng chọn khi tạo hạng mục mới.
  static const List<Color> categoryPalette = [
    Color(0xFFFF7675),
    Color(0xFFE17055),
    Color(0xFFFFA502),
    Color(0xFFFDCB6E),
    Color(0xFF00B894),
    Color(0xFF00CEC9),
    Color(0xFF74B9FF),
    Color(0xFF0984E3),
    Color(0xFF6C5CE7),
    Color(0xFFA29BFE),
    Color(0xFFE84393),
    Color(0xFFFF6B9A),
    Color(0xFF636E72),
    Color(0xFF2D3436),
  ];
}
