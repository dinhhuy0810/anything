import 'package:flutter/material.dart';

import '../values/app_colors.dart';

/// Nút hành động nổi dạng viên thuốc gradient, thay [FloatingActionButton]
/// mặc định. Truyền [label] để có dạng mở rộng (icon + chữ), bỏ trống để
/// chỉ hiện icon tròn.
class GradientFab extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;

  const GradientFab({super.key, required this.onPressed, required this.icon, this.label});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: label != null ? 20 : 16),
          decoration: BoxDecoration(
            gradient: AppColors.gradientPrimary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white),
              if (label != null) ...[
                const SizedBox(width: 8),
                Text(label!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
