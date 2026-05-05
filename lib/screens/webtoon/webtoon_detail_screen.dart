import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../models/comment.dart';
import '../../models/chapter.dart';
import '../../models/webtoon.dart';
import '../../services/chapter_service.dart';
import '../../services/comment_service.dart';
import '../../services/favorite_service.dart';
import '../../services/rating_service.dart';
import '../../services/webtoon_service.dart';
import 'widgets/chapter_list_item.dart';
import 'widgets/genre_chip.dart';

class WebtoonDetailScreen extends StatefulWidget {
  final String slug;

  const WebtoonDetailScreen({super.key, required this.slug});

  @override
  State<WebtoonDetailScreen> createState() => _WebtoonDetailScreenState();
}

class _WebtoonDetailScreenState extends State<WebtoonDetailScreen>
    with SingleTickerProviderStateMixin {
  final _webtoonService = WebtoonService();
  final _chapterService = ChapterService();
  final _commentService = CommentService();
  final _favoriteService = FavoriteService();
  final _ratingService = RatingService();
  final _commentController = TextEditingController();

  late final TabController _tabCtrl;

  Webtoon? _webtoon;
  List<Chapter> _chapters = [];
  List<Comment> _comments = [];
  bool _isFavorite = false;
  double? _myRating;
  bool _loading = true;
  bool _commentsLoading = true;
  bool _postingComment = false;
  bool _synopsisExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final webtoon = await _webtoonService.fetchBySlug(widget.slug);
      final chapters = await _chapterService.fetchChapters(webtoon.id);
      final comments = await _commentService.fetchWebtoonComments(webtoon.id);
      final isFav = await _favoriteService.isFavorite(webtoon.id);
      final myRating = await _ratingService.fetchMyRating(webtoon.id);

      if (mounted) {
        setState(() {
          _webtoon = webtoon;
          _chapters = chapters;
          _comments = comments;
          _isFavorite = isFav;
          _myRating = myRating;
          _commentsLoading = false;
        });
      }
      _webtoonService.incrementView(webtoon.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshComments() async {
    if (_webtoon == null) return;
    setState(() => _commentsLoading = true);
    try {
      final comments = await _commentService.fetchWebtoonComments(_webtoon!.id);
      if (mounted) {
        setState(() => _comments = comments);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _commentsLoading = false);
    }
  }

  Future<void> _postComment() async {
    if (_webtoon == null) return;

    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _postingComment = true);
    try {
      await _commentService.postComment(
        webtoonId: _webtoon!.id,
        content: content,
      );
      _commentController.clear();
      await _refreshComments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yorum eklendi.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _postingComment = false);
    }
  }

  Future<void> _toggleFavorite() async {
    if (_webtoon == null) return;
    try {
      if (_isFavorite) {
        await _favoriteService.remove(_webtoon!.id);
      } else {
        await _favoriteService.add(_webtoon!.id);
      }
      if (mounted) setState(() => _isFavorite = !_isFavorite);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _rate(double score) async {
    if (_webtoon == null) return;
    await _ratingService.rate(_webtoon!.id, score);
    if (mounted) setState(() => _myRating = score);
  }

  void _openChapter(Chapter chapter) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    if (chapter.isPremium) {
      _showPremiumDialog(chapter);
      return;
    }

    context.push(
      '/reader/${chapter.id}?webtoonId=${_webtoon?.id}&type=${_webtoon?.type}',
    );
  }

  void _showPremiumDialog(Chapter chapter) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        title: const Text('Premium Bölüm'),
        content: Text(
          '${chapter.displayTitle} bölümüne erişmek için '
          '${chapter.coinCost} coin harcamak ister misin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _chapterService.unlockWithCoins(
                  chapter.id,
                  chapter.coinCost,
                );
                if (mounted) {
                  context.push(
                    '/reader/${chapter.id}?webtoonId=${_webtoon?.id}&type=${_webtoon?.type}',
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.toll_rounded, size: 16),
                const SizedBox(width: 6),
                Text('${chapter.coinCost} Coin Harca'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_webtoon == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: const Center(child: Text('Webtoon bulunamadı')),
      );
    }

    final w = _webtoon!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          _buildSliverAppBar(w),
        ],
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildInfoTab(w),
                  _buildChaptersTab(),
                  _buildCommentsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(Webtoon w) => SliverAppBar(
        expandedHeight: 280,
        pinned: true,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isFavorite
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_outline_rounded,
                key: ValueKey(_isFavorite),
                color: _isFavorite ? AppColors.primary : AppColors.onSurface,
              ),
            ),
            onPressed: _toggleFavorite,
          ),
          const SizedBox(width: 4),
        ],
        flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: Stack(
            fit: StackFit.expand,
            children: [
              if (w.bannerUrl != null || w.coverUrl != null)
                CachedNetworkImage(
                  imageUrl: w.bannerUrl ?? w.coverUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      Container(color: AppColors.surfaceContainer),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.background.withValues(alpha: 0.9),
                      AppColors.background,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.3, 0.75, 1.0],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: w.coverUrl != null
                          ? CachedNetworkImage(
                              imageUrl: w.coverUrl!,
                              width: 90,
                              height: 130,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 90,
                              height: 130,
                              color: AppColors.surfaceContainer,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            w.title,
                            style: const TextStyle(
                              color: AppColors.onBackground,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          if (w.author != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              w.author!.name,
                              style: const TextStyle(
                                color: AppColors.onSurfaceDim,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          _buildStats(w),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildStats(Webtoon w) => Wrap(
        spacing: 12,
        children: [
          _StatItem(
              icon: Icons.star_rounded,
              value: w.avgRating.toStringAsFixed(1),
              color: AppColors.gold),
          _StatItem(
              icon: Icons.visibility_outlined,
              value: _formatCount(w.viewCount),
              color: AppColors.onSurfaceDim),
          _StatItem(
              icon: Icons.menu_book_outlined,
              value: '${w.chapterCount}',
              color: AppColors.onSurfaceDim),
        ],
      );

  Widget _buildTabBar() => Container(
        color: AppColors.surface,
        child: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceDim,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Bilgi'),
            Tab(text: 'Bölümler'),
            Tab(text: 'Yorumlar'),
          ],
        ),
      );

  Widget _buildInfoTab(Webtoon w) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (w.genres.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: w.genres.map((g) => GenreChip(genre: g)).toList(),
              ),
              const SizedBox(height: 20),
            ],
            if (w.synopsis != null && w.synopsis!.isNotEmpty) ...[
              const Text(
                'Özet',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () =>
                    setState(() => _synopsisExpanded = !_synopsisExpanded),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      w.synopsis!,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 14,
                        height: 1.6,
                      ),
                      maxLines: _synopsisExpanded ? null : 4,
                      overflow:
                          _synopsisExpanded ? null : TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _synopsisExpanded ? 'Daha az göster' : 'Devamını oku',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Text(
              'Puanın',
              style: TextStyle(
                color: AppColors.onBackground,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            RatingBar.builder(
              initialRating: _myRating ?? 0,
              minRating: 1,
              itemCount: 10,
              itemSize: 28,
              glowColor: AppColors.gold.withValues(alpha: 0.3),
              unratedColor: AppColors.outline,
              itemBuilder: (_, __) =>
                  const Icon(Icons.star_rounded, color: AppColors.gold),
              onRatingUpdate: _rate,
            ),
            if (_myRating != null) ...[
              const SizedBox(height: 6),
              Text(
                'Puanın: ${_myRating!.toStringAsFixed(0)}/10',
                style: const TextStyle(
                  color: AppColors.onSurfaceDim,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 24),
            _buildDetailsCard(w),
          ],
        ),
      );

  Widget _buildDetailsCard(Webtoon w) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _DetailRow(label: 'Durum', value: w.statusLabel),
            _DetailRow(label: 'Tür', value: w.typeLabel),
            if (w.releaseDay != null)
              _DetailRow(label: 'Yayın Günü', value: w.releaseDay!),
            if (w.artist != null)
              _DetailRow(label: 'Çizer', value: w.artist!.name),
            _DetailRow(
              label: 'Toplam Bölüm',
              value: '${w.chapterCount}',
            ),
          ],
        ),
      );

  Widget _buildChaptersTab() {
    if (_chapters.isEmpty) {
      return const Center(
        child: Text(
          'Henüz bölüm yok',
          style: TextStyle(color: AppColors.onSurfaceDim),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _chapters.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final chapter = _chapters[i];
        return ChapterListItem(
          chapter: chapter,
          isUnlocked: false,
          onTap: () => _openChapter(chapter),
        );
      },
    );
  }

  Widget _buildCommentsTab() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refreshComments,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCommentComposer(),
          const SizedBox(height: 16),
          if (_commentsLoading)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_comments.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'Henüz yorum yok',
                  style: TextStyle(color: AppColors.onSurfaceDim),
                ),
              ),
            )
          else
            ..._comments.map((comment) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CommentCard(comment: comment),
                )),
        ],
      ),
    );
  }

  Widget _buildCommentComposer() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yorum Yaz',
              style: TextStyle(
                color: AppColors.onBackground,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _commentController,
              maxLines: 4,
              minLines: 2,
              decoration: const InputDecoration(
                hintText: 'Bu webtoon hakkında düşüncen nedir?',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _postingComment ? null : _postComment,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: Text(_postingComment ? 'Gönderiliyor...' : 'Gönder'),
              ),
            ),
          ],
        ),
      );

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }
}

class _CommentCard extends StatelessWidget {
  final Comment comment;

  const _CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    final avatar = comment.user.avatarUrl;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            backgroundImage: avatar != null && avatar.isNotEmpty
                ? NetworkImage(avatar)
                : null,
            child: avatar == null || avatar.isEmpty
                ? Text(
                    comment.user.displayedName.isNotEmpty
                        ? comment.user.displayedName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.user.displayedName,
                        style: const TextStyle(
                          color: AppColors.onBackground,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(comment.createdAt),
                      style: const TextStyle(
                        color: AppColors.onSurfaceDim,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.content,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.favorite_outline,
                        size: 14, color: AppColors.onSurfaceDim),
                    const SizedBox(width: 4),
                    Text('${comment.likeCount}',
                        style: const TextStyle(
                            color: AppColors.onSurfaceDim, fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.reply_rounded,
                        size: 14, color: AppColors.onSurfaceDim),
                    const SizedBox(width: 4),
                    Text('${comment.replyCount}',
                        style: const TextStyle(
                            color: AppColors.onSurfaceDim, fontSize: 12)),
                    if (comment.isSpoiler) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Spoiler',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}dk';
    if (diff.inHours < 24) return '${diff.inHours}s';
    if (diff.inDays < 7) return '${diff.inDays}g';
    return '${date.day}.${date.month}.${date.year}';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _StatItem(
      {required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
              color: color, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.onSurfaceDim, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.onBackground,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
