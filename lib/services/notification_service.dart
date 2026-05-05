import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/errors/app_exceptions.dart';
import '../models/notification_model.dart';

class NotificationService {
  final _client = Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  Future<int> fetchUnreadCount() async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', _userId)
          .eq('is_read', false)
          .count(CountOption.exact);
      return response.count;
    } catch (_) {
      return 0;
    }
  }

  Future<List<NotificationModel>> fetchAll() async {
    try {
      final data = await _client
          .from('notifications')
          .select('id, type, title, message, data, is_read, created_at')
          .eq('user_id', _userId)
          .order('created_at', ascending: false)
          .limit(50);
      return (data as List).map((e) => NotificationModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<void> markRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', _userId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<void> markAllRead() async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', _userId)
          .eq('is_read', false);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}
