import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _keyIncognito = 'incognito_mode';
  static const _keyMatureContent = 'mature_content';
  static const _keyMatureVerified = 'mature_verified';

  bool _incognitoMode = false;
  bool _matureContent = false;
  bool _matureVerified = false;

  bool get incognitoMode => _incognitoMode;
  bool get matureContent => _matureContent;
  bool get matureVerified => _matureVerified;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _incognitoMode = prefs.getBool(_keyIncognito) ?? false;
    _matureContent = prefs.getBool(_keyMatureContent) ?? false;
    _matureVerified = prefs.getBool(_keyMatureVerified) ?? false;
    notifyListeners();
  }

  Future<void> setIncognitoMode(bool value) async {
    _incognitoMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIncognito, value);
  }

  Future<void> setMatureContent(bool value, {bool verified = false}) async {
    if (value && !_matureVerified && !verified) return;
    _matureContent = value;
    if (verified) _matureVerified = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMatureContent, value);
    if (verified) await prefs.setBool(_keyMatureVerified, true);
  }
}
