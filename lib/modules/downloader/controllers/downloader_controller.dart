import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../../data/models/media_download_model.dart';
import '../../../data/services/media_downloader_service.dart';

enum DownloadJobState { idle, downloading, done, error }

class DownloaderController extends GetxController {
  final MediaDownloaderService _service;
  DownloaderController(this._service);

  /// Sở hữu bởi controller (không phải widget) để tồn tại đúng 1 lần suốt
  /// vòng đời tab và được dispose đúng chỗ trong [onClose] — tránh tạo mới
  /// TextEditingController mỗi lần build() như khi để trong StatelessWidget.
  final TextEditingController linkController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final result = Rxn<MediaDownloadResult>();

  final jobState = DownloadJobState.idle.obs;
  final jobProgress = 0.0.obs;
  final jobLabel = ''.obs;

  final history = <MediaDownloadResult>[].obs;

  @override
  void onClose() {
    linkController.dispose();
    super.onClose();
  }

  Future<void> resolveLink(String url) async {
    errorMessage.value = null;
    result.value = null;
    isLoading.value = true;
    try {
      final res = await _service.resolve(url);
      result.value = res;
      history.insert(0, res);
      if (history.length > 20) history.removeRange(20, history.length);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadVideo(MediaDownloadResult media, {bool hd = true}) async {
    final url = (hd ? media.videoHdUrl : media.videoUrl) ?? media.videoUrl ?? media.videoHdUrl;
    if (url == null || url.isEmpty) {
      Get.snackbar('Không có video', 'Bài đăng này không có video để tải.');
      return;
    }
    await _downloadAndSave(url: url, suggestedName: '${media.id}.mp4', isVideo: true, label: 'Đang tải video...');
  }

  Future<void> downloadImage(String imageUrl, int index) async {
    await _downloadAndSave(
      url: imageUrl,
      suggestedName: 'image_$index.jpg',
      isVideo: false,
      label: 'Đang tải ảnh ${index + 1}...',
    );
  }

  Future<void> downloadAllImages(MediaDownloadResult media) async {
    for (var i = 0; i < media.images.length; i++) {
      await downloadImage(media.images[i], i);
    }
  }

  /// Nhạc nền không thể lưu vào thư viện ảnh/video của hệ thống,
  /// nên được lưu vào thư mục tài liệu riêng của app.
  Future<void> downloadMusic(MediaDownloadResult media) async {
    final url = media.musicUrl;
    if (url == null || url.isEmpty) {
      Get.snackbar('Không có nhạc', 'Bài đăng này không có nhạc nền để tải.');
      return;
    }
    jobState.value = DownloadJobState.downloading;
    jobProgress.value = 0;
    jobLabel.value = 'Đang tải nhạc nền...';
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/nhac_${media.id}.mp3';
      await _service.downloadFile(
        url,
        filePath,
        onProgress: (received, total) {
          if (total > 0) jobProgress.value = received / total;
        },
      );
      jobState.value = DownloadJobState.done;
      Get.snackbar('Đã lưu nhạc', 'File đã lưu trong bộ nhớ ứng dụng: $filePath');
    } catch (e) {
      jobState.value = DownloadJobState.error;
      Get.snackbar('Lỗi tải xuống', e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _downloadAndSave({
    required String url,
    required String suggestedName,
    required bool isVideo,
    required String label,
  }) async {
    jobState.value = DownloadJobState.downloading;
    jobProgress.value = 0;
    jobLabel.value = label;
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          throw Exception('Bạn cần cấp quyền truy cập thư viện ảnh/video để lưu file.');
        }
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$suggestedName';

      await _service.downloadFile(
        url,
        filePath,
        onProgress: (received, total) {
          if (total > 0) jobProgress.value = received / total;
        },
      );

      if (isVideo) {
        await Gal.putVideo(filePath, album: 'TikTok Downloads');
      } else {
        await Gal.putImage(filePath, album: 'TikTok Downloads');
      }

      final file = File(filePath);
      if (await file.exists()) await file.delete();

      jobState.value = DownloadJobState.done;
      Get.snackbar('Đã lưu', 'Đã lưu vào thư viện ảnh/video của bạn.');
    } catch (e) {
      jobState.value = DownloadJobState.error;
      Get.snackbar('Lỗi tải xuống', e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void reset() {
    result.value = null;
    errorMessage.value = null;
    jobState.value = DownloadJobState.idle;
  }
}
