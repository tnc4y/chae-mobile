import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/errors/app_exceptions.dart';

class RatingService {
  final _client = Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  Future<double?> fetchMyRating(String webtoonId) async {
    try {
      final data = await _client
          .from('ratings')
          .select('score')
          .eq('user_id', _userId)
          .eq('webtoon_id', webtoonId)
          .maybeSingle();
      return (data?['score'] as num?)?.toDouble();
    } catch (_) {
      return null;
    }
  }

  Future<void> rate(String webtoonId, double score) async {
    try {
      await _client.from('ratings').upsert(
        {
          'user_id': _userId,
          'webtoon_id': webtoonId,
          'score': score.toInt(),
        },
        onConflict: 'user_id,webtoon_id',
      );
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}
