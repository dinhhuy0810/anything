/// Loại giao dịch trong dòng lịch sử ngân sách.
enum BudgetHistoryType {
  /// Nạp thêm (hoặc điều chỉnh giảm) tổng quỹ.
  topup,

  /// Phân bổ (chia) tiền từ quỹ chưa phân bổ vào một hạng mục,
  /// hoặc rút bớt tiền khỏi hạng mục để trả về quỹ chung.
  allocate,

  /// Một khoản chi tiêu thực tế trừ vào hạng mục.
  expense,
}

class BudgetHistoryEntry {
  final String id;
  final BudgetHistoryType type;
  final double amount;

  /// Dương nếu là tăng (nạp/phân bổ vào), âm nếu là giảm (rút bớt).
  /// Với [BudgetHistoryType.expense] luôn là số dương (số tiền đã chi).
  final bool isIncrease;
  final String title;
  final String? categoryId;
  final String? categoryName;
  final String? note;
  final DateTime date;

  const BudgetHistoryEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.isIncrease,
    required this.title,
    this.categoryId,
    this.categoryName,
    this.note,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'isIncrease': isIncrease,
        'title': title,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory BudgetHistoryEntry.fromJson(Map<String, dynamic> json) {
    return BudgetHistoryEntry(
      id: json['id'] as String,
      type: BudgetHistoryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BudgetHistoryType.expense,
      ),
      amount: (json['amount'] as num).toDouble(),
      isIncrease: json['isIncrease'] as bool? ?? false,
      title: json['title'] as String,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
