import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/env.dart';

class RevenueCatService {
  RevenueCatService._();

  static final RevenueCatService instance = RevenueCatService._();

  bool _isConfigured = false;

  bool get isConfigured => _isConfigured;

  Future<void> initialize({String? appUserId}) async {
    if (kIsWeb) return;

    final apiKey = _apiKeyForPlatform;
    if (apiKey.isEmpty) {
      _isConfigured = false;
      return;
    }

    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);

    final config = PurchasesConfiguration(apiKey);
    if (appUserId != null && appUserId.isNotEmpty) {
      config.appUserID = appUserId;
    }

    await Purchases.configure(config);
    _isConfigured = true;
  }

  Future<void> login(String appUserId) async {
    if (!_isConfigured || appUserId.isEmpty) return;
    await Purchases.logIn(appUserId);
  }

  Future<void> logout() async {
    if (!_isConfigured) return;
    await Purchases.logOut();
  }

  Future<Offerings> getOfferings() async {
    _ensureConfigured();
    return Purchases.getOfferings();
  }

  Future<CustomerInfo> purchasePackage(Package package) async {
    _ensureConfigured();
    return Purchases.purchasePackage(package);
  }

  Future<CustomerInfo> restorePurchases() async {
    _ensureConfigured();
    return Purchases.restorePurchases();
  }

  Future<bool> hasPremiumAccess() async {
    _ensureConfigured();
    final customerInfo = await Purchases.getCustomerInfo();
    return hasPremiumEntitlement(customerInfo);
  }

  bool hasPremiumEntitlement(CustomerInfo customerInfo) {
    return customerInfo.entitlements.active.containsKey(
      Env.revenueCatPremiumEntitlementId,
    );
  }

  void _ensureConfigured() {
    if (_isConfigured) return;
    throw StateError(
      'RevenueCat yapılandırılmadı. REVENUECAT_* dart-define değerlerini ekleyin.',
    );
  }

  String get _apiKeyForPlatform {
    if (Env.revenueCatApiKey.isNotEmpty) return Env.revenueCatApiKey;
    if (Platform.isAndroid) return Env.revenueCatAndroidApiKey;
    if (Platform.isIOS) return Env.revenueCatIosApiKey;
    return '';
  }
}
