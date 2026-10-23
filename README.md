# 🐍 Snake Battle

A modern, interactive Snake game for Android with multiple ad implementations and release versions.

## Features

- 🎮 **Classic Snake Gameplay** - Control your snake and eat food to grow
- 👾 **Battle Royale Mode** - Fight against 6 AI-controlled snakes
- ✨ **Smooth Animations** - Physics-based smooth movement and collision detection
- 🎨 **Multiple Skins** - Unlock different snake skins and colors
- 🎵 **Sound & Vibration** - Audio and haptic feedback (toggleable)
- 💎 **Progressive Difficulty** - Game speeds up as you gain points
- ❤️ **Health System** - 3 lives with invincibility periods
- 📊 **Score Tracking** - High score persistence
- 🌍 **Parallax Background** - Dynamically shifting backgrounds
- 📱 **Mobile Optimized** - Touch controls with D-pad and turbo button

## Three Release Versions

This project supports building three different versions optimized for different distribution channels:

### Version 1: Debug APK (No Ads)
- **Purpose**: Testing and development
- **Ads**: None
- **Build**: `flutter build apk --flavor debug --debug --target-platform android-arm64 --split-per-abi`
- **Output**: `build/app/outputs/flutter-apk/app-debug.apk`

### Version 2: Yandex Ads APK
- **Purpose**: Distribution with Yandex Mobile Ads
- **Ads**: Banner, Interstitial, Rewarded Video
- **Build**: `flutter build apk --flavor yandex --release --target-platform android-arm64 --split-per-abi`
- **Output**: `build/app/outputs/flutter-apk/app-yandex-release.apk`

### Version 3: Google AdMob AAB
- **Purpose**: Google Play Store distribution
- **Ads**: Banner, Interstitial, Rewarded Video, Native, App Open
- **Build**: `flutter build appbundle --flavor admob --release --target-platform android-arm64`
- **Output**: `build/app/outputs/bundle/admobRelease/app-admob-release.aab`

## Quick Start

### Prerequisites
- Flutter SDK (3.0+)
- Android SDK (API 21+)
- Java 11+
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/karim971210/Snake-battle-.git
cd Snake-battle-

# Get dependencies
flutter pub get

# Check Flutter setup
flutter doctor
```

### Running the Game

```bash
# Development mode (no ads)
flutter run --flavor debug

# Or build APK
flutter build apk --flavor debug --debug
```

## Building Releases

### Build All Versions
```bash
chmod +x build_all_versions.sh
./build_all_versions.sh
```

### Build Individual Versions

**Debug (Testing):**
```bash
flutter build apk --flavor debug --debug --target-platform android-arm64 --split-per-abi
```

**Yandex (Release):**
```bash
flutter build apk --flavor yandex --release --target-platform android-arm64 --split-per-abi
```

**Google AdMob (Play Store):**
```bash
flutter build appbundle --flavor admob --release --target-platform android-arm64
```

## Project Structure

```
Snake-battle-/
├── lib/
│   ├── main.dart                      # Game code with ad integration
│   ├── ad_service.dart                # Base ad service
│   ├── admob_ads_service.dart         # Google AdMob implementation
│   └── yandex_ads_service.dart        # Yandex Ads implementation
├── android/
│   ├── app/
│   │   ├── build.gradle               # Gradle build config with flavors
│   │   ├── proguard-rules.pro        # Code obfuscation rules
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── res/values/strings.xml
│   ├── build.gradle
│   ├── gradle.properties
│   └── settings.gradle
├── pubspec.yaml                       # Flutter dependencies
├── app-ads.txt                        # Google Play app-ads.txt
├── BUILD_GUIDE.md                     # Detailed build instructions
├── BUILD_COMMANDS.txt                 # Individual build commands
├── build_all_versions.sh              # Automated build script
└── README.md                          # This file
```

## Game Controls

- **Arrow Buttons**: Move the snake in four directions
- **Turbo Button**: Hold to boost speed (bottom right)
- **Radar**: Track food and enemies (top left)
- **Health Display**: Lives remaining (top left)
- **Score Display**: Points and level (top right)

## Ad Integration

### Yandex Mobile Ads
- App ID: `269350095`
- Banner: `240845807`
- Interstitial: `240845808`
- Rewarded: `240845809`

### Google AdMob
- App ID: `ca-app-pub-1727125738804934~9540663885`
- Banner: `ca-app-pub-1727125738804934/5814390450`
- Interstitial: `ca-app-pub-1727125738804934/4808430540`
- Rewarded: `ca-app-pub-1727125738804934/2448641921`
- Native: `ca-app-pub-1727125738804934/6878841524`
- App Open: `ca-app-pub-1727125738804934/8191923192`

## Dependencies

```yaml
flutter:
  sdk: flutter

audioplayers: ^6.0.0         # Game audio
vibration: ^1.8.0            # Haptic feedback
google_mobile_ads: ^5.0.0    # Google AdMob (admob flavor)
yandex_mobileads: ^2.1.0     # Yandex Ads (yandex flavor)
shared_preferences: ^2.0.0   # User preferences
```

## Development

### Code Style
- Uses standard Dart conventions
- 80-120 character line limit
- Comments in English and Arabic
- Proper class and method naming

### Game Architecture
- Single-file structure for simplicity
- Custom painters for rendering
- Timer-based game loop
- Entity-component design for game objects

### Performance Optimizations
- Efficient collision detection
- Smooth interpolation for movement
- Optimized canvas drawing
- ProGuard obfuscation in release builds

## Testing

### Test on Device
```bash
# Debug version
adb install build/app/outputs/flutter-apk/app-debug.apk

# Run on emulator
flutter run --flavor debug
```

### Test Different Flavors
```bash
# Test Yandex flavor
flutter run --flavor yandex

# Test AdMob flavor
flutter run --flavor admob
```

## Troubleshooting

### Common Issues

**Build fails with SDK error:**
```bash
flutter clean
flutter pub get
flutter doctor
```

**Ads not showing:**
1. Check internet connection
2. Verify Ad Unit IDs in `strings.xml`
3. For AdMob: Add test device ID

**App too large:**
- Ensure ProGuard is enabled in release builds
- Use AAB format instead of APK
- Remove unused assets

## Documentation

- **BUILD_GUIDE.md** - Detailed build instructions and configurations
- **BUILD_COMMANDS.txt** - Individual build command reference
- **pubspec.yaml** - Dependency specifications
- **android/app/build.gradle** - Android build configuration with flavors

## Publishing

### Google Play Store
1. Build AAB: `flutter build appbundle --flavor admob --release`
2. Upload to Google Play Console
3. Add app store listing
4. Submit for review
5. Configure AdMob in Google Play Console

### Yandex Store
1. Build APK: `flutter build apk --flavor yandex --release`
2. Upload to Yandex App Developer account
3. Configure Yandex Ads settings
4. Submit for review

## License

This project is provided as-is for educational and commercial use.

## Support

For issues, questions, or improvements:
1. Check existing documentation
2. Review error logs: `flutter logs`
3. Test on Flutter latest version

## Credits

Created by Karim - Snake Battle Game Developer

---

## Quick Links

- [Flutter Documentation](https://flutter.dev)
- [Google Mobile Ads SDK](https://developers.google.com/google-ads/mobile-ads-sdk)
- [Yandex Mobile Ads](https://yandex.com/dev/mobile-ads/)
- [Android Developers](https://developer.android.com)

---

**Last Updated**: May 2026
**Latest Version**: 1.0.0
