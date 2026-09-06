/// Kết quả phân tích một link TikTok / Douyin: chứa link video không logo,
/// ảnh (nếu là bài đăng dạng album/slideshow) và nhạc nền.
class MediaDownloadResult {
  final String id;
  final String title;
  final String authorName;
  final String? authorAvatar;
  final String cover;
  final String? videoUrl;
  final String? videoHdUrl;
  final String? musicUrl;
  final List<String> images;
  final String platform;

  const MediaDownloadResult({
    required this.id,
    required this.title,
    required this.authorName,
    this.authorAvatar,
    required this.cover,
    this.videoUrl,
    this.videoHdUrl,
    this.musicUrl,
    this.images = const [],
    required this.platform,
  });

  bool get isSlideshow => images.isNotEmpty;
}
