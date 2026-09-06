import 'package:flutter/material.dart';

import '../values/app_colors.dart';

/// Nút phụ dạng viền mềm, dùng cho hành động thứ yếu (thay [OutlinedButton]
/// mặc định) — nền nhạt, viền tím nhạt, bo tròn đồng bộ với [GradientButton].
class SoftButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final Color color;

  const SoftButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.fullWidth = true,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: disabled ? null : onPressed,
          child: Container(
            height: 52,
            width: fullWidth ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: color, size: 19),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
