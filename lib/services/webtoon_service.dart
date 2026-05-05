import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/errors/app_exceptions.dart';
import '../models/webtoon.dart';

class WebtoonService {
  final _client = Supabase.instance.client;

  static const _listSelect = '''
    id, title, slug, cover_url, status, type,
    avg_rating, rating_count, chapter_count,
    view_count, is_premium, is_featured, release_day,
    webtoon_genres(genre:genres(id, name, color))
  ''';

  static const _detailSelect = '''
    *,
    author:authors!webtoons_author_id_fkey(id, name, avatar_url),
    artist:authors!webtoons_artist_id_fkey(id, name),
    webtoon_genres(genre:genres(id, name, color))
  ''';

  Future<List<Webtoon>> fetchList({
    int page = 0,
    bool showMature = false,
  }) async {
    try {
      final from = page * 20;
      var query =
          _client.from('webtoons').select('''
            id, title, slug, cover_url, status, type,
            avg_rating, rating_count, chapter_count,
            view_count, is_premium, is_featured, release_day,
            webtoon_genres!inner(genre_id, genre:genres(id, name, color))
          ''').eq('is_published', true);
       if (!showMature) query = query.neq('age_rating', 'mature');
      final data = await query
          .order('updated_at', ascending: false)
          .range(from, from + 19);
      return (data as List).map((e) => Webtoon.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<Webtoon>> fetchFeatured() async {
    try {
      final data = await _client
          .from('webtoons')
          .select(
              'id, title, slug, cover_url, banner_url, avg_rating, status, type, webtoon_genres(genre:genres(id, name, color))')
          .eq('is_published', true)
          .eq('is_featured', true)
          .limit(10);
      return (data as List).map((e) => Webtoon.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<Webtoon>> fetchByGenre(String genreSlug, {int page = 0}) async {
    try {
      final genre = await _client
          .from('genres')
          .select('id')
          .eq('slug', genreSlug)
          .single();

      final from = page * 20;
      final data = await _client
          .from('webtoons')
          .select('$_listSelect, webtoon_genres!inner(genre_id)')
          .eq('is_published', true)
          .eq('webtoon_genres.genre_id', genre['id'])
          .order('view_count', ascending: false)
          .range(from, from + 19);
      return (data as List).map((e) => Webtoon.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<Webtoon>> search(String query, {bool showMature = false}) async {
    try {
      var q = _client
          .from('webtoons')
          .select(
              'id, title, slug, cover_url, status, type, avg_rating, webtoon_genres(genre:genres(id, name, color))')
          .eq('is_published', true)
          .ilike('title', '%$query%');
            if (!showMature) q = q.neq('age_rating', 'mature');
      final data = await q.limit(20);
      return (data as List).map((e) => Webtoon.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Webtoon> fetchBySlug(String slug) async {
    try {
      final data = await _client
          .from('webtoons')
          .select(_detailSelect)
          .eq('slug', slug)
          .single();
      return Webtoon.fromJson(data);
    } on PostgrestException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> incrementView(String webtoonId) async {
    try {
      await _client.rpc('increment_view', params: {
        'table_name': 'webtoons',
        'row_id': webtoonId,
      });
    } catch (_) {}
  }

  Future<List<Webtoon>> fetchNextPage(String lastUpdatedAt) async {
    try {
      final data = await _client
          .from('webtoons')
          .select(_listSelect)
          .eq('is_published', true)
          .lt('updated_at', lastUpdatedAt)
          .order('updated_at', ascending: false)
          .limit(20);
      return (data as List).map((e) => Webtoon.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw _mapError(e);
    }
  }

  AppException _mapError(PostgrestException e) => switch (e.code) {
        'PGRST116' => const NotFoundException('Webtoon bulunamadı'),
        '42501' =>
          const UnauthorizedException('Bu içeriğe erişim yetkiniz yok'),
        _ => ServerException(e.message),
      };
}
