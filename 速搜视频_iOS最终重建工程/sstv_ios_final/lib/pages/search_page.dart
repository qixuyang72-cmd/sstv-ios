import 'dart:async';
import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/media_tile.dart';
import 'browser_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _text = TextEditingController();
  final _api = ApiService();
  final _storage = StorageService();
  Timer? _timer;
  bool _loading = false;
  List<String> _suggestions = [];
  List<String> _history = [];
  List<MediaItem> _results = [];
  Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    _reloadHistory();
  }

  Future<void> _reloadHistory() async {
    final h = await _storage.getSearchHistory();
    if (mounted) setState(() => _history = h);
  }

  void _onChanged(String value) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 350), () async {
      final list = await _api.suggestions(value);
      if (mounted) setState(() => _suggestions = list);
    });
  }

  Future<void> _search([String? value]) async {
    final q = (value ?? _text.text).trim();
    if (q.isEmpty) return;
    _text.text = q;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _suggestions = [];
    });
    await _storage.addSearchHistory(q);
    final list = await _api.search(q);
    final favs = await _storage.getFavorites();
    if (!mounted) return;
    setState(() {
      _results = list;
      _favorites = favs.map((e) => '${e.title}|${e.url}').toSet();
      _loading = false;
    });
    _reloadHistory();
  }

  Future<void> _toggle(MediaItem item) async {
    await _storage.toggleFavorite(item);
    final favs = await _storage.getFavorites();
    if (mounted) setState(() => _favorites = favs.map((e) => '${e.title}|${e.url}').toSet());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('速搜视频')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: SearchBar(
                controller: _text,
                hintText: '输入影视名称',
                leading: const Icon(Icons.search),
                trailing: [IconButton(onPressed: _search, icon: const Icon(Icons.arrow_forward))],
                onChanged: _onChanged,
                onSubmitted: _search,
              ),
            ),
            if (_suggestions.isNotEmpty)
              SizedBox(
                height: 46,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ActionChip(label: Text(_suggestions[i]), onPressed: () => _search(_suggestions[i])),
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _results.length,
                          itemBuilder: (_, i) {
                            final item = _results[i];
                            final key = '${item.title}|${item.url}';
                            return MediaTile(
                              item: item,
                              favorite: _favorites.contains(key),
                              onFavorite: () => _toggle(item),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BrowserPage(title: item.title, url: item.url))),
                            );
                          },
                        )
                      : _historyView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyView() {
    if (_history.isEmpty) {
      return const Center(child: Text('输入关键词开始搜索'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Expanded(child: Text('搜索历史', style: TextStyle(fontWeight: FontWeight.bold))),
            TextButton(
              onPressed: () async {
                await _storage.clearSearchHistory();
                _reloadHistory();
              },
              child: const Text('清空'),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _history.map((e) => ActionChip(label: Text(e), onPressed: () => _search(e))).toList(),
        ),
      ],
    );
  }
}
