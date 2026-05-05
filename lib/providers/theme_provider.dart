import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_themes.dart';
import '../services/revenuecat_service.dart';

class ThemeProvider extends ChangeNotifier {
  static const _key = 'selected_theme_id';

  AppThemePreset _current = AppThemes.defaultDark;
  bool _premiumUnlocked = false;

  AppThemePreset get current => _current;
  bool get premiumUnlocked => _premiumUnlocked;

  Future<void> initialize() async {
    await _loadPremiumStatus();
    await _loadSavedTheme();
  }

  Future<void> _loadPremiumStatus() async {
    try {
      _premiumUnlocked = await RevenueCatService.instance.hasPremiumAccess();
    } catch (_) {
      _premiumUnlocked = false;
    }
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_key);
    if (savedId == null) return;

    final preset = AppThemes.findById(savedId);
    if (preset.isPremium && !_premiumUnlocked) return;
    _current = preset;
  }

  Future<bool> setTheme(AppThemePreset preset) async {
    if (preset.isPremium && !_premiumUnlocked) return false;

    _current = preset;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, preset.id);
    return true;
  }

  Future<void> refreshPremiumStatus() async {
    await _loadPremiumStatus();
    if (_current.isPremium && !_premiumUnlocked) {
      _current = AppThemes.defaultDark;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    }
    notifyListeners();
  }
}
