# Snake Battle - Build Guide

## Three Different Versions

This project is set up to build three different versions of Snake Battle with different ad configurations.

---

## Version 1: Debug APK (No Ads) - Testing Build

**Purpose:** For testing on your device
**No Ads:** ✓ Pure game code
**Target:** ARM64 Debug Build

### Build Command:
```bash
flutter build apk \
  --flavor debug \
  --debug \
  --target-platform android-arm64 \
  --split-per-abi
```

### Output Path:
```
build/app/outputs/flutter-apk/app-debug.apk
```

### Features:
- No advertisements
- Quick build for development
- Maximum logging and debugging
- Suitable for testing gameplay

---

## Version 2: Yandex Ads APK - Release Build

**Purpose:** For distribution with Yandex Ads
**Ads Included:** 
- Banner Ads (bottom of screen during gameplay)
- Interstitial Ads (on Game Over)
- Rewarded Video Ads (optional, for bonus points)

### Build Command:
```bash
flutter build apk \
  --flavor yandex \
  --release \
  --target-platform android-arm64 \
  --split-per-abi
```

### Output Path:
```
build/app/outputs/flutter-apk/app-yandex-release.apk
```

### Ad Unit IDs:
- App ID: `269350095`
- Banner Ad: `240845807`
- Interstitial Ad: `240845808`
- Rewarded Ad: `240845809`

### Features:
- Yandex Mobile Ads integration
- Banner ads at bottom of screen
- Interstitial ads on game over
- Rewarded video ads for bonus gameplay

---

## Version 3: Google AdMob AAB - Play Store Distribution

**Purpose:** For publishing on Google Play Store
**Ads Included:**
- Banner Ads (bottom of screen)
- Interstitial Ads (on Game Over)
- Rewarded Video Ads (optional bonus)
- Native Ads (optional)
- App Open Ads

### Build Command:
```bash
flutter build appbundle \
  --flavor admob \
  --release \
  --target-platform android-arm64
```

### Output Path:
```
build/app/outputs/bundle/admobRelease/app-admob-release.aab
```

### Ad Unit IDs:
- App ID: `ca-app-pub-1727125738804934~9540663885`
- Banner Ad: `ca-app-pub-1727125738804934/5814390450`
- Interstitial Ad: `ca-app-pub-1727125738804934/4808430540`
- Rewarded Ad: `ca-app-pub-1727125738804934/2448641921`
- Native Ad: `ca-app-pub-1727125738804934/6878841524`
- App Open Ad: `ca-app-pub-1727125738804934/8191923192`

### App Ads TXT:
```
google.com, pub-1727125738804934, DIRECT, f08c47fec0942fa0
```

### Features:
- Google Mobile Ads (AdMob) integration
- Multiple ad format support
- App Store optimized
- Full Google Play Services integration

---

## Building All Versions at Once

```bash
#!/bin/bash

# Clean previous builds
flutter clean

# Version 1: Debug APK
echo "Building Debug APK (No Ads)..."
flutter build apk --flavor debug --debug --target-platform android-arm64 --split-per-abi

# Version 2: Yandex APK Release
echo "Building Yandex APK (Release)..."
flutter build apk --flavor yandex --release --target-platform android-arm64 --split-per-abi

# Version 3: Google AdMob AAB
echo "Building Google AdMob AAB (Play Store)..."
flutter build appbundle --flavor admob --release --target-platform android-arm64

echo "All builds completed!"
```

---

## Project Structure

```
Snake-battle-/
├── lib/
│   ├── main.dart                 # Main game code with ad integration
│   ├── ad_service.dart           # Base ad service (abstract)
│   ├── admob_ads_service.dart    # Google AdMob implementation
│   └── yandex_ads_service.dart   # Yandex Ads implementation
├── android/
│   ├── app/
│   │   ├── build.gradle          # App build config with flavors
│   │   ├── proguard-rules.pro    # Code obfuscation rules
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── res/values/strings.xml
│   ├── build.gradle              # Project build config
│   ├── gradle.properties         # Gradle settings
│   └── settings.gradle           # Settings
├── pubspec.yaml                  # Flutter dependencies
└── app-ads.txt                   # Google Play app-ads.txt
```

---

## Dependencies

### Core Dependencies
- `flutter` - Flutter SDK
- `audioplayers` - For game audio
- `vibration` - For haptic feedback

### Ad Dependencies (managed by flavor)
- `google_mobile_ads` - Google AdMob (admob flavor only)
- `yandex_mobileads` - Yandex Ads (yandex flavor only)

### Optional
- `shared_preferences` - For saving user preferences
- `firebase_analytics` - For analytics (admob flavor)

---

## Testing the Ads

### Debug Version (No Ads)
- Just run normally for testing gameplay
- No internet access needed
- Fastest build time

### Yandex Version
- Requires Yandex App ID configured
- Banner ads appear at bottom during gameplay
- Interstitial ads show on Game Over
- Rewarded ads available in shop (if implemented)

### AdMob Version
- Requires valid Google AdMob account
- Test Device ID needs to be configured for test ads
- Production ads show after app release on Play Store

---

## Signing & Keystore Setup

For release builds, you need a signing keystore:

```bash
# Generate keystore (one time)
keytool -genkey -v -keystore snake_battle_keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias snake_battle_key

# Then set environment variables:
export KEYSTORE_PASSWORD="your_password"
export KEY_ALIAS="snake_battle_key"
export KEY_PASSWORD="your_password"
```

---

## Troubleshooting

### Build Fails
1. Run `flutter clean`
2. Run `flutter pub get`
3. Ensure Android SDK is properly installed
4. Check Java version: `java -version` (should be 11+)

### Ads Not Showing
1. Check internet connection
2. Verify Ad Unit IDs in strings.xml
3. For AdMob: Add test device ID to admob-config
4. Check app-ads.txt placement (root of Play Console)

### APK too large
- ProGuard rules are enabled in release builds
- AAB format is recommended for Play Store (smaller download size)

---

## Release Checklist

Before publishing:
- [ ] Test all three versions on real devices
- [ ] Verify ads display correctly
- [ ] Check app-ads.txt is accessible
- [ ] Update version numbers in pubspec.yaml
- [ ] Increment buildNumber in build.gradle
- [ ] Sign APK/AAB with production keystore
- [ ] Test on Google Play Console internal testing
- [ ] Prepare store listing and screenshots
- [ ] Submit to Play Store review

---

## Support

For issues or questions, check:
- Flutter Documentation: https://flutter.dev
- Google Mobile Ads: https://developers.google.com/google-ads/mobile-ads-sdk
- Yandex Mobile Ads: https://yandex.com/dev/mobile-ads/

