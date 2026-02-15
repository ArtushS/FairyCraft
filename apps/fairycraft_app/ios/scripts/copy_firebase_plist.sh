#!/bin/sh
# Placeholder script: copy correct Firebase plist for selected flavor to Runner/GoogleService-Info.plist
# Usage (on macOS / CI):
#   FLAVOR=dev ./ios/scripts/copy_firebase_plist.sh
#   or set in an Xcode Run Script build phase to pick ${FLAVOR}

set -e

FLAVOR=${FLAVOR:-dev}
SRC_DIR="${SRCROOT:-..}/Runner/${FLAVOR}"
DST_FILE="${SRCROOT:-..}/Runner/GoogleService-Info.plist"

if [ ! -f "$SRC_DIR/GoogleService-Info.plist" ]; then
  echo "Missing plist for flavor '$FLAVOR' at $SRC_DIR/GoogleService-Info.plist"
  exit 1
fi

cp "$SRC_DIR/GoogleService-Info.plist" "$DST_FILE"
echo "Copied $SRC_DIR/GoogleService-Info.plist -> $DST_FILE"
