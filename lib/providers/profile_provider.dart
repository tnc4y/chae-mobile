import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final _service = ProfileService();

  Profile? _profile;
  bool _loading = false;
  String? _error;

  Profile? get profile => _profile;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _service.fetchMyProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      await _service.updateProfile(
        displayName: displayName,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      await fetchProfile();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> syncPremiumRole(bool isPremium) async {
    try {
      await _service.syncPremiumRole(isPremium);
      await fetchProfile();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _profile = null;
    _error = null;
    notifyListeners();
  }
}
