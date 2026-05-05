class Chapter {
  final String id;
  final String webtoonId;
  final int chapterNumber;
  final String? title;
  final bool isPremium;
  final bool isPublished;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int pageCount;
  final int coinCost;
  final String? thumbnailUrl;
  final DateTime? publishedAt;

  const Chapter({
    required this.id,
    required this.webtoonId,
    required this.chapterNumber,
    this.title,
    required this.isPremium,
    required this.isPublished,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.pageCount,
    required this.coinCost,
    this.thumbnailUrl,
    this.publishedAt,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
    id: json['id'] as String,
    webtoonId: json['webtoon_id'] as String? ?? '',
    chapterNumber: (json['chapter_number'] as num?)?.toInt() ?? 0,
    title: json['title'] as String?,
    isPremium: json['is_premium'] as bool? ?? false,
    isPublished: json['is_published'] as bool? ?? false,
    viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
    likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
    commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
    pageCount: (json['page_count'] as num?)?.toInt() ?? 0,
    coinCost: (json['coin_cost'] as num?)?.toInt() ?? 0,
    thumbnailUrl: json['thumbnail_url'] as String?,
    publishedAt: json['published_at'] != null
        ? DateTime.tryParse(json['published_at'] as String)
        : null,
  );

  String get displayTitle =>
      title?.isNotEmpty == true ? title! : 'Bölüm $chapterNumber';
}
