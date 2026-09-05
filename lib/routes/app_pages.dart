import 'package:get/get.dart';

import '../modules/nav/bindings/nav_binding.dart';
import '../modules/nav/views/nav_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: Routes.NAV,
      page: () => const NavView(),
      binding: NavBinding(),
    ),
  ];
}
