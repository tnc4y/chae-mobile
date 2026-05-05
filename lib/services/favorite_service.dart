import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/errors/app_exceptions.dart';
import '../models/webtoon.dart';

class FavoriteService {
  final _client = Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  Future<bool> isFavorite(String webtoonId) async {
    try {
      final data = await _client
          .from('favorites')
          .select('id')
          .eq('user_id', _userId)
          .eq('webtoon_id', webtoonId)
          .maybeSingle();
      return data != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> add(String webtoonId) async {
    try {
      await _client.from('favorites').insert({
        'user_id': _userId,
        'webtoon_id': webtoonId,
        'notify_new_chapter': true,
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505')
        throw const AlreadyExistsException('Zaten favorilere ekli');
      throw ServerException(e.message);
    }
  }

  Future<void> remove(String webtoonId) async {
    try {
      await _client
          .from('favorites')
          .delete()
          .eq('user_id', _userId)
          .eq('webtoon_id', webtoonId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<List<Webtoon>> fetchFavorites() async {
    try {
      final data = await _client.from('favorites').select('''
            id, created_at, notify_new_chapter,
            webtoon:webtoons(id, title, slug, cover_url, status, chapter_count, avg_rating,
              webtoon_genres(genre:genres(id, name, color)))
          ''').eq('user_id', _userId).order('created_at', ascending: false);

      return (data as List)
          .map((e) {
            final webtoonData = e['webtoon'];
            if (webtoonData is Map<String, dynamic>) {
              return Webtoon.fromJson(webtoonData);
            }
            return null;
          })
          .whereType<Webtoon>()
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}
