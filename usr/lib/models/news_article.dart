class NewsArticle {
  final String id;
  final String title;
  final String summary;
  final String? imageUrl;
  final String category;
  final String source;
  final String? articleUrl;
  final bool isBreaking;
  final DateTime createdAt;

  NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    this.imageUrl,
    required this.category,
    required this.source,
    this.articleUrl,
    required this.isBreaking,
    required this.createdAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String,
      source: json['source'] as String,
      articleUrl: json['article_url'] as String?,
      isBreaking: json['is_breaking'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'image_url': imageUrl,
      'category': category,
      'source': source,
      'article_url': articleUrl,
      'is_breaking': isBreaking,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
