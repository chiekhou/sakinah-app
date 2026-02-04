class Article {
  final String id;
  final String title;
  final String summary;
  final String theme;
  final int readingTimeMinutes;
  final String? mediaUrl;
  final bool isFeatured;

  Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.theme,
    required this.readingTimeMinutes,
    this.mediaUrl,
    this.isFeatured = false,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      summary: json['summary'] ?? '',
      theme: json['theme'],
      readingTimeMinutes: json['reading_time_minutes'] ?? 3,
      mediaUrl: json['media_url'],
      isFeatured: json['is_featured'] ?? false,
    );
  }

  String get themeEmoji {
    switch (theme) {
      case 'stress':
        return '😰';
      case 'estime':
        return '💪';
      case 'harcelement':
        return '🛡️';
      case 'emotions':
        return '💭';
      case 'sommeil':
        return '😴';
      case 'conflit':
        return '🤝';
      default:
        return '📰';
    }
  }
}

class ArticleDetail {
  final String id;
  final String title;
  final String content;
  final String summary;
  final String theme;
  final int readingTimeMinutes;
  final String? mediaUrl;

  ArticleDetail({
    required this.id,
    required this.title,
    required this.content,
    required this.summary,
    required this.theme,
    required this.readingTimeMinutes,
    this.mediaUrl,
  });

  factory ArticleDetail.fromJson(Map<String, dynamic> json) {
    return ArticleDetail(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      summary: json['summary'] ?? '',
      theme: json['theme'],
      readingTimeMinutes: json['reading_time_minutes'] ?? 3,
      mediaUrl: json['media_url'],
    );
  }
}
