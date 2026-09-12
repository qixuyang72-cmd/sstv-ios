import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/storage_service.dart';
import '../widgets/media_tile.dart';
import 'browser_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _storage = StorageService();
  List<MediaItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _storage.getFavorites();
    if (mounted) setState(() => _items = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('收藏')),
      body: SafeArea(
        child: _items.isEmpty
            ? const Center(child: Text('还没有收藏'))
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final item = _items[i];
                    return MediaTile(
                      item: item,
                      favorite: true,
                      onFavorite: () async { await _storage.toggleFavorite(item); await _load(); },
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BrowserPage(title: item.title, url: item.url))),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
