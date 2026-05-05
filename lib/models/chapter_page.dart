class ChapterPage {
  final String id;
  final int pageNumber;
  final String imageUrl;
  final int? width;
  final int? height;

  const ChapterPage({
    required this.id,
    required this.pageNumber,
    required this.imageUrl,
    this.width,
    this.height,
  });

  factory ChapterPage.fromJson(Map<String, dynamic> json) => ChapterPage(
    id: json['id'] as String,
    pageNumber: (json['page_number'] as num?)?.toInt() ?? 0,
    imageUrl: json['image_url'] as String,
    width: (json['width'] as num?)?.toInt(),
    height: (json['height'] as num?)?.toInt(),
  );

  double get aspectRatio =>
      (width != null && height != null && height! > 0)
          ? width! / height!
          : 3 / 4;
}
