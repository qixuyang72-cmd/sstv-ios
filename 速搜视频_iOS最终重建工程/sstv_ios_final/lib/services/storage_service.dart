import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_item.dart';

class StorageService {
  static const _historyKey = 'search_history_v1';
  static const _favoriteKey = 'favorites_v1';

  Future<List<String>> getSearchHistory() async {
    final p = await SharedPreferences.getInstance();
    return p.getStringList(_historyKey) ?? <String>[];
  }

  Future<void> addSearchHistory(String text) async {
    final value = text.trim();
    if (value.isEmpty) return;
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList(_historyKey) ?? <String>[];
    list.remove(value);
    list.insert(0, value);
    await p.setStringList(_historyKey, list.take(20).toList());
  }

  Future<void> clearSearchHistory() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_historyKey);
  }

  Future<List<MediaItem>> getFavorites() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList(_favoriteKey) ?? <String>[];
    return raw.map((e) => MediaItem.fromJson(jsonDecode(e))).toList();
  }

  Future<void> toggleFavorite(MediaItem item) async {
    final p = await SharedPreferences.getInstance();
    final list = await getFavorites();
    final idx = list.indexWhere((e) => e.title == item.title && e.url == item.url);
    if (idx >= 0) {
      list.removeAt(idx);
    } else {
      list.insert(0, item);
    }
    await p.setStringList(
      _favoriteKey,
      list.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<bool> isFavorite(MediaItem item) async {
    final list = await getFavorites();
    return list.any((e) => e.title == item.title && e.url == item.url);
  }
}
