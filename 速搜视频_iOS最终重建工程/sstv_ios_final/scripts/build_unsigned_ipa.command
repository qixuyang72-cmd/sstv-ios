#!/bin/bash
set -e
cd "$(dirname "$0")/.."

if ! command -v flutter >/dev/null 2>&1; then
  echo "未找到 Flutter。"
  exit 1
fi
if [ ! -d ios ]; then
  echo "尚未生成 ios 工程，请先运行 scripts/bootstrap_macos.command"
  exit 1
fi

rm -rf dist/Payload dist/速搜视频_unsigned.ipa
mkdir -p dist

echo "正在以 Release、无签名模式编译 iPhone App..."
flutter build ios --release --no-codesign

APP="build/ios/iphoneos/Runner.app"
if [ ! -d "$APP" ]; then
  echo "没有找到 $APP，构建失败。"
  exit 1
fi

mkdir -p dist/Payload
cp -R "$APP" dist/Payload/Runner.app
(
  cd dist
  /usr/bin/zip -qry "速搜视频_unsigned.ipa" Payload
  rm -rf Payload
)

echo "生成完成：dist/速搜视频_unsigned.ipa"
echo "这个 IPA 尚未签名，可再交给爱思助手/其他合法签名工具使用你自己的 Apple 账号或证书签名。"
