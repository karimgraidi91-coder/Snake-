#!/usr/bin/env bash
set -euo pipefail

# Root of the Flutter project
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "Cleaning project..."
flutter clean

echo "Fetching dependencies..."
flutter pub get

# Version 1: Debug APK without ads
echo "Building Version 1: Debug APK (no ads)"
flutter build apk --debug --target-platform android-arm64 --flavor noads --dart-define=AD_PROVIDER=none
cp build/app/outputs/flutter-apk/app-arm64-v8a-noads-debug.apk snake_battle_test.apk

# Version 2: Release APK with Yandex ads
echo "Building Version 2: Release APK (Yandex)"
flutter build apk --release --target-platform android-arm64 --flavor yandex --dart-define=AD_PROVIDER=yandex
cp build/app/outputs/flutter-apk/app-arm64-v8a-yandex-release.apk snake_battle_yandex.apk

# Version 3: Release AAB with Google AdMob
echo "Building Version 3: Release AAB (AdMob)"
flutter build appbundle --release --flavor admob --dart-define=AD_PROVIDER=admob
cp build/app/outputs/bundle/release/app-release.aab snake_battle_google.aab

echo "Builds completed. Output files: snake_battle_test.apk, snake_battle_yandex.apk, snake_battle_google.aab"
