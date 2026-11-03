#!/usr/bin/env bash
# Build Typing Tutor on a Mac, or run the logic tests anywhere Swift runs.
#   ./build.sh        make dist/TypingTutor-mac-universal.zip
#   ./build.sh test   run the TypingTutorCore unit tests
#
# macOS still ships Bash 3.2, so this script avoids the old bug where
# `set -e` exits a function even when the call site is an `if`.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

if [[ "${1:-}" == "test" ]]; then
  shift
  swift test "$@"
  exit 0
fi

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "The app build needs macOS. On this machine, run: ./build.sh test" >&2
  exit 1
fi

export MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-14.0}"
APP_DIR="$ROOT/App"
DIST="$ROOT/dist"
STAGE="$(mktemp -d)"
PAYLOAD="$STAGE/payload"
APP="$PAYLOAD/Typing Tutor.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$DIST"

bin_dir() {
  # Caller has already built this configuration. --show-bin-path does not rebuild.
  swift build -c release --product TypingTutor --package-path "$APP_DIR" --show-bin-path "$@"
}

UNIVERSAL=""
set +e
swift build -c release --product TypingTutor --package-path "$APP_DIR" --arch arm64 --arch x86_64
DUAL_STATUS=$?
set -e
if [[ "$DUAL_STATUS" -eq 0 ]]; then
  DUAL_DIR="$(bin_dir --arch arm64 --arch x86_64)"
  if [[ -x "$DUAL_DIR/TypingTutor" ]]; then
    DUAL_INFO="$(lipo -info "$DUAL_DIR/TypingTutor" || true)"
    if [[ "$DUAL_INFO" == *arm64* && "$DUAL_INFO" == *x86_64* ]]; then
      UNIVERSAL="$DUAL_DIR/TypingTutor"
    fi
  fi
fi

if [[ -z "$UNIVERSAL" ]]; then
  swift build -c release --product TypingTutor --package-path "$APP_DIR" --triple arm64-apple-macosx14.0
  swift build -c release --product TypingTutor --package-path "$APP_DIR" --triple x86_64-apple-macosx14.0
  ARM_DIR="$(bin_dir --triple arm64-apple-macosx14.0)"
  INTEL_DIR="$(bin_dir --triple x86_64-apple-macosx14.0)"
  if [[ ! -x "$ARM_DIR/TypingTutor" || ! -x "$INTEL_DIR/TypingTutor" ]]; then
    echo "Could not find both architecture builds under App/.build" >&2
    exit 1
  fi
  lipo -create "$ARM_DIR/TypingTutor" "$INTEL_DIR/TypingTutor" -output "$APP/Contents/MacOS/TypingTutor"
else
  cp "$UNIVERSAL" "$APP/Contents/MacOS/TypingTutor"
fi

chmod +x "$APP/Contents/MacOS/TypingTutor"
FINAL_INFO="$(lipo -info "$APP/Contents/MacOS/TypingTutor")"
echo "$FINAL_INFO"
if [[ "$FINAL_INFO" != *arm64* || "$FINAL_INFO" != *x86_64* ]]; then
  echo "The app is not a universal binary." >&2
  exit 1
fi

ICONSET="$ROOT/App/Resources/AppIcon.iconset"
if [[ ! -d "$ICONSET" ]]; then
  echo "Missing $ICONSET" >&2
  exit 1
fi
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"

cp "$ROOT/App/Info.plist" "$APP/Contents/Info.plist"
printf 'APPL????' > "$APP/Contents/PkgInfo"

BUNDLE_ID="$(plutil -extract CFBundleIdentifier raw -o - "$APP/Contents/Info.plist")"
if [[ "$BUNDLE_ID" != "com.kidscomputer.typingtutor" ]]; then
  echo "Unexpected bundle id: $BUNDLE_ID" >&2
  exit 1
fi

cp "$ROOT/README-mac.txt" "$PAYLOAD/README-mac.txt"
rm -f "$DIST/TypingTutor-mac-universal.zip"
(
  cd "$PAYLOAD"
  zip -r -y -X "$DIST/TypingTutor-mac-universal.zip" "Typing Tutor.app" "README-mac.txt"
)
cp "$ROOT/README-mac.txt" "$DIST/README-mac.txt"
rm -rf "$DIST/Typing Tutor.app"
cp -R "$APP" "$DIST/Typing Tutor.app"
rm -rf "$STAGE"

echo "Built $DIST/TypingTutor-mac-universal.zip"
