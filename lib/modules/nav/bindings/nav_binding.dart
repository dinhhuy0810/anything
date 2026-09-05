import 'package:get/get.dart';

import '../../../data/providers/storage_provider.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../calendar/controllers/calendar_controller.dart';
import '../../expense/controllers/expense_controller.dart';
import '../controllers/nav_controller.dart';

/// Khai báo toàn bộ dependency cho app tại đây vì chỉ có 1 màn hình Nav
/// chứa 2 tab luôn tồn tại song song (IndexedStack) trong suốt vòng đời app.
class NavBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(StorageProvider(), permanent: true);
    Get.put(EventRepository(Get.find()), permanent: true);
    Get.put(ExpenseRepository(Get.find()), permanent: true);

    Get.put(CalendarController(Get.find()), permanent: true);
    Get.put(ExpenseController(Get.find()), permanent: true);
    Get.put(NavController());
  }
}
