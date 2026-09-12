class MediaItem {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String url;
  final String source;

  const MediaItem({
    required this.title,
    this.subtitle = '',
    this.imageUrl = '',
    this.url = '',
    this.source = '',
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'imageUrl': imageUrl,
        'url': url,
        'source': source,
      };

  factory MediaItem.fromJson(Map<String, dynamic> json) => MediaItem(
        title: (json['title'] ?? '').toString(),
        subtitle: (json['subtitle'] ?? '').toString(),
        imageUrl: (json['imageUrl'] ?? '').toString(),
        url: (json['url'] ?? '').toString(),
        source: (json['source'] ?? '').toString(),
      );
}
