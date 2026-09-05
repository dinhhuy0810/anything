import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../calendar/views/calendar_view.dart';
import '../../expense/views/expense_view.dart';
import '../controllers/nav_controller.dart';

class NavView extends GetView<NavController> {
  const NavView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            CalendarView(),
            ExpenseView(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.changeTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Lịch',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Chi tiêu',
            ),
          ],
        ),
      ),
    );
  }
}
