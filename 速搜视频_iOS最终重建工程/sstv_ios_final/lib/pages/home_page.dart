import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/media_tile.dart';
import 'browser_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  final _api = ApiService();
  final _storage = StorageService();
  bool _loading = true;
  String? _error;
  List<MediaItem> _movies = [];
  List<MediaItem> _tv = [];
  List<MediaItem> _shows = [];
  Set<String> _favorites = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final result = await Future.wait([_api.hotMovies(), _api.hotTv(), _api.hotShows()]);
      final favs = await _storage.getFavorites();
      if (!mounted) return;
      setState(() {
        _movies = result[0];
        _tv = result[1];
        _shows = result[2];
        _favorites = favs.map((e) => '${e.title}|${e.url}').toSet();
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = '$e'; _loading = false; });
    }
  }

  Future<void> _toggle(MediaItem item) async {
    await _storage.toggleFavorite(item);
    final favs = await _storage.getFavorites();
    if (mounted) setState(() => _favorites = favs.map((e) => '${e.title}|${e.url}').toSet());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: const Text('发现'), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    if (_error != null) Card(child: Padding(padding: const EdgeInsets.all(12), child: Text('加载失败：$_error'))),
                    _section('电影热榜', _movies),
                    _section('剧集热榜', _tv),
                    _section('综艺热榜', _shows),
                    if (_movies.isEmpty && _tv.isEmpty && _shows.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('暂时没有获取到榜单数据，可在“搜索”页使用关键词搜索。')),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _section(String title, List<MediaItem> list) {
    if (list.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ),
        ...list.map((item) {
          final key = '${item.title}|${item.url}';
          return MediaTile(
            item: item,
            favorite: _favorites.contains(key),
            onFavorite: () => _toggle(item),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BrowserPage(title: item.title, url: item.url))),
          );
        }),
      ],
    );
  }
}
