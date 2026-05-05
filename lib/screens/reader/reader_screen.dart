import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/context_colors.dart';
import '../../models/chapter_page.dart';
import '../../providers/settings_provider.dart';
import '../../services/chapter_service.dart';
import 'widgets/reader_comments_sheet.dart';

class ReaderScreen extends StatefulWidget {
  final String chapterId;
  final String webtoonId;
  final String webtoonType;
  final bool isLocal;

  const ReaderScreen({
    super.key,
    required this.chapterId,
    required this.webtoonId,
    required this.webtoonType,
    this.isLocal = false,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final _chapterService = ChapterService();
  final _scrollCtrl = ScrollController();
  final _pageCtrl = PageController();

  List<ChapterPage> _pages = [];
  bool _loading = true;
  bool _uiVisible = true;
  int _currentPage = 0;
  String? _error;

  bool get _isManga => widget.webtoonType == AppConstants.typeManga;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _load();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _scrollCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_pages.isEmpty || _isManga) return;
    final total = _scrollCtrl.position.maxScrollExtent;
    if (total > 0) {
      final progress = _scrollCtrl.offset / total;
      final page =
          (progress * _pages.length).floor().clamp(0, _pages.length - 1);
      if (page != _currentPage) {
        setState(() => _currentPage = page);
        _saveProgress(page);
      }
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pages = await _chapterService.fetchPages(widget.chapterId);
      if (mounted) setState(() => _pages = pages);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _saveProgress(int page) {
    final incognito =
        context.read<SettingsProvider>().incognitoMode;
    if (incognito) return;

    _chapterService.saveReadingHistory(
      webtoonId: widget.webtoonId,
      chapterId: widget.chapterId,
      currentPage: page + 1,
      totalPages: _pages.length,
    );
  }

  void _toggleUI() => setState(() => _uiVisible = !_uiVisible);

  void _openComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReaderCommentsSheet(
        chapterId: widget.chapterId,
        webtoonId: widget.webtoonId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final incognito = context.watch<SettingsProvider>().incognitoMode;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleUI,
        child: Stack(
          children: [
            if (_loading)
              Center(
                  child: CircularProgressIndicator(color: colors.primary))
            else if (_error != null)
              _buildError()
            else
              _isManga ? _buildMangaReader() : _buildWebtoonReader(),
            _buildTopBar(incognito),
            _buildBottomBar(colors),
          ],
        ),
      ),
      floatingActionButton: AnimatedSlide(
        offset: _uiVisible ? Offset.zero : const Offset(0, 2),
        duration: const Duration(milliseconds: 250),
        child: AnimatedOpacity(
          opacity: _uiVisible ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton.small(
            onPressed: _openComments,
            backgroundColor: colors.surfaceContainer,
            child: Icon(Icons.chat_bubble_outline_rounded,
                color: colors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildWebtoonReader() => ListView.builder(
        controller: _scrollCtrl,
        itemCount: _pages.length,
        itemBuilder: (_, i) => _buildPageImage(_pages[i]),
      );

  Widget _buildPageImage(ChapterPage page) {
    final isLocal = page.imageUrl.startsWith('/');
    if (isLocal) {
      return Image.file(
        File(page.imageUrl),
        fit: BoxFit.fitWidth,
        width: double.infinity,
        errorBuilder: (_, __, ___) => AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            color: const Color(0xFF1A1A1A),
            child: const Icon(Icons.broken_image_outlined,
                color: Colors.white24, size: 48),
          ),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: page.imageUrl,
      fit: BoxFit.fitWidth,
      width: double.infinity,
      placeholder: (_, __) => AspectRatio(
        aspectRatio: page.aspectRatio,
        child: Shimmer.fromColors(
          baseColor: const Color(0xFF1A1A1A),
          highlightColor: const Color(0xFF2A2A2A),
          child: Container(color: const Color(0xFF1A1A1A)),
        ),
      ),
      errorWidget: (_, __, ___) => AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          color: const Color(0xFF1A1A1A),
          child: const Icon(Icons.broken_image_outlined,
              color: Colors.white24, size: 48),
        ),
      ),
    );
  }

  Widget _buildMangaReader() => PageView.builder(
        controller: _pageCtrl,
        reverse: true,
        itemCount: (_pages.length / 2).ceil(),
        onPageChanged: (i) {
          setState(() => _currentPage = i * 2);
          _saveProgress(i * 2);
        },
        itemBuilder: (_, spreadIndex) {
          final rightIdx = spreadIndex * 2;
          final leftIdx = spreadIndex * 2 + 1;
          final right = _pages[rightIdx];
          final left =
              leftIdx < _pages.length ? _pages[leftIdx] : null;

          return Row(
            children: [
              Expanded(child: _buildSpreadImage(right)),
              if (left != null) Expanded(child: _buildSpreadImage(left)),
            ],
          );
        },
      );

  Widget _buildSpreadImage(ChapterPage page) {
    if (page.imageUrl.startsWith('/')) {
      return Image.file(File(page.imageUrl), fit: BoxFit.contain);
    }
    return CachedNetworkImage(
      imageUrl: page.imageUrl,
      fit: BoxFit.contain,
      placeholder: (_, __) => Container(color: Colors.black),
      errorWidget: (_, __, ___) => Container(color: Colors.black),
    );
  }

  Widget _buildTopBar(bool incognito) => AnimatedSlide(
        offset: _uiVisible ? Offset.zero : const Offset(0, -1),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.8),
                Colors.transparent
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  if (incognito) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility_off_rounded,
                              size: 12, color: Colors.white70),
                          SizedBox(width: 4),
                          Text(
                            'Gizli',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (_pages.isNotEmpty)
                    Text(
                      '${_currentPage + 1} / ${_pages.length}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildBottomBar(c) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: AnimatedSlide(
          offset: _uiVisible ? Offset.zero : const Offset(0, 1),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _pages.isNotEmpty
                    ? SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 16),
                          activeTrackColor: c.primary,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: c.primary,
                        ),
                        child: Slider(
                          value: _currentPage.toDouble(),
                          min: 0,
                          max: (_pages.length - 1).toDouble(),
                          onChanged: (val) {
                            final page = val.toInt();
                            setState(() => _currentPage = page);
                            if (_isManga) {
                              _pageCtrl.jumpToPage(page ~/ 2);
                            } else {
                              final itemHeight =
                                  MediaQuery.of(context).size.width *
                                      (1 / _pages[page].aspectRatio);
                              _scrollCtrl.jumpTo(itemHeight * page);
                            }
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.error, size: 56),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: _load, child: const Text('Tekrar Dene')),
            ],
          ),
        ),
      );
}
