class ReadingHistoryEntry {
  final String webtoonId;
  final String chapterId;
  final int lastPage;
  final double progress;
  final DateTime lastReadAt;
  final String webtoonTitle;
  final String? webtoonCoverUrl;
  final String webtoonSlug;
  final String webtoonType;
  final int chapterNumber;
  final String? chapterTitle;
  final int pageCount;

  const ReadingHistoryEntry({
    required this.webtoonId,
    required this.chapterId,
    required this.lastPage,
    required this.progress,
    required this.lastReadAt,
    required this.webtoonTitle,
    this.webtoonCoverUrl,
    required this.webtoonSlug,
    required this.webtoonType,
    required this.chapterNumber,
    this.chapterTitle,
    required this.pageCount,
  });

  factory ReadingHistoryEntry.fromJson(Map<String, dynamic> json) {
    final webtoon = json['webtoon'] as Map<String, dynamic>;
    final chapter = json['chapter'] as Map<String, dynamic>;
    return ReadingHistoryEntry(
      webtoonId: json['webtoon_id'] as String,
      chapterId: json['chapter_id'] as String,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 0,
      progress:
          double.tryParse(json['progress']?.toString() ?? '0') ?? 0,
      lastReadAt: DateTime.parse(json['last_read_at'] as String),
      webtoonTitle: webtoon['title'] as String,
      webtoonCoverUrl: webtoon['cover_url'] as String?,
      webtoonSlug: webtoon['slug'] as String,
      webtoonType: webtoon['type'] as String? ?? 'webtoon',
      chapterNumber: (chapter['chapter_number'] as num).toInt(),
      chapterTitle: chapter['title'] as String?,
      pageCount: (chapter['page_count'] as num?)?.toInt() ?? 0,
    );
  }

  String get chapterDisplayTitle {
    final t = chapterTitle;
    if (t != null && t.isNotEmpty) return 'Bölüm $chapterNumber: $t';
    return 'Bölüm $chapterNumber';
  }
}
