import 'package:flutter/material.dart';

import '../values/app_colors.dart';

class FloatingNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const FloatingNavItem({required this.icon, required this.selectedIcon, required this.label});
}

/// Thanh điều hướng dạng "nổi" tự vẽ — thay cho [NavigationBar] mặc định.
/// Mục đang chọn có 1 khối vuông bo góc nhẹ (không phải viên thuốc dài) làm
/// nền gradient sau icon, nhãn chữ luôn hiển thị bên dưới cho mọi mục.
class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<FloatingNavItem> items;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              final item = items[i];
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        width: 42,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: selected ? AppColors.gradientPrimary : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          selected ? item.selectedIcon : item.icon,
                          size: 21,
                          color: selected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                          color: selected ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
