import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/errors/app_exceptions.dart';
import '../models/profile.dart';

class ProfileService {
  final _client = Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  Future<Profile> fetchMyProfile() async {
    try {
      final data = await _client
          .from('profiles')
          .select('id, username, display_name, avatar_url, bio, role, coins')
          .eq('id', _userId)
          .single();
      return Profile.fromJson(data);
    } on PostgrestException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _client.from('profiles').update(updates).eq('id', _userId);
    } on PostgrestException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> syncPremiumRole(bool isPremium) async {
    try {
      await _client.rpc(
        'sync_revenuecat_premium_role',
        params: {'is_premium': isPremium},
      );
    } on PostgrestException catch (e) {
      throw _mapError(e);
    }
  }

  AppException _mapError(PostgrestException e) {
    return switch (e.code) {
      'PGRST116' => const NotFoundException('Profil bulunamadı'),
      '42501' => const UnauthorizedException('Yetki yok'),
      _ => ServerException(e.message),
    };
  }
}
