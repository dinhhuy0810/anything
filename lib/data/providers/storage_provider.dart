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

  double readDouble(String key, {double fallback = 0}) {
    final v = _box.read(key);
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  Future<void> writeDouble(String key, double value) {
    return _box.write(key, value);
  }

  String? readString(String key) => _box.read<String>(key);

  Future<void> writeString(String key, String value) {
    return _box.write(key, value);
  }
}
