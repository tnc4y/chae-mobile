import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/context_colors.dart';
import '../../models/webtoon.dart';
import '../../services/favorite_service.dart';
import '../home/widgets/webtoon_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _service = FavoriteService();

  List<Webtoon> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _service.fetchFavorites();
      if (mounted) setState(() => _favorites = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Favorilerim'),
        actions: [
          if (_favorites.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_favorites.length}',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: colors.primary,
        onRefresh: _load,
        child: _buildBody(colors),
      ),
    );
  }

  Widget _buildBody(c) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: c.primary));
    }

    if (_favorites.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: c.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.bookmark_outline_rounded,
                    size: 40,
                    color: c.outline,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Henüz favori yok',
                  style: TextStyle(
                    color: c.onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Beğendiğin webtoonları buraya ekle.',
                  style: TextStyle(color: c.onSurfaceDim),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/search'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(160, 44),
                  ),
                  child: const Text('Webtoon Keşfet'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.55,
      ),
      itemCount: _favorites.length,
      itemBuilder: (_, i) => WebtoonCard(
        webtoon: _favorites[i],
        onTap: () => context.push('/home/webtoon/${_favorites[i].slug}'),
      ),
    );
  }
}
