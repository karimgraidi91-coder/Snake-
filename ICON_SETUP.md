Steps to generate adaptive launcher icons (run locally where Flutter SDK is installed):

1. Ensure your `pubspec.yaml` contains the following dev dependency and config (already added):

```
dev_dependencies:
  flutter_launcher_icons: ^0.14.1

flutter_icons:
  android: true
  ios: false
  image_path: "assets/icon/icon.png"
  adaptive_icon_background: "#000000"
  adaptive_icon_foreground: "assets/icon/icon.png"
```

2. From the repository root run:

```bash
# make script executable once
chmod +x scripts/generate_icons.sh

# Generate icons
scripts/generate_icons.sh
```

3. After the script completes, build the APK:

```bash
flutter build apk --release
```

Notes:
- The container used by this workspace currently does not have `flutter` installed. Run the above commands on your development machine or CI runner with Flutter SDK available.
- The script uses `dart run flutter_launcher_icons:main` which works with modern Flutter + Dart toolchains.
