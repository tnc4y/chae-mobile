import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/errors/app_exceptions.dart';
import '../config/app_constants.dart';
import '../models/chapter.dart';
import '../models/chapter_page.dart';
import '../models/reading_history_entry.dart';

class ChapterService {
  final _client = Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  Future<List<Chapter>> fetchChapters(String webtoonId) async {
    try {
      final data = await _client
          .from('chapters')
          .select(
            'id, webtoon_id, chapter_number, title, is_premium, is_published, '
            'view_count, like_count, comment_count, page_count, '
            'coin_cost, thumbnail_url, published_at',
          )
          .eq('webtoon_id', webtoonId)
          .eq('is_published', true)
          .order('chapter_number', ascending: false);
      return (data as List).map((e) => Chapter.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<ChapterPage>> fetchPages(String chapterId) async {
    try {
      final chapter = await _client
          .from('chapters')
          .select('id, is_premium, coin_cost, webtoon_id')
          .eq('id', chapterId)
          .single();

      if (chapter['is_premium'] == true) {
        final profile = await _client
            .from('profiles')
            .select('role')
            .eq('id', _userId)
            .single();

        final hasAccess =
            AppConstants.premiumRoles.contains(profile['role'] as String?);
        if (!hasAccess) {
          final unlock = await _client
              .from('chapter_unlocks')
              .select('id')
              .eq('user_id', _userId)
              .eq('chapter_id', chapterId)
              .maybeSingle();
          if (unlock == null) {
            throw const UnauthorizedException('Bu bölüm premium');
          }
        }
      }

      final pages = await _client
          .from('chapter_pages')
          .select('id, page_number, image_url, width, height')
          .eq('chapter_id', chapterId)
          .order('page_number', ascending: true);
      return (pages as List).map((e) => ChapterPage.fromJson(e)).toList();
    } on AppException {
      rethrow;
    } on PostgrestException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> saveReadingHistory({
    required String webtoonId,
    required String chapterId,
    required int currentPage,
    required int totalPages,
  }) async {
    try {
      final progress = totalPages > 0
          ? (currentPage / totalPages * 100).toStringAsFixed(1)
          : '0';
      await _client.from('reading_history').upsert(
        {
          'user_id': _userId,
          'webtoon_id': webtoonId,
          'chapter_id': chapterId,
          'last_page': currentPage,
          'progress': progress,
          'last_read_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,chapter_id',
      );
    } catch (_) {}
  }

  Future<void> unlockWithCoins(String chapterId, int coinCost) async {
    try {
      final profile = await _client
          .from('profiles')
          .select('coins')
          .eq('id', _userId)
          .single();

      final coins = (profile['coins'] as num?)?.toInt() ?? 0;
      if (coins < coinCost) throw const InsufficientCoinsException();

      await _client.from('chapter_unlocks').insert({
        'user_id': _userId,
        'chapter_id': chapterId,
        'coins_spent': coinCost,
      });

      final newBalance = coins - coinCost;
      await _client
          .from('profiles')
          .update({'coins': newBalance})
          .eq('id', _userId);

      await _client.from('coin_transactions').insert({
        'user_id': _userId,
        'amount': -coinCost,
        'balance': newBalance,
        'reason': 'chapter_unlock',
        'data': {'chapter_id': chapterId},
      });
    } on AppException {
      rethrow;
    } on PostgrestException catch (e) {
      throw _mapError(e);
    }
  }

  Future<bool> isLiked(String chapterId) async {
    try {
      final data = await _client
          .from('chapter_likes')
          .select('id')
          .eq('user_id', _userId)
          .eq('chapter_id', chapterId)
          .maybeSingle();
      return data != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> incrementChapterView(String chapterId) async {
    try {
      await _client.rpc('increment_view', params: {
        'table_name': 'chapters',
        'row_id': chapterId,
      });
    } catch (_) {}
  }

  Future<List<ReadingHistoryEntry>> fetchReadingHistory() async {
    try {
      final data = await _client
          .from('reading_history')
          .select(
            'webtoon_id, chapter_id, last_page, progress, last_read_at, '
            'webtoon:webtoons(title, cover_url, slug, type), '
            'chapter:chapters(chapter_number, title, page_count)',
          )
          .eq('user_id', _userId)
          .order('last_read_at', ascending: false)
          .limit(50);
      return (data as List)
          .map((e) => ReadingHistoryEntry.fromJson(e))
          .toList();
    } on PostgrestException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> toggleLike(String chapterId, bool currentlyLiked) async {
    try {
      if (currentlyLiked) {
        await _client
            .from('chapter_likes')
            .delete()
            .eq('user_id', _userId)
            .eq('chapter_id', chapterId);
      } else {
        await _client.from('chapter_likes').insert({
          'user_id': _userId,
          'chapter_id': chapterId,
        });
      }
    } on PostgrestException catch (e) {
      throw _mapError(e);
    }
  }

  AppException _mapError(PostgrestException e) => switch (e.code) {
    'PGRST116' => const NotFoundException('Bölüm bulunamadı'),
    '42501' => const UnauthorizedException('Bu içeriğe erişim yetkiniz yok'),
    '23505' => const AlreadyExistsException('Zaten mevcut'),
    _ => ServerException(e.message),
  };
}
