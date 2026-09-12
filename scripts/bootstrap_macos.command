#!/bin/bash
set -e
cd "$(dirname "$0")/.."

if ! command -v flutter >/dev/null 2>&1; then
  echo "未找到 Flutter。请先在 Mac 安装 Flutter SDK，并确保 flutter 在 PATH 中。"
  exit 1
fi
if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "未找到 Xcode。请从 App Store 安装 Xcode 并至少启动一次。"
  exit 1
fi

echo "[1/5] 生成 iOS 工程..."
flutter create --platforms=ios --org com.sjz --project-name sstv_ios_rebuild .

echo "[2/5] 获取依赖..."
flutter pub get

echo "[3/5] 配置 Info.plist..."
PLIST="ios/Runner/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName 速搜视频" "$PLIST" 2>/dev/null || /usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string 速搜视频" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity dict" "$PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSAllowsArbitraryLoads bool true" "$PLIST" 2>/dev/null || /usr/libexec/PlistBuddy -c "Set :NSAppTransportSecurity:NSAllowsArbitraryLoads true" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :NSPhotoLibraryUsageDescription string 用于选择或保存视频相关内容。" "$PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :NSPhotoLibraryAddUsageDescription string 用于将内容保存到照片图库。" "$PLIST" 2>/dev/null || true

echo "复制 App 图标..."
if [ -d ios_templates/AppIcon.appiconset ]; then
  rm -rf ios/Runner/Assets.xcassets/AppIcon.appiconset
  cp -R ios_templates/AppIcon.appiconset ios/Runner/Assets.xcassets/AppIcon.appiconset
fi

echo "[4/5] iOS Pods 准备..."
cd ios
if command -v pod >/dev/null 2>&1; then
  pod install || true
else
  echo "未安装 CocoaPods。Flutter 通常会在后续构建时提示安装。"
fi
cd ..

echo "[5/5] 完成。"
echo "现在可以运行： scripts/build_unsigned_ipa.command"
