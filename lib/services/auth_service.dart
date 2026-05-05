import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/errors/app_exceptions.dart';

class AuthService {
  final _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
      );
      if (res.user == null) {
        throw ServerException(res.toString());
      }
      return res.user;
    } on AuthException catch (e) {
      throw UnauthorizedException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user == null) {
        throw UnauthorizedException('Giriş yapılamadı');
      }
      return res.user;
    } on AuthException catch (e) {
      throw UnauthorizedException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw UnauthorizedException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
