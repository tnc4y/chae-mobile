import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/favorite_service.dart';
import '../services/revenuecat_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();
  final _favoriteService = FavoriteService();

  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get loading => _loading;
  String? get error => _error;

  AuthProvider() {
    _user = _service.currentUser;

    final currentUser = _user;
    if (currentUser != null) {
      RevenueCatService.instance.login(currentUser.id);
    }

    _service.authStateChanges.listen((state) {
      _user = state.session?.user;

      final signedInUser = _user;
      if (signedInUser != null) {
        RevenueCatService.instance.login(signedInUser.id);
      } else {
        RevenueCatService.instance.logout();
      }

      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _service.signIn(email: email, password: password);
      _user = user;
      return user != null;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _service.signUp(email: email, password: password);
      _user = user;
      return user != null;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    _user = null;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.resetPassword(email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
