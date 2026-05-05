import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/context_colors.dart';
import '../../../models/chapter.dart';
import '../../../services/chapter_service.dart';
import '../../../services/download_service.dart';

class ChapterListItem extends StatefulWidget {
  final Chapter chapter;
  final bool isUnlocked;
  final bool isPremiumUser;
  final VoidCallback onTap;

  const ChapterListItem({
    super.key,
    required this.chapter,
    required this.isUnlocked,
    required this.onTap,
    this.isPremiumUser = false,
  });

  @override
  State<ChapterListItem> createState() => _ChapterListItemState();
}

class _ChapterListItemState extends State<ChapterListItem> {
  final _downloadService = DownloadService.instance;
  final _chapterService = ChapterService();

  bool _isDownloaded = false;
  bool _downloading = false;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _checkDownload();
  }

  Future<void> _checkDownload() async {
    final downloaded =
        await _downloadService.isDownloaded(widget.chapter.id);
    if (mounted) setState(() => _isDownloaded = downloaded);
  }

  Future<void> _download() async {
    if (_downloading) return;
    setState(() {
      _downloading = true;
      _progress = 0;
    });
    try {
      final pages =
          await _chapterService.fetchPages(widget.chapter.id);
      await _downloadService.downloadChapter(
        chapter: widget.chapter,
        pages: pages,
        onProgress: (current, total) {
          if (mounted) {
            setState(() => _progress = current / total);
          }
        },
      );
      if (mounted) setState(() => _isDownloaded = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('İndirme hatası: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _deleteDownload() async {
    await _downloadService.deleteDownload(widget.chapter.id);
    if (mounted) setState(() => _isDownloaded = false);
  }

  void _showDownloadMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              title: const Text('İndirmeyi Sil'),
              onTap: () {
                Navigator.pop(ctx);
                _deleteDownload();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLocked = widget.chapter.isPremium && !widget.isUnlocked;
    final showDownload = widget.isPremiumUser && !isLocked;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isLocked
                    ? colors.premium.withValues(alpha: 0.15)
                    : colors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: isLocked
                    ? Icon(Icons.lock_rounded,
                        size: 18, color: colors.premium)
                    : Text(
                        '${widget.chapter.chapterNumber}',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chapter.displayTitle,
                    style: TextStyle(
                      color: isLocked ? colors.onSurfaceDim : colors.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.visibility_outlined,
                          size: 13, color: colors.onSurfaceDim),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.chapter.viewCount}',
                        style: TextStyle(
                            color: colors.onSurfaceDim, fontSize: 11),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.favorite_outline,
                          size: 13, color: colors.onSurfaceDim),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.chapter.likeCount}',
                        style: TextStyle(
                            color: colors.onSurfaceDim, fontSize: 11),
                      ),
                      if (widget.chapter.publishedAt != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          _formatDate(widget.chapter.publishedAt!),
                          style: TextStyle(
                              color: colors.onSurfaceDim, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isLocked)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.premium.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.toll_rounded,
                        size: 13, color: colors.premium),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.chapter.coinCost}',
                      style: TextStyle(
                        color: colors.premium,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              if (showDownload) ...[
                const SizedBox(width: 8),
                _buildDownloadButton(colors),
              ],
              const SizedBox(width: 4),
              Icon(Icons.play_circle_outline_rounded,
                  color: colors.primary, size: 22),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(c) {
    if (_downloading) {
      return SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(
          value: _progress > 0 ? _progress : null,
          strokeWidth: 2,
          color: c.primary,
        ),
      );
    }
    if (_isDownloaded) {
      return GestureDetector(
        onTap: _showDownloadMenu,
        child: Icon(Icons.download_done_rounded,
            size: 20, color: AppColors.success),
      );
    }
    return GestureDetector(
      onTap: _download,
      child: Icon(Icons.download_outlined, size: 20, color: c.onSurfaceDim),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Bugün';
    if (diff.inDays == 1) return 'Dün';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return '${date.day}.${date.month}.${date.year}';
  }
}
