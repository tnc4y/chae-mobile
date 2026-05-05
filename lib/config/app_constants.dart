class AppConstants {
  static const appName = 'Chae';
  static const pageSize = 20;
  static const featuredLimit = 10;

  static const rolePremium = 'premium';
  static const roleAdmin = 'admin';
  static const roleModerator = 'moderator';
  static const roleUser = 'user';
  static const premiumRoles = [rolePremium, roleAdmin, roleModerator];

  static const typeWebtoon = 'webtoon';
  static const typeManga = 'manga';
  static const typeManhwa = 'manhwa';
  static const typeManhua = 'manhua';

  static const statusOngoing = 'ongoing';
  static const statusCompleted = 'completed';
  static const statusHiatus = 'hiatus';

  static const reportReasons = [
    'spam',
    'inappropriate',
    'spoiler',
    'harassment',
    'other',
  ];
}
