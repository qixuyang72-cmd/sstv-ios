import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';

class ApiService {
  static const _headers = {
    'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148',
    'Accept': 'application/json,text/plain,*/*',
  };

  Future<List<String>> suggestions(String keyword) async {
    final q = keyword.trim();
    if (q.isEmpty) return [];
    try {
      final uri = Uri.parse('https://suggest.video.iqiyi.com/?if=mobile&key=${Uri.encodeQueryComponent(q)}');
      final r = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (r.statusCode != 200) return [];
      final data = jsonDecode(utf8.decode(r.bodyBytes));
      final out = <String>[];
      void walk(dynamic node) {
        if (node is Map) {
          for (final entry in node.entries) {
            final key = entry.key.toString().toLowerCase();
            final v = entry.value;
            if ((key.contains('name') || key.contains('word') || key.contains('title')) && v is String && v.trim().isNotEmpty) {
              out.add(v.trim());
            }
            walk(v);
          }
        } else if (node is List) {
          for (final v in node) walk(v);
        }
      }
      walk(data);
      return out.toSet().take(12).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<MediaItem>> hotMovies() => _doubanCollection('movie_real_time_hotest', '电影热榜');
  Future<List<MediaItem>> hotTv() => _doubanCollection('tv_real_time_hotest', '剧集热榜');
  Future<List<MediaItem>> hotShows() => _doubanCollection('show_hot', '综艺热榜');

  Future<List<MediaItem>> _doubanCollection(String collection, String source) async {
    final uri = Uri.parse(
      'https://frodo.douban.com/api/v2/subject_collection/$collection/items?apikey=0ac44ae016490db2204ce0a042db2916&start=0&count=12',
    );
    try {
      final r = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));
      if (r.statusCode != 200) return [];
      final data = jsonDecode(utf8.decode(r.bodyBytes));
      final items = (data is Map ? data['subject_collection_items'] : null) as List? ?? const [];
      return items.map<MediaItem>((raw) {
        final m = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
        final subject = m['subject'] is Map ? Map<String, dynamic>.from(m['subject']) : m;
        final title = (subject['title'] ?? subject['name'] ?? '').toString();
        final card = subject['card_subtitle']?.toString() ?? subject['original_title']?.toString() ?? '';
        String img = '';
        final pic = subject['pic'];
        if (pic is Map) img = (pic['normal'] ?? pic['large'] ?? '').toString();
        final id = (subject['id'] ?? '').toString();
        final url = id.isEmpty ? 'https://movie.douban.com' : 'https://movie.douban.com/subject/$id/';
        return MediaItem(title: title, subtitle: card, imageUrl: img, url: url, source: source);
      }).where((e) => e.title.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<MediaItem>> search(String keyword) async {
    final q = keyword.trim();
    if (q.isEmpty) return [];

    // APK 内可确认存在爱奇艺联想接口；原 App 的完整站源规则已被 AOT 编译，
    // 无法可靠恢复。因此这里以可跨平台工作的公开网页入口作为安全回退。
    final suggestionsList = await suggestions(q);
    final names = <String>[q, ...suggestionsList].toSet().take(10).toList();
    return names.map((name) {
      final query = Uri.encodeQueryComponent("$name 影视");
      final url = "https://www.baidu.com/s?wd=$query";
      return MediaItem(
        title: name,
        subtitle: '搜索相关影视信息',
        url: url,
        source: '搜索',
      );
    }).toList();
  }
}
