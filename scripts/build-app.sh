#!/bin/bash
set -euo pipefail

APP_NAME="Solmac"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"

echo "Building ${APP_NAME} in release mode..."
swift build -c release

echo "Creating app bundle..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${MACOS_DIR}"

cp "${BUILD_DIR}/${APP_NAME}" "${MACOS_DIR}/"
cp "Resources/Info.plist" "${CONTENTS_DIR}/"

echo "Done! ${APP_BUNDLE} created."
echo "To run: open ${APP_BUNDLE}"
