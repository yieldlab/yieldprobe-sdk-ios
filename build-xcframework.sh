#!/bin/sh

set -e
set -x

test -n "${TARGET_BUILD_DIR}"

xcodebuild archive -project SDK.xcodeproj -scheme Yieldprobe -configuration Release -archivePath "${TARGET_BUILD_DIR}-iphoneos/Yieldprobe.xcarchive" -sdk iphoneos SKIP_INSTALL=no
xcodebuild archive -project SDK.xcodeproj -scheme Yieldprobe -configuration Release -archivePath "${TARGET_BUILD_DIR}-iphonesimulator/Yieldprobe.xcarchive" -sdk iphonesimulator SKIP_INSTALL=no

xcodebuild -create-xcframework \
	-framework "${TARGET_BUILD_DIR}-iphoneos/Yieldprobe.xcarchive/Products/Library/Frameworks/Yieldprobe.framework" \
	-framework "${TARGET_BUILD_DIR}-iphonesimulator/Yieldprobe.xcarchive/Products/Library/Frameworks/Yieldprobe.framework" \
	-output "${DERIVED_FILE_DIR}/Yieldprobe.xcframework"

# 2019-10-29: “Apple is working on a fix…”
#   -- https://forums.developer.apple.com/thread/123253
find "${DERIVED_FILE_DIR}/Yieldprobe.xcframework" -name "*.swiftinterface" -exec sed -i -e 's/Yieldprobe\.//g' {} \;

ditto "${DERIVED_FILE_DIR}/Yieldprobe.xcframework" ../Sample/Frameworks/Yieldprobe.xcframework
