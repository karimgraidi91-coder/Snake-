import 'package:flutter/material.dart';
import 'admob_ads_service.dart';
import 'yandex_ads_service.dart';

/// Base Ad Service - Abstract class for ad implementations
abstract class BaseAdService {
  Future<void> initialize();
  void showBannerAd(BuildContext context);
  void showInterstitialAd();
  void showRewardedAd();
  void dispose();
}

/// No Ads Implementation - Used in Debug build
class NoAdService extends BaseAdService {
  static final NoAdService _instance = NoAdService._internal();

  factory NoAdService() {
    return _instance;
  }

  NoAdService._internal();

  @override
  Future<void> initialize() async {
    print('✓ No Ads Service Initialized (Debug Build)');
  }

  @override
  void showBannerAd(BuildContext context) {
    print('Banner ad not shown (Debug Build)');
  }

  @override
  void showInterstitialAd() {
    print('Interstitial ad not shown (Debug Build)');
  }

  @override
  void showRewardedAd() {
    print('Rewarded ad not shown (Debug Build)');
  }

  @override
  void dispose() {}
}

/// Singleton Pattern for Ad Service
class AdService {
  static final AdService _instance = AdService._internal();
  BaseAdService _adService = NoAdService();

  factory AdService() {
    return _instance;
  }

  AdService._internal();

  static AdService get instance => _instance;

  /// Initialize with the appropriate ad service
  /// This will be overridden in platform-specific implementations
  Future<void> initialize() async {
    // Select ad provider via compile-time define AD_PROVIDER:
    // Use --dart-define=AD_PROVIDER=admob or yandex
    const provider =
        String.fromEnvironment('AD_PROVIDER', defaultValue: 'none');
    if (provider == 'yandex') {
      _adService = YandexAdService();
    } else if (provider == 'admob') {
      _adService = AdMobAdService();
    } else {
      _adService = NoAdService();
    }
    await _adService.initialize();
  }

  /// Set custom ad service
  void setAdService(BaseAdService service) {
    _adService = service;
  }

  void showBannerAd(BuildContext context) {
    _adService.showBannerAd(context);
  }

  void showInterstitialAd() {
    _adService.showInterstitialAd();
  }

  void showRewardedAd() {
    _adService.showRewardedAd();
  }

  void dispose() {
    _adService.dispose();
  }
}
