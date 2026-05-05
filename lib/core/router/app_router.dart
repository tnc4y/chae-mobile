import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/shell/shell_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/favorites/favorites_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/webtoon/webtoon_detail_screen.dart';
import '../../screens/reader/reader_screen.dart';
import '../../screens/history/reading_history_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/settings/themes_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter() => GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    final loc = state.matchedLocation;

    final publicRoutes = ['/', '/login', '/register'];
    if (!isLoggedIn && !publicRoutes.contains(loc)) {
      return '/login';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/reader/:chapterId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ReaderScreen(
        chapterId: state.pathParameters['chapterId']!,
        webtoonId: state.uri.queryParameters['webtoonId'] ?? '',
        webtoonType: state.uri.queryParameters['type'] ?? 'webtoon',
      ),
    ),
    GoRoute(
      path: '/themes',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ThemesScreen(),
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/reading-history',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ReadingHistoryScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => ShellScreen(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'webtoon/:slug',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => WebtoonDetailScreen(
                slug: state.pathParameters['slug']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
