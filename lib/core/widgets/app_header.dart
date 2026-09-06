import 'package:flutter/material.dart';

import '../values/app_colors.dart';

/// Header tự vẽ thay cho [AppBar] mặc định của Flutter — tiêu đề lớn,
/// 2 khối màu mờ (blob) trang trí phía sau, bo góc dưới lớn tạo cảm giác
/// "thẻ nổi" thay vì thanh phẳng thường thấy.
class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  /// Nội dung phụ đặt bên dưới tiêu đề (vd: thanh chọn tab dạng pill).
  final Widget? bottom;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        child: Stack(
          children: [
            Positioned(top: -36, right: -24, child: _blob(110, AppColors.secondary.withOpacity(0.22))),
            Positioned(top: -46, left: -40, child: _blob(120, AppColors.primary.withOpacity(0.14))),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subtitle!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (trailing != null) trailing!,
                      ],
                    ),
                    if (bottom != null) ...[
                      const SizedBox(height: 14),
                      bottom!,
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
