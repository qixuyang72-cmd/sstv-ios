import 'package:flutter/material.dart';
import '../models/media_item.dart';

class MediaTile extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final bool favorite;

  const MediaTile({super.key, required this.item, required this.onTap, this.onFavorite, this.favorite = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: item.imageUrl.isEmpty
            ? const SizedBox(width: 48, height: 68, child: Icon(Icons.movie_outlined, size: 34))
            : ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  item.imageUrl,
                  width: 48,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(width: 48, height: 68, child: Icon(Icons.movie_outlined)),
                ),
              ),
        title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          [if (item.source.isNotEmpty) item.source, if (item.subtitle.isNotEmpty) item.subtitle].join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: onFavorite == null
            ? const Icon(Icons.chevron_right)
            : IconButton(
                onPressed: onFavorite,
                icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
              ),
      ),
    );
  }
}
