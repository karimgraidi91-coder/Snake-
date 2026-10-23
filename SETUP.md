# Installation & Setup Guide

## System Requirements

- **OS**: macOS, Linux, or Windows 10+
- **Flutter**: 3.0.0 or higher
- **Java**: JDK 11+ (for Android build)
- **Android SDK**: API 21 (Android 5.0) minimum, API 34 (Android 14) target
- **RAM**: 8GB minimum for building
- **Storage**: 10GB+ free space

## Step 1: Install Flutter

### macOS/Linux
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Add to ~/.bashrc or ~/.zshrc permanently
echo 'export PATH="$PATH:~/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

### Windows
1. Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
2. Extract to `C:\flutter` (or preferred location)
3. Add `C:\flutter\bin` to system PATH
4. Open new Command Prompt and run `flutter doctor`

## Step 2: Install Android SDK

### Using Android Studio (Recommended)
1. Download Android Studio from https://developer.android.com/studio
2. Open Android Studio and go to SDK Manager
3. Ensure these are installed:
   - Android SDK Platform 34 (or latest)
   - Android SDK Tools
   - Android Emulator
   - Intel x86 Emulator Accelerator (HAXM) - Windows/macOS

### Using Command Line
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Create Android Virtual Device (emulator)
flutter emulator --launch Pixel_4_API_30
```

## Step 3: Setup Project

### Clone Repository
```bash
git clone https://github.com/karim971210/Snake-battle-.git
cd Snake-battle-
```

### Configure Local Properties
```bash
# Copy the example file
cp android/local.properties.example android/local.properties

# Edit the file and add your Flutter SDK path
# nano android/local.properties
# Change: flutter.sdk=/path/to/flutter
```

On different OS:
- **macOS/Linux**: Edit with `nano` or `vim`
- **Windows**: Edit with Notepad

### Install Dependencies
```bash
flutter pub get
```

### Run Health Check
```bash
flutter doctor
```

Expected output (should show green checkmarks):
```
Flutter (Channel stable) • Framework • revision abc123...
Dart 3.x.x • build 3xxx
DevTools 2.x.x

[✓] Flutter (Channel stable, 3.x.x, on Linux 5.x.x)
[✓] Android toolchain - develop for Android devices
[✓] Android Studio (version 2022.3)
[✓] VS Code
```

## Step 4: Generate Resources

### For Google AdMob (AAB Build)

Create `android/app/google-services.json`:
```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "key-id",
  "private_key": "-----BEGIN RSA PRIVATE KEY-----...",
  "client_email": "firebase-adminsdk@...iam.gserviceaccount.com",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "..."
}
```

## Step 5: Create Signing Keystore (For Release Builds)

```bash
# Generate keystore (one-time)
keytool -genkey -v \
  -keystore android/app/keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias snake_battle_key

# You will be prompted for:
# - Keystore password
# - Key password
# - First and last name
# - Organization unit
# - Organization name
# - City/Town
# - State/Province
# - Country code
```

**Keep this file safe and backed up!**

## Step 6: Build for Development

### Run on Emulator
```bash
# List available emulators
flutter emulators

# Start emulator
flutter emulator --launch <emulator_name>

# Or use Android Studio's emulator

# Run app
flutter run --flavor debug
```

### Run on Physical Device
```bash
# Enable USB Debugging on device
# Go to Settings > Developer Options > USB Debugging

# Connect device
# Check connection
adb devices

# Run app
flutter run --flavor debug
```

## Step 7: Build Release Versions

### Debug APK (No Ads - Testing)
```bash
flutter build apk \
  --flavor debug \
  --debug \
  --target-platform android-arm64 \
  --split-per-abi
```

### Yandex Ads APK
```bash
flutter build apk \
  --flavor yandex \
  --release \
  --target-platform android-arm64 \
  --split-per-abi
```

### Google AdMob AAB (Play Store)
```bash
flutter build appbundle \
  --flavor admob \
  --release \
  --target-platform android-arm64
```

## Troubleshooting

### Flutter Not Found
```bash
# Check if Flutter is in PATH
which flutter

# If not, add to PATH
export PATH="$PATH:~/flutter/bin"
```

### Android SDK Issues
```bash
# Run Android tools setup
flutter doctor --android-licenses

# Accept all licenses
y
```

### Build Fails - Gradle Issues
```bash
cd android
./gradlew clean build
cd ..
```

### Emulator Issues
```bash
# Kill all emulators
adb kill-server

# Start fresh
flutter clean
flutter pub get
```

### Out of Memory During Build
```bash
# Increase Gradle memory
export GRADLE_OPTS="-Xmx2048m"
```

### Port Already in Use
```bash
# Kill process on port 8888
lsof -ti:8888 | xargs kill -9

# Or change port
flutter run --observatory-port=8889
```

## IDE Setup

### VS Code
1. Install Flutter extension: `esbenp.prettier-vscode`
2. Install Dart extension
3. Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["--flavor", "debug"]
    }
  ]
}
```

### Android Studio
1. Open Project
2. Go to Flutter Settings
3. Set Flutter SDK path
4. Click "Get Dependencies"

## Next Steps

1. **Read BUILD_GUIDE.md** - Detailed build instructions
2. **Review BUILD_COMMANDS.txt** - Individual build commands
3. **Check README.md** - Project overview
4. **Test the game** - Build debug version and test on device

## Getting Help

If you encounter issues:

1. **Check Flutter Documentation**: https://flutter.dev/docs
2. **Android Docs**: https://developer.android.com/docs
3. **Stackoverflow**: Tag with `flutter` and `android`
4. **GitHub Issues**: Check project issues section

## Development Workflow

```bash
# Start development
cd Snake-battle-

# Make changes to lib/main.dart or other files

# Run on device/emulator
flutter run --flavor debug

# Or rebuild APK after changes
flutter build apk --flavor debug --debug

# Commit changes
git add .
git commit -m "Feature: description of changes"
git push origin main
```

---

**Good luck building Snake Battle! 🐍**
