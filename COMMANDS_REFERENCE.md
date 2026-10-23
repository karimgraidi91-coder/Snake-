# 🐍 SNAKE BATTLE - BUILD COMMANDS REFERENCE

## Copy & Paste Build Commands

### 📦 PREREQUISITE (Run Once)
```bash
cd /workspaces/Snake-battle-
flutter clean
flutter pub get
flutter doctor --android-licenses
```

---

## 🎯 BUILD ALL VERSIONS (EASIEST)

```bash
chmod +x build_all_versions.sh
./build_all_versions.sh
```

This will:
1. Clean previous builds
2. Build Debug APK (no ads)
3. Build Yandex APK (release)
4. Build AdMob AAB (Play Store)
5. Display summary with file sizes

---

## 🔨 BUILD INDIVIDUAL VERSIONS

### VERSION 1: Debug APK (No Ads - Testing)

```bash
flutter build apk --flavor debug --debug --target-platform android-arm64 --split-per-abi
```

**Output:** `build/app/outputs/flutter-apk/app-debug.apk`

**Alternative (Universal APK):**
```bash
flutter build apk --flavor debug --debug
```

---

### VERSION 2: Yandex Ads APK (Release)

```bash
flutter build apk --flavor yandex --release --target-platform android-arm64 --split-per-abi
```

**Output:** `build/app/outputs/flutter-apk/app-yandex-release.apk`

**Alternative (Universal APK):**
```bash
flutter build apk --flavor yandex --release
```

---

### VERSION 3: Google AdMob AAB (Play Store)

```bash
flutter build appbundle --flavor admob --release --target-platform android-arm64
```

**Output:** `build/app/outputs/bundle/admobRelease/app-admob-release.aab`

---

## 🧪 TEST & DEVELOPMENT

### Run in Debug Mode

```bash
flutter run --flavor debug
```

### Run on Specific Device

```bash
flutter devices  # List connected devices
flutter run --flavor debug -d <device_id>
```

### Run on Emulator

```bash
flutter emulators  # List available emulators
flutter emulator --launch Pixel_4_API_30
flutter run --flavor debug
```

---

## 📱 INSTALL ON DEVICE

### Install Debug APK

```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### Install Yandex APK

```bash
adb install build/app/outputs/flutter-apk/app-yandex-release.apk
```

### Launch App

```bash
adb shell am start -n com.karim971210.snake_battle.debug/com.karim971210.snake_battle.MainActivity
```

---

## 🔍 VERIFY & INSPECT

### Check APK Info

```bash
aapt dump badging build/app/outputs/flutter-apk/app-debug.apk
```

### Verify APK Signature

```bash
jarsigner -verify build/app/outputs/flutter-apk/app-yandex-release.apk
```

### Check APK Size

```bash
du -h build/app/outputs/flutter-apk/*.apk
du -h build/app/outputs/bundle/admobRelease/*.aab
```

---

## 🧹 CLEANUP & MAINTENANCE

### Clean Build Cache

```bash
flutter clean
```

### Get Fresh Dependencies

```bash
flutter pub get
```

### Update Dependencies

```bash
flutter pub upgrade
```

### Check System Health

```bash
flutter doctor
flutter doctor -v
```

---

## ⚙️ CUSTOM BUILD OPTIONS

### Build with Custom Version

```bash
flutter build apk \
  --flavor debug \
  --debug \
  --build-number=2 \
  --build-name=1.0.1
```

### Build Specific Architecture

```bash
# ARM64 only
flutter build apk --flavor yandex --release --target-platform android-arm64

# x86 only (emulator)
flutter build apk --flavor yandex --release --target-platform android-x86

# Both (creates multiple APKs)
flutter build apk --flavor yandex --release --split-per-abi
```

### Build with Debug Output

```bash
flutter build apk --flavor debug --debug --verbose
```

### Increase Gradle Memory

```bash
export GRADLE_OPTS="-Xmx2048m"
flutter build appbundle --flavor admob --release
```

---

## 📊 FILE LOCATIONS

### Output Directories

Debug APK:
```
build/app/outputs/flutter-apk/app-debug.apk
```

Yandex APK:
```
build/app/outputs/flutter-apk/app-yandex-release.apk
```

AdMob AAB:
```
build/app/outputs/bundle/admobRelease/app-admob-release.aab
```

### Source Files

Main Dart:
```
lib/main.dart
```

Android Config:
```
android/app/build.gradle
android/app/src/main/AndroidManifest.xml
android/app/src/main/res/values/strings.xml
```

---

## 🐛 TROUBLESHOOTING COMMANDS

### If Build Fails

```bash
flutter clean
flutter pub get
flutter pub cache clean --expired
cd android && ./gradlew clean && cd ..
```

### Check Gradle

```bash
cd android
./gradlew clean build
cd ..
```

### View Logs

```bash
flutter logs -c  # Clear and follow logs
flutter logs     # View logs
```

### Android Studio Sync Issues

```bash
cd android
./gradlew sync
cd ..
```

### Memory Issues

```bash
export GRADLE_OPTS="-Xmx4096m -XX:MaxPermSize=512m"
flutter build appbundle --flavor admob --release
```

---

## 🔐 SIGNING & RELEASE

### Create Keystore (One Time)

```bash
keytool -genkey -v \
  -keystore android/app/keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias snake_battle_key
```

### Build Signed APK

```bash
flutter build apk \
  --flavor yandex \
  --release \
  --target-platform android-arm64 \
  --split-per-abi \
  -v
```

### Build Signed AAB

```bash
flutter build appbundle \
  --flavor admob \
  --release \
  --target-platform android-arm64 \
  -v
```

---

## 📤 UPLOAD TO STORES

### Google Play Console

1. Create app in Google Play Console
2. Upload AAB file:
   ```
   build/app/outputs/bundle/admobRelease/app-admob-release.aab
   ```
3. Upload app-ads.txt
4. Complete store listing
5. Submit for review

### Yandex Store

1. Create developer account at Yandex
2. Upload APK file:
   ```
   build/app/outputs/flutter-apk/app-yandex-release.apk
   ```
3. Configure app settings
4. Add app listing
5. Submit for review

---

## 🎯 QUICK REFERENCE

| Task | Command |
|------|---------|
| Build all 3 versions | `./build_all_versions.sh` |
| Debug APK | `flutter build apk --flavor debug --debug --split-per-abi` |
| Yandex APK | `flutter build apk --flavor yandex --release --split-per-abi` |
| AdMob AAB | `flutter build appbundle --flavor admob --release` |
| Run app | `flutter run --flavor debug` |
| Clean build | `flutter clean && flutter pub get` |
| Check health | `flutter doctor` |
| View logs | `flutter logs` |
| Install APK | `adb install build/app/outputs/flutter-apk/app-debug.apk` |

---

## 💡 USEFUL ALIASES

Add to ~/.bashrc or ~/.zshrc:

```bash
# Flutter shortcuts
alias fb='flutter build'
alias fbapk='flutter build apk'
alias fbaab='flutter build appbundle'
alias fr='flutter run'
alias fc='flutter clean && flutter pub get'
alias fd='flutter doctor'
alias fl='flutter logs -c'

# Project shortcuts
alias sbg='cd /workspaces/Snake-battle-'
alias sbuild='cd /workspaces/Snake-battle- && ./build_all_versions.sh'
```

Then use:
```bash
sbuild  # Build all versions
fr      # Run app
fc      # Clean and refresh
```

---

## 🚀 DEPLOYMENT WORKFLOW

```bash
# 1. Clean and prepare
flutter clean
flutter pub get

# 2. Build all versions
./build_all_versions.sh

# 3. Test each version
adb install build/app/outputs/flutter-apk/app-debug.apk

# 4. Upload to stores
# - Debug: Direct distribution or test stores
# - Yandex: Upload APK to Yandex Store
# - AdMob: Upload AAB to Google Play Console

# 5. Monitor after release
# - Check reviews and ratings
# - Monitor ad performance
# - Update as needed
```

---

## 📝 NOTES

- All commands assume you're in the project root: `/workspaces/Snake-battle-`
- Add `-v` or `--verbose` flag to any command for more output
- Internet connection needed for downloading dependencies
- Builds take 2-5 minutes depending on system performance
- AAB format is required for Google Play Store (not APK)
- Split APKs are more efficient than universal APK

---

## ✅ COMMAND VALIDATION

To verify commands work:

```bash
# Check Flutter version
flutter --version

# Check project structure
ls -la lib/ android/ pubspec.yaml

# Verify builds exist after building
ls -lh build/app/outputs/flutter-apk/*.apk 2>/dev/null || echo "APK not found"
ls -lh build/app/outputs/bundle/*/app*.aab 2>/dev/null || echo "AAB not found"
```

---

**Last Updated:** May 20, 2026
**Status:** Ready for Production
**Version:** 1.0.0

Use these commands to build and deploy Snake Battle across all three platforms! 🚀
