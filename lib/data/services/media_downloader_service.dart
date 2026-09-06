import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/media_download_model.dart';

/// Gọi một API công khai, không chính thức (tikwm.com) để lấy link video/ảnh
/// KHÔNG có logo watermark từ link TikTok hoặc Douyin.
///
/// LƯU Ý QUAN TRỌNG:
/// - Đây là dịch vụ bên thứ 3, miễn phí, không phải của TikTok/Douyin hay Anthropic.
///   Độ ổn định, tốc độ và khả năng hỗ trợ Douyin không được đảm bảo 100%,
///   API có thể thay đổi hoặc ngừng hoạt động bất cứ lúc nào.
/// - Chỉ nên dùng để tải nội dung phục vụ mục đích cá nhân, tôn trọng bản quyền
///   và điều khoản sử dụng của nền tảng gốc.
class MediaDownloaderService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'User-Agent': 'Mozilla/5.0 (Linux; Android 10)'},
    ),
  );

  static const _endpoint = 'https://www.tikwm.com/api/';

  bool isSupportedLink(String url) {
    final lower = url.toLowerCase();
    return lower.contains('tiktok.com') || lower.contains('douyin.com') || lower.contains('vt.tiktok.com');
  }

  String detectPlatform(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('douyin.com')) return 'Douyin';
    return 'TikTok';
  }

  String _normalizeMediaUrl(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return 'https://www.tikwm.com$raw';
  }

  Future<MediaDownloadResult> resolve(String rawUrl) async {
    final url = rawUrl.trim();
    if (url.isEmpty) {
      throw Exception('Vui lòng dán link video TikTok hoặc Douyin.');
    }
    if (!isSupportedLink(url)) {
      throw Exception('Link không hợp lệ. Vui lòng dán link TikTok hoặc Douyin.');
    }

    final response = await _dio.get(_endpoint, queryParameters: {
      'url': url,
      'hd': 1,
    });

    final body = response.data;
    Map<String, dynamic> json;
    if (body is Map<String, dynamic>) {
      json = body;
    } else if (body is String && body.isNotEmpty) {
      try {
        json = jsonDecode(body) as Map<String, dynamic>;
      } catch (_) {
        json = {};
      }
    } else {
      json = {};
    }

    final code = json['code'];
    if (code != 0 || json['data'] == null) {
      final msg = json['msg']?.toString() ?? 'Không lấy được dữ liệu, vui lòng thử lại.';
      throw Exception(msg);
    }

    final data = json['data'] as Map<String, dynamic>;
    final author = data['author'] as Map<String, dynamic>?;

    final imagesRaw = data['images'];
    final images = imagesRaw is List
        ? imagesRaw.map((e) => _normalizeMediaUrl(e.toString())).where((e) => e.isNotEmpty).toList()
        : <String>[];

    return MediaDownloadResult(
      id: data['id']?.toString() ?? '',
      title: (data['title'] as String?)?.trim().isNotEmpty == true ? data['title'] as String : 'Không có tiêu đề',
      authorName: author?['nickname']?.toString() ?? author?['unique_id']?.toString() ?? 'Không rõ',
      authorAvatar: _normalizeMediaUrl(author?['avatar']?.toString()),
      cover: _normalizeMediaUrl(data['cover']?.toString() ?? data['origin_cover']?.toString()),
      videoUrl: images.isEmpty ? _normalizeMediaUrl(data['play']?.toString()) : null,
      videoHdUrl: images.isEmpty ? _normalizeMediaUrl(data['hdplay']?.toString()) : null,
      musicUrl: _normalizeMediaUrl(data['music']?.toString()),
      images: images,
      platform: detectPlatform(url),
    );
  }

  /// Tải 1 file nhị phân (video/ảnh/nhạc) từ [url] về [savePath], có callback tiến trình.
  Future<void> downloadFile(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) async {
    await _dio.download(
      url,
      savePath,
      onReceiveProgress: onProgress,
      options: Options(responseType: ResponseType.bytes),
    );
  }
}
