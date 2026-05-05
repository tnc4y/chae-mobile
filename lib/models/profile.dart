class Profile {
  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String role;
  final int coins;

  const Profile({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    required this.role,
    required this.coins,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    username: json['username'] as String? ?? '',
    displayName: json['display_name'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    bio: json['bio'] as String?,
    role: json['role'] as String? ?? 'user',
    coins: (json['coins'] as num?)?.toInt() ?? 0,
  );

  String get displayedName => displayName?.isNotEmpty == true ? displayName! : username;

  bool get isPremium =>
      role == 'premium' || role == 'admin' || role == 'moderator';
}
