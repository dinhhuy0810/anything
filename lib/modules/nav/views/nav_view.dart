import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/widgets/floating_nav_bar.dart';
import '../../budget/views/budget_view.dart';
import '../../calendar/views/calendar_view.dart';
import '../../downloader/views/downloader_view.dart';
import '../controllers/nav_controller.dart';

class NavView extends GetView<NavController> {
  const NavView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            CalendarView(),
            BudgetView(),
            DownloaderView(),
          ],
        ),
        bottomNavigationBar: FloatingNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          items: const [
            FloatingNavItem(
              icon: Icons.calendar_month_outlined,
              selectedIcon: Icons.calendar_month_rounded,
              label: 'Lịch',
            ),
            FloatingNavItem(
              icon: Icons.account_balance_wallet_outlined,
              selectedIcon: Icons.account_balance_wallet_rounded,
              label: 'Ngân sách',
            ),
            FloatingNavItem(
              icon: Icons.download_outlined,
              selectedIcon: Icons.download_rounded,
              label: 'Tải video',
            ),
          ],
        ),
      ),
    );
  }
}
