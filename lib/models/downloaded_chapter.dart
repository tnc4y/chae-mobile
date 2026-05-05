class DownloadedChapter {
  final String chapterId;
  final String webtoonId;
  final int chapterNumber;
  final String? title;
  final int pageCount;
  final DateTime downloadedAt;
  final String cbzPath;

  const DownloadedChapter({
    required this.chapterId,
    required this.webtoonId,
    required this.chapterNumber,
    this.title,
    required this.pageCount,
    required this.downloadedAt,
    required this.cbzPath,
  });

  factory DownloadedChapter.fromJson(Map<String, dynamic> json) =>
      DownloadedChapter(
        chapterId: json['chapter_id'] as String,
        webtoonId: json['webtoon_id'] as String,
        chapterNumber: (json['chapter_number'] as num).toInt(),
        title: json['title'] as String?,
        pageCount: (json['page_count'] as num).toInt(),
        downloadedAt: DateTime.parse(json['downloaded_at'] as String),
        cbzPath: json['cbz_path'] as String,
      );

  Map<String, dynamic> toJson() => {
        'chapter_id': chapterId,
        'webtoon_id': webtoonId,
        'chapter_number': chapterNumber,
        'title': title,
        'page_count': pageCount,
        'downloaded_at': downloadedAt.toIso8601String(),
        'cbz_path': cbzPath,
      };

  String get displayTitle =>
      title?.isNotEmpty == true ? title! : 'Bölüm $chapterNumber';
}
