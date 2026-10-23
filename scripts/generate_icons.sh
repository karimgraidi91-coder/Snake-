#!/usr/bin/env bash
set -euo pipefail

echo "Running Flutter pub get and flutter_launcher_icons"
cd "$(dirname "$0")/.."

# Ensure Flutter SDK is installed and on PATH
if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter command not found. Install Flutter or run this on a machine with Flutter SDK." >&2
  exit 2
fi

flutter pub get

# Use dart run (newer flutter_launcher_icons versions recommend dart run)
dart run flutter_launcher_icons:main

echo "Launcher icons generated. Run a Flutter build to include them in the app." 
