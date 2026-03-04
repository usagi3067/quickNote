#!/bin/bash
set -e

APP_NAME="QuickNote"

echo "Building $APP_NAME..."
swift build -c release

echo "Creating app bundle..."
rm -rf "$APP_NAME.app"
mkdir -p "$APP_NAME.app/Contents/MacOS"
mkdir -p "$APP_NAME.app/Contents/Resources"

cp .build/release/QuickNote "$APP_NAME.app/Contents/MacOS/$APP_NAME"
cp Resources/Info.plist "$APP_NAME.app/Contents/"

echo "Signing..."
codesign --sign - \
  --entitlements QuickNote.entitlements \
  --force \
  --deep \
  "$APP_NAME.app"

echo ""
echo "Done! Built $APP_NAME.app"
echo "Run with: open $APP_NAME.app"
echo "Or drag to /Applications"
