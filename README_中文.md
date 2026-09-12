# 速搜视频 iOS 重建工程

这是根据你提供的 `速搜视频_1.4.1.apk` 做的 iOS/Flutter 重建工程。

## 已完成
- Flutter iOS 可编译源码结构
- 发现 / 搜索 / 收藏 / 设置 4 个主要页面
- 爱奇艺搜索联想接口（从 APK 二进制可确认）
- 豆瓣电影 / 剧集 / 综艺热榜接口（从 APK 二进制可确认）
- 内置 WebView 浏览与在线播放网页能力
- 搜索历史、本地收藏
- iOS 网络权限/照片权限配置脚本
- Mac 一键生成 iOS 工程脚本
- Mac 一键编译「未签名 IPA」脚本

## 无法从 APK 直接恢复的部分
APK 中 Dart 业务代码已经 AOT 编译到 `libapp.so`，所以以下内容无法保证 1:1 恢复：
- 原作者完整站源规则
- 自定义解析器 / 私有解析接口
- 原账号登录、微信/QQ 授权业务
- 服务端鉴权、私有密钥和动态配置
- Android 专属原生插件逻辑

因此本工程不会伪造这些功能。它是一个能继续开发、能在 iOS 上编译的重建版本，而不是“把 Android 二进制改后缀”。

## 在 Mac 上生成未签名 IPA

### 1. 安装
- Xcode
- Flutter SDK
- CocoaPods（Flutter 提示需要时安装）

### 2. 第一次运行
双击或终端运行：

```bash
./scripts/bootstrap_macos.command
```

它会创建 `ios/` 工程并自动配置主要 Info.plist 项。

### 3. 生成 IPA

```bash
./scripts/build_unsigned_ipa.command
```

成功后得到：

```text
dist/速搜视频_unsigned.ipa
```

这个 IPA 是无签名构建，可再使用你自己的 Apple ID / 开发者证书进行签名。

## 爱思助手安装逻辑

```text
速搜视频_unsigned.ipa
        ↓
爱思助手 IPA 签名
        ↓
使用你自己的 Apple ID / 证书签名
        ↓
安装到 iPhone
```

如果免费 Apple ID 签名到期，需要重新签名。具体有效期取决于 Apple 当前的签名政策和你使用的账号类型。

## Bundle ID
默认建议使用：

```text
com.sjz.ss
```

如果 Xcode 提示 Bundle ID 已被占用，改成你自己的唯一值，例如：

```text
com.yourname.sstv
```

## 注意
第三方公开接口可能随时间变化或限制访问。如果榜单加载失败，不代表 iOS 工程本身不能运行。
