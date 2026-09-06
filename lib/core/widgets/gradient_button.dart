import 'package:flutter/material.dart';

import '../values/app_colors.dart';

/// Nút bấm gradient tự vẽ (thay [ElevatedButton] mặc định) cho hành động
/// chính. [fullWidth]=true (mặc định) để chiếm hết chiều ngang — tắt đi
/// khi dùng làm nút nổi (floating action) chỉ vừa nội dung.
class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final Gradient? gradient;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.loading = false,
    this.fullWidth = true,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: disabled || loading ? null : onPressed,
          child: Container(
            height: 52,
            width: fullWidth ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: gradient ?? AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 19),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
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
