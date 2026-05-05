import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/context_colors.dart';
import '../../../models/comment.dart';
import '../../../services/comment_service.dart';

class ReaderCommentsSheet extends StatefulWidget {
  final String chapterId;
  final String webtoonId;

  const ReaderCommentsSheet({
    super.key,
    required this.chapterId,
    required this.webtoonId,
  });

  @override
  State<ReaderCommentsSheet> createState() => _ReaderCommentsSheetState();
}

class _ReaderCommentsSheetState extends State<ReaderCommentsSheet> {
  final _service = CommentService();
  final _ctrl = TextEditingController();

  List<Comment> _comments = [];
  bool _loading = true;
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final comments =
          await _service.fetchChapterComments(widget.chapterId);
      final likedIds = await _service
          .fetchLikedCommentIds(comments.map((c) => c.id));
      if (mounted) {
        setState(() {
          _comments = comments
              .map((c) => c.copyWith(isLiked: likedIds.contains(c.id)))
              .toList();
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _post() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _posting = true);
    try {
      await _service.postComment(
        webtoonId: widget.webtoonId,
        chapterId: widget.chapterId,
        content: text,
      );
      _ctrl.clear();
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  Future<void> _toggleLike(Comment comment) async {
    try {
      if (comment.isLiked) {
        await _service.unlikeComment(comment.id);
      } else {
        await _service.likeComment(comment.id);
      }
      if (!mounted) return;
      setState(() {
        _comments = _comments.map((c) {
          if (c.id != comment.id) return c;
          final liked = !c.isLiked;
          return c.copyWith(
            isLiked: liked,
            likeCount: liked ? c.likeCount + 1 : (c.likeCount - 1).clamp(0, 1 << 30),
          );
        }).toList();
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Bölüm Yorumları',
                    style: TextStyle(
                      color: colors.onBackground,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (!_loading)
                    Text(
                      '${_comments.length}',
                      style: TextStyle(
                          color: colors.onSurfaceDim, fontSize: 14),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      style: TextStyle(color: colors.onBackground),
                      decoration: InputDecoration(
                        hintText: 'Yorum yaz...',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        filled: true,
                        fillColor: colors.surfaceContainer,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _posting ? null : _post,
                    icon: _posting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.primary,
                            ),
                          )
                        : Icon(Icons.send_rounded, color: colors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: colors.outlineVariant),
            Expanded(
              child: _loading
                  ? Center(
                      child:
                          CircularProgressIndicator(color: colors.primary))
                  : _comments.isEmpty
                      ? Center(
                          child: Text(
                            'Henüz yorum yok',
                            style:
                                TextStyle(color: colors.onSurfaceDim),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.all(16),
                          itemCount: _comments.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => _CommentRow(
                            comment: _comments[i],
                            onLike: () => _toggleLike(_comments[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  final Comment comment;
  final VoidCallback onLike;

  const _CommentRow({required this.comment, required this.onLike});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final avatar = comment.user.avatarUrl;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: colors.primary.withValues(alpha: 0.15),
          backgroundImage: avatar?.isNotEmpty == true
              ? NetworkImage(avatar!)
              : null,
          child: avatar?.isNotEmpty != true
              ? Text(
                  comment.user.displayedName.isNotEmpty
                      ? comment.user.displayedName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                      color: colors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.user.displayedName,
                    style: TextStyle(
                      color: colors.onBackground,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(comment.createdAt),
                    style:
                        TextStyle(color: colors.onSurfaceDim, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              if (comment.isSpoiler)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Spoiler',
                    style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                  ),
                )
              else
                Text(
                  comment.content,
                  style: TextStyle(
                      color: colors.onSurface, fontSize: 13, height: 1.4),
                ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onLike,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      comment.isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline,
                      size: 15,
                      color: comment.isLiked
                          ? AppColors.error
                          : colors.onSurfaceDim,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${comment.likeCount}',
                      style: TextStyle(
                          color: colors.onSurfaceDim, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}dk';
    if (diff.inHours < 24) return '${diff.inHours}s';
    if (diff.inDays < 7) return '${diff.inDays}g';
    return '${date.day}.${date.month}.${date.year}';
  }
}
