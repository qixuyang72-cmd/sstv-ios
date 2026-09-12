import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _version = '';
  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((p) {
      if (mounted) setState(() => _version = '${p.version} (${p.buildNumber})');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: SafeArea(
        child: ListView(
          children: [
            const ListTile(
              leading: Icon(Icons.phone_iphone),
              title: Text('iOS 重建版'),
              subtitle: Text('根据已提供 APK 可确认的跨平台能力重新实现'),
            ),
            ListTile(leading: const Icon(Icons.info_outline), title: const Text('版本'), subtitle: Text(_version)),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '说明：原 APK 的 Dart 业务代码已经 AOT 编译，无法从安装包完整恢复原始源码。\n\n'
                '本工程实现了 iOS 可运行的搜索联想、榜单、网页浏览、收藏和搜索历史等基础能力；原 App 未能可靠还原的私有站源、解析器、账号登录或第三方授权功能不会伪造。',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
