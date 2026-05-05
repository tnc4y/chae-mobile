class Genre {
  final String id;
  final String name;
  final String? color;
  final String? slug;

  const Genre({required this.id, required this.name, this.color, this.slug});

  factory Genre.fromJson(Map<String, dynamic> json) => Genre(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    color: json['color'] as String?,
    slug: json['slug'] as String?,
  );
}
