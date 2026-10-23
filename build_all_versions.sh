#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         SNAKE BATTLE BUILD SCRIPT              ║${NC}"
echo -e "${BLUE}║        Build All Three Versions                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}✗ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Flutter found${NC}"
echo -e "${YELLOW}Flutter version:${NC}"
flutter --version

# Clean previous builds
echo -e "\n${BLUE}Cleaning previous builds...${NC}"
flutter clean
flutter pub get

# Version 1: Debug APK (No Ads)
echo -e "\n${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}Building Version 1: Debug APK (No Ads)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
flutter build apk \
  --flavor debug \
  --debug \
  --target-platform android-arm64 \
  --split-per-abi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Debug APK built successfully!${NC}"
    echo -e "${YELLOW}Output:${NC} build/app/outputs/flutter-apk/app-debug.apk"
else
    echo -e "${RED}✗ Failed to build Debug APK${NC}"
    exit 1
fi

# Version 2: Yandex Ads APK (Release)
echo -e "\n${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}Building Version 2: Yandex Ads APK (Release)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
flutter build apk \
  --flavor yandex \
  --release \
  --target-platform android-arm64 \
  --split-per-abi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Yandex Ads APK built successfully!${NC}"
    echo -e "${YELLOW}Output:${NC} build/app/outputs/flutter-apk/app-yandex-release.apk"
else
    echo -e "${RED}✗ Failed to build Yandex Ads APK${NC}"
    exit 1
fi

# Version 3: Google AdMob AAB
echo -e "\n${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}Building Version 3: Google AdMob AAB${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
flutter build appbundle \
  --flavor admob \
  --release \
  --target-platform android-arm64

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Google AdMob AAB built successfully!${NC}"
    echo -e "${YELLOW}Output:${NC} build/app/outputs/bundle/admobRelease/app-admob-release.aab"
else
    echo -e "${RED}✗ Failed to build Google AdMob AAB${NC}"
    exit 1
fi

# Summary
echo -e "\n${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              BUILD SUMMARY                     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"

echo -e "\n${GREEN}All builds completed successfully!${NC}\n"

echo -e "${YELLOW}Version 1 - Debug APK (No Ads):${NC}"
echo "  Path: build/app/outputs/flutter-apk/app-debug.apk"
echo "  Size: $(du -h build/app/outputs/flutter-apk/app-debug.apk 2>/dev/null | cut -f1)"
echo ""

echo -e "${YELLOW}Version 2 - Yandex Ads APK:${NC}"
echo "  Path: build/app/outputs/flutter-apk/app-yandex-release.apk"
echo "  Size: $(du -h build/app/outputs/flutter-apk/app-yandex-release.apk 2>/dev/null | cut -f1)"
echo ""

echo -e "${YELLOW}Version 3 - Google AdMob AAB:${NC}"
echo "  Path: build/app/outputs/bundle/admobRelease/app-admob-release.aab"
echo "  Size: $(du -h build/app/outputs/bundle/admobRelease/app-admob-release.aab 2>/dev/null | cut -f1)"
echo ""

echo -e "${BLUE}Next steps:${NC}"
echo "1. Test Version 1 (Debug) on your Android device"
echo "2. Publish Version 2 (Yandex) to Yandex.Kassa or equivalent"
echo "3. Upload Version 3 (AdMob AAB) to Google Play Console"
echo ""
echo -e "${GREEN}Build script completed!${NC}\n"
