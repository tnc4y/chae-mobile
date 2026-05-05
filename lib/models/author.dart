class Author {
  final String id;
  final String name;
  final String? avatarUrl;

  const Author({required this.id, required this.name, this.avatarUrl});

  factory Author.fromJson(Map<String, dynamic> json) => Author(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    avatarUrl: json['avatar_url'] as String?,
  );
}
