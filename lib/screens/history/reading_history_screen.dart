import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/context_colors.dart';
import '../../models/reading_history_entry.dart';
import '../../services/chapter_service.dart';

class ReadingHistoryScreen extends StatefulWidget {
  const ReadingHistoryScreen({super.key});

  @override
  State<ReadingHistoryScreen> createState() => _ReadingHistoryScreenState();
}

class _ReadingHistoryScreenState extends State<ReadingHistoryScreen> {
  final _chapterService = ChapterService();
  List<ReadingHistoryEntry> _history = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final history = await _chapterService.fetchReadingHistory();
      if (mounted) setState(() => _history = history);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openChapter(ReadingHistoryEntry entry) {
    context.push(
      '/reader/${entry.chapterId}'
      '?webtoonId=${entry.webtoonId}&type=${entry.webtoonType}',
    );
  }

  void _openWebtoon(ReadingHistoryEntry entry) {
    context.push('/home/webtoon/${entry.webtoonSlug}');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Okuma Geçmişi'),
        backgroundColor: colors.background,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : _error != null
              ? _buildError()
              : _history.isEmpty
                  ? _buildEmpty(colors)
                  : RefreshIndicator(
                      color: colors.primary,
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _history.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) =>
                            _HistoryCard(
                          entry: _history[i],
                          onTapChapter: () => _openChapter(_history[i]),
                          onTapWebtoon: () => _openWebtoon(_history[i]),
                        ),
                      ),
                    ),
    );
  }

  Widget _buildEmpty(c) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 64, color: c.onSurfaceDim),
            const SizedBox(height: 16),
            Text(
              'Henüz okuma geçmişin yok',
              style: TextStyle(color: c.onSurfaceDim, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Bir bölüm okuduktan sonra burada görünecek.',
              style: TextStyle(color: c.onSurfaceDim, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.colors.onSurface)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _load, child: const Text('Tekrar Dene')),
            ],
          ),
        ),
      );
}

class _HistoryCard extends StatelessWidget {
  final ReadingHistoryEntry entry;
  final VoidCallback onTapChapter;
  final VoidCallback onTapWebtoon;

  const _HistoryCard({
    required this.entry,
    required this.onTapChapter,
    required this.onTapWebtoon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress = entry.progress.clamp(0.0, 100.0);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: onTapChapter,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              GestureDetector(
                onTap: onTapWebtoon,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: entry.webtoonCoverUrl != null
                      ? CachedNetworkImage(
                          imageUrl: entry.webtoonCoverUrl!,
                          width: 60,
                          height: 84,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _coverPlaceholder(colors),
                        )
                      : _coverPlaceholder(colors),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: onTapWebtoon,
                      child: Text(
                        entry.webtoonTitle,
                        style: TextStyle(
                          color: colors.onBackground,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.chapterDisplayTitle,
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.menu_book_rounded,
                            size: 13, color: colors.onSurfaceDim),
                        const SizedBox(width: 4),
                        Text(
                          entry.pageCount > 0
                              ? '${entry.lastPage} / ${entry.pageCount} sayfa'
                              : '${entry.lastPage}. sayfa',
                          style: TextStyle(
                              color: colors.onSurfaceDim, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 4,
                        backgroundColor:
                            colors.primary.withValues(alpha: 0.15),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colors.primary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '%${progress.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatDate(entry.lastReadAt),
                          style: TextStyle(
                              color: colors.onSurfaceDim, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.play_circle_outline_rounded,
                  color: colors.primary, size: 26),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coverPlaceholder(c) => Container(
        width: 60,
        height: 84,
        decoration: BoxDecoration(
          color: c.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.image_not_supported_outlined,
            color: c.onSurfaceDim, size: 24),
      );

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    if (diff.inDays == 1) return 'Dün';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return '${date.day}.${date.month}.${date.year}';
  }
}
