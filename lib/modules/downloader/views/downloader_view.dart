import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/media_download_model.dart';
import '../controllers/downloader_controller.dart';

class DownloaderView extends GetView<DownloaderController> {
  const DownloaderView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Tải video / ảnh')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dán link TikTok hoặc Douyin',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Video/ảnh tải về sẽ không có logo watermark.',
                  style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.linkController,
                        decoration: const InputDecoration(
                          hintText: 'https://vt.tiktok.com/...',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: 'Dán từ bộ nhớ tạm',
                      onPressed: () async {
                        final data = await Clipboard.getData('text/plain');
                        if (data?.text != null) controller.linkController.text = data!.text!;
                      },
                      icon: const Icon(Icons.paste_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.resolveLink(controller.linkController.text),
                      icon: controller.isLoading.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.download_rounded),
                      label: Text(controller.isLoading.value ? 'Đang lấy dữ liệu...' : 'Lấy video / ảnh'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final err = controller.errorMessage.value;
            if (err == null) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.danger),
                  const SizedBox(width: 10),
                  Expanded(child: Text(err, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600))),
                ],
              ),
            );
          }),
          Obx(() {
            final media = controller.result.value;
            if (media == null) return const SizedBox.shrink();
            return _ResultCard(media: media);
          }),
          Obx(() {
            if (controller.jobState.value == DownloadJobState.downloading) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    Text(controller.jobLabel.value, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(value: controller.jobProgress.value, minHeight: 8),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Lưu ý: tính năng này dùng dịch vụ công khai bên thứ ba để lấy link không watermark, '
              'không phải sản phẩm chính thức của TikTok/Douyin nên đôi lúc có thể chậm hoặc lỗi. '
              'Vui lòng chỉ tải nội dung cho mục đích cá nhân và tôn trọng bản quyền tác giả.',
              style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final MediaDownloadResult media;
  const _ResultCard({required this.media});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DownloaderController>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: media.cover.isEmpty
                ? Container(color: AppColors.surfaceMuted)
                : Image.network(
                    media.cover,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceMuted),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        media.platform,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        media.authorName,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(media.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                const SizedBox(height: 14),
                if (media.isSlideshow) ...[
                  Text('${media.images.length} ảnh trong bài đăng', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 12)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: media.images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final img = media.images[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              Image.network(img, width: 70, height: 90, fit: BoxFit.cover),
                              Positioned(
                                right: 2,
                                bottom: 2,
                                child: GestureDetector(
                                  onTap: () => controller.downloadImage(img, index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                    child: const Icon(Icons.download_rounded, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => controller.downloadAllImages(media),
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Tải tất cả ảnh'),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: () => controller.downloadVideo(media, hd: true),
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Tải video (không logo)'),
                  ),
                  const SizedBox(height: 10),
                  if (media.musicUrl != null && media.musicUrl!.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => controller.downloadMusic(media),
                      icon: const Icon(Icons.music_note_rounded),
                      label: const Text('Tải nhạc nền'),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
