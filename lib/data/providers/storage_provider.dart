import 'dart:convert';

import 'package:get_storage/get_storage.dart';

/// Lớp trung gian đọc/ghi dữ liệu local (dùng GetStorage).
/// Sau này nếu muốn đổi sang API hoặc database khác, chỉ cần sửa ở đây.
class StorageProvider {
  final _box = GetStorage();

  List<Map<String, dynamic>> readList(String key) {
    final raw = _box.read<String>(key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> list) {
    return _box.write(key, jsonEncode(list));
  }
}
