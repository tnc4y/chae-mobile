import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/errors/app_exceptions.dart';
import '../models/comment.dart';

class CommentService {
  final _client = Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  Future<Set<String>> fetchLikedCommentIds(Iterable<String> commentIds) async {
    final ids = commentIds.where((id) => id.isNotEmpty).toList();
    if (ids.isEmpty) return <String>{};

    try {
      final data = await _client
          .from('comment_likes')
          .select('comment_id')
          .eq('user_id', _userId)
          .inFilter('comment_id', ids);
      return (data as List)
          .map((entry) => entry['comment_id'] as String)
          .toSet();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<List<Comment>> fetchWebtoonComments(
    String webtoonId, {
    int page = 0,
  }) async {
    try {
      final data = await _client
          .from('comments')
          .select('''
            id, content, is_spoiler, is_pinned,
            like_count, reply_count, created_at, parent_id,
            user:profiles!comments_user_id_fkey(username, display_name, avatar_url)
          ''')
          .eq('webtoon_id', webtoonId)
          .eq('is_deleted', false)
          .isFilter('parent_id', null)
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false)
          .range(page * 20, page * 20 + 19);
      return (data as List).map((e) => Comment.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<List<Comment>> fetchChapterComments(
    String chapterId, {
    int page = 0,
  }) async {
    try {
      final data = await _client
          .from('comments')
          .select('''
            id, content, is_spoiler, is_pinned,
            like_count, reply_count, created_at, parent_id,
            user:profiles!comments_user_id_fkey(username, display_name, avatar_url)
          ''')
          .eq('chapter_id', chapterId)
          .eq('is_deleted', false)
          .isFilter('parent_id', null)
          .order('created_at', ascending: false)
          .range(page * 20, page * 20 + 19);
      return (data as List).map((e) => Comment.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<List<Comment>> fetchReplies(String commentId) async {
    try {
      final data = await _client
          .from('comments')
          .select('''
            id, content, is_spoiler, like_count, reply_count, created_at, parent_id,
            user:profiles!comments_user_id_fkey(username, display_name, avatar_url)
          ''')
          .eq('parent_id', commentId)
          .eq('is_deleted', false)
          .order('created_at');
      return (data as List).map((e) => Comment.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<void> postComment({
    required String webtoonId,
    required String content,
    bool isSpoiler = false,
    String? parentId,
    String? chapterId,
  }) async {
    try {
      await _client.from('comments').insert({
        'user_id': _userId,
        'webtoon_id': webtoonId,
        'content': content,
        'is_spoiler': isSpoiler,
        'parent_id': parentId,
        if (chapterId != null) 'chapter_id': chapterId,
      });
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _client
          .from('comments')
          .update({
            'is_deleted': true,
            'deleted_at': DateTime.now().toIso8601String(),
          })
          .eq('id', commentId)
          .eq('user_id', _userId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<void> likeComment(String commentId) async {
    try {
      await _client.from('comment_likes').insert({
        'user_id': _userId,
        'comment_id': commentId,
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') return;
      throw ServerException(e.message);
    }
  }

  Future<void> unlikeComment(String commentId) async {
    try {
      await _client
          .from('comment_likes')
          .delete()
          .eq('user_id', _userId)
          .eq('comment_id', commentId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<void> reportComment({
    required String commentId,
    required String reason,
    String? description,
  }) async {
    try {
      await _client.from('reports').insert({
        'reporter_id': _userId,
        'reason': reason,
        'description': description,
        'comment_id': commentId,
      });
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}
