import 'author.dart';
import 'genre.dart';

class Webtoon {
  final String id;
  final String title;
  final String slug;
  final String? coverUrl;
  final String? bannerUrl;
  final String status;
  final String type;
  final double avgRating;
  final int ratingCount;
  final int chapterCount;
  final int viewCount;
  final bool isPremium;
  final bool isFeatured;
  final String? releaseDay;
  final String? synopsis;
  final Author? author;
  final Author? artist;
  final List<Genre> genres;

  const Webtoon({
    required this.id,
    required this.title,
    required this.slug,
    this.coverUrl,
    this.bannerUrl,
    required this.status,
    required this.type,
    required this.avgRating,
    required this.ratingCount,
    required this.chapterCount,
    required this.viewCount,
    required this.isPremium,
    required this.isFeatured,
    this.releaseDay,
    this.synopsis,
    this.author,
    this.artist,
    required this.genres,
  });

  factory Webtoon.fromJson(Map<String, dynamic> json) {
    final authorRaw = json['author'];
    final artistRaw = json['artist'];
    final genresRaw = json['webtoon_genres'] as List<dynamic>? ?? [];

    return Webtoon(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      coverUrl: json['cover_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      status: json['status'] as String? ?? 'ongoing',
      type: json['type'] as String? ?? 'webtoon',
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
      chapterCount: (json['chapter_count'] as num?)?.toInt() ?? 0,
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      isPremium: json['is_premium'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      releaseDay: json['release_day'] as String?,
      synopsis: json['synopsis'] as String?,
      author: authorRaw is Map<String, dynamic> ? Author.fromJson(authorRaw) : null,
      artist: artistRaw is Map<String, dynamic> ? Author.fromJson(artistRaw) : null,
      genres: genresRaw
          .map((e) {
            final genreData = (e as Map<String, dynamic>)['genre'];
            if (genreData is Map<String, dynamic>) {
              return Genre.fromJson(genreData);
            }
            return null;
          })
          .whereType<Genre>()
          .toList(),
    );
  }

  String get statusLabel => switch (status) {
    'ongoing' => 'Devam Ediyor',
    'completed' => 'Tamamlandı',
    'hiatus' => 'Ara Verildi',
    _ => status,
  };

  String get typeLabel => switch (type) {
    'webtoon' => 'Webtoon',
    'manga' => 'Manga',
    'manhwa' => 'Manhwa',
    'manhua' => 'Manhua',
    _ => type,
  };
}
