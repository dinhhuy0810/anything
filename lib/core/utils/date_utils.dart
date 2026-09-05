import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String formatFull(DateTime date) {
    return DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(date);
  }

  static String formatShort(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  static String formatMonthYear(DateTime date) => DateFormat('MM/yyyy').format(date);

  static String formatTime(DateTime date) => DateFormat('HH:mm').format(date);

  static String formatCurrency(num amount) {
    final f = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return f.format(amount);
  }
}
